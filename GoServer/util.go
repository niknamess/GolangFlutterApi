package main

import (
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/hpcloud/tail"
)

func WSHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, w.Header())
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		http.Error(w, "Could not open websocket connection", http.StatusBadRequest)
		return
	}

	filenameB, _ := base64.StdEncoding.DecodeString(mux.Vars(r)["b64file"])
	filename := string(filenameB)
	// sanitize the file if it is present in the index or not.
	filename = filepath.Clean(filename)
	ok := false
	for _, wFile := range Conf.Dir {
		if filename == wFile {
			ok = true
			break
		}
	}

	// If the file is found, only then start tailing the file.
	// This is to prevent arbitrary file access. Otherwise send a 403 status
	// This should take care of stacking of filenames as it would first
	// be searched as a string in the index, if not found then rejected.
	if ok {
		go TailFile(conn, filename)
	}
	w.WriteHeader(http.StatusUnauthorized)
}

var (
	// FileList - list of files that were parsed from the provided config
	FileList []string
	visited  map[string]bool

	// Global Map that stores all the files, used to skip duplicates while
	// subsequent indexing attempts in cron trigger
	indexMap = make(map[string]bool)
)

// TailFile - Accepts a websocket connection and a filename and tails the
// file and writes the changes into the connection. Recommended to run on
// a thread as this is blocking in nature
func TailFile(conn *websocket.Conn, fileName string) {
	t, err := tail.TailFile(fileName,
		tail.Config{
			Follow: true,
			Location: &tail.SeekInfo{
				Whence: os.SEEK_END,
			},
		})
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error occurred in opening the file: ", err)
	}
	for line := range t.Lines {
		conn.WriteMessage(websocket.TextMessage, []byte(line.Text))
	}
}

// IndexFiles - takes argument as a list of files and directories and returns
// a list of absolute file strings to be tailed
func IndexFiles(fileList []string) error {
	// Re-initialize the visited array
	visited = make(map[string]bool)

	// marking all entries possible stale
	// will be removed if not updated
	for k := range indexMap {
		indexMap[k] = false
	}

	for _, file := range fileList {
		dfs(file)
	}
	// Re-initialize the file list array
	FileList = make([]string, 0)

	// Iterate through the map that contains the filenames
	for k, v := range indexMap {
		if v == false {
			delete(indexMap, k)
			continue
		}
		fmt.Fprintln(os.Stderr, k)
		FileList = append(FileList, k)
	}
	Conf.Dir = FileList
	fmt.Fprintln(os.Stderr, "Indexing complete !, file index length: ", len(Conf.Dir))
	//fmt.Println(Conf.Dir)
	return nil
}

/* skip all files that are :
   a: append-only
   l: exclusive use
   T: temporary file; Plan 9 only
   L: symbolic link
   D: device file
   p: named pipe (FIFO)
   S: Unix domain socket
   u: setuid
   g: setgid
   c: Unix character device, when ModeDevice is set
   t: sticky
*/
func dfs(file string) {
	// Mostly useful for first entry, as the paths may be like ../dir or ~/path/../dir
	// or some wierd *nixy style, Once the file is cleaned and made into an absolute
	// path, it should be safe as the next call is basepath(abspath) + "/" + name of
	// the file which should be accurate in all terms and absolute without any
	// funky conversions used in OS
	file = filepath.Clean(file)
	absPath, err := filepath.Abs(file)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to get absolute path of the file %s; err: %s\n", file, err)
	}
	if _, ok := visited[file]; ok {
		// if the absolute path has been visited, return without processing
		return
	}
	visited[file] = true
	s, err := os.Stat(absPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to stat file %s; err: %s\n", file, err)
		return
	}
	// check if the file is a directory
	if s.IsDir() {
		basepath := filepath.Clean(file)
		filelist, _ := ioutil.ReadDir(absPath)
		for _, f := range filelist {
			dfs(basepath + string(os.PathSeparator) + f.Name())
		}
	} else if strings.ContainsAny(s.Mode().String(), "alTLDpSugct") {
		// skip these files
		// @TODO try including names PIPES
	} else {
		// only remaining file are ascii files that can be then differentiated
		// by the user as golang has only these many categorization
		// Note : this appends the absolute paths
		// Insert the absPath into the Map, avoids duplicates in successive cron runs
		indexMap[absPath] = true
	}
}

type Config struct {
	Dir       []string
	ForceAuth bool
	Whitelist map[string]bool
	Cron      string
}

// Conf global config
var Conf Config

// ParseConfig - function to manage config
func ParseConfig(dir []string, cron string) error {
	// Parse cron
	// Rules for cron :
	// the string should be of type [^0](\d*)(h|d) and the integer should be positive
	// If this exact format is not presented, it will fail.

	timeUnit := cron[len(cron)-1]
	if timeUnit != 'h' && timeUnit != 'd' {
		return fmt.Errorf("invalid time unit in cron arg: %s", cron)
	}

	timeValue, err := strconv.ParseInt(cron[:len(cron)-1], 10, 32)
	if err != nil {
		//logs.ErrorLogger.Println("invalid time value" + err.Error())
		return fmt.Errorf("invalid time value in cron arg: %s", cron)
	}
	if timeValue < 0 {
		return fmt.Errorf("invalid time value in cron arg: %s", cron)
	}

	if (timeUnit == 'h' && timeValue >= 10000) || (timeUnit == 'd' && timeValue >= 365) {
		fmt.Fprintf(os.Stderr, "Whoah Dude !, That's a long time you put there...")
	}

	// First Index
	IndexFiles(dir)
	tmp := make([]interface{}, len(dir))
	for idx, x := range dir {
		tmp[idx] = x
		//log.Println(x)
	}

	// Setting up cron job to keep indexing the files
	if timeValue > 0 {
		repeat := time.Duration(timeValue) * time.Hour

		if timeUnit == 'd' {
			repeat = repeat * 24
		}
		//fmt.Println(repeat)
		//	go MakeAndStartCron(repeat, func(v ...interface{}) error { !!!
		go MakeAndStartCron(repeat, func(v ...interface{}) error {
			tmp := make([]string, len(v))
			for idx, val := range v {
				tmp[idx] = val.(string)
			}
			IndexFiles(tmp)
			return nil
		}, tmp...)
	}
	return nil
}

func MakeAndStartCron(repeat time.Duration, run func(...interface{}) error, v ...interface{}) {
	ticker := time.Tick(repeat)
	for range ticker {
		fmt.Fprintf(os.Stderr, "Running cron job @%v\n", time.Now())
		//fmt.Println("length of arg :", len(v))
		err := run(v...)
		if err != nil {
			//logs.ErrorLogger.Println("Cron job failed" + err.Error())
			fmt.Fprintf(os.Stderr, "Cron job failed: %s\n", err)
		}
	}
}
