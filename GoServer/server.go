package main

import (
	"GoServer/util"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/alecthomas/kingpin"
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/hpcloud/tail"
	"github.com/shurcooL/httpfs/union"
	"github.com/spf13/afero"
)

const port = ":5500"

var (
	pathdata = "E:/Project/GitFlutter/GolangFlutterApi/Testdata"
	//pathdata = "/var/local/logi2"
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}
	search       string
	datestartend string
	savefiles    []string
	stringF      bool

	PrevNetConn net.Conn
	dir         = kingpin.Arg("dir", "Directory path(s) to look for files").Default(pathdata + "/repdata").ExistingFilesOrDirs()
	cron        = kingpin.Flag("cron", "").Short('t').Default("1h").String()
)

func main() {
	//cron = kingpin.Flag("cron", "").Short('t').Default("1h").String()
	kingpin.Parse()

	//pathdata = "/var/local/logi2"
	//time.Sleep(time.Second * 2)

	go func() {
		for {

			err := ParseConfig(*dir, *cron) //INDEXING FILE

			if err != nil {
				//logs.FatalLogger.Println("Indexing files on web" + err.Error())
				panic(err)

			}
			time.Sleep(time.Second * 10)
		}
	}()
	time.Sleep(time.Second * 5)
	for i := 0; i < len(Conf.Dir); i++ {
		filesList = append(filesList, files{Conf.Dir[i]})
	}
	//fmt.Println(filesList)
	dir := pathdata + "/repdata/"
	time.Sleep(time.Second * 10)
	fsbase := afero.NewBasePathFs(afero.NewOsFs(), dir)
	fsInput := afero.NewReadOnlyFs(fsbase)
	fsRoot := union.New(map[string]http.FileSystem{
		"/data": afero.NewHttpFs(fsInput),
	})

	router := mux.NewRouter()
	fileserver := http.FileServer(fsRoot)
	router.HandleFunc("/", rootPage)
	router.HandleFunc("/files/{fetchPercentage}", filesL).Methods("GET")
	router.HandleFunc("/data/{b64file}", filedata).Methods("GET")
	router.PathPrefix("/vfs/").Handler(http.StripPrefix("/vfs/", fileserver))
	router.HandleFunc("/ws/{b64file}", WSHandler).Methods("GET")

	fmt.Println("Serving @ http://127.0.0.1" + port)
	log.Fatal(http.ListenAndServe(port, router))

}

func rootPage(w http.ResponseWriter, r *http.Request) {

	w.Write([]byte("This is root page"))
}

func filesL(w http.ResponseWriter, r *http.Request) {

	fetchPercentage, errInput := strconv.ParseFloat(mux.Vars(r)["fetchPercentage"], 64)

	fetchCount := 0

	if errInput != nil {
		fmt.Println(errInput.Error())
	} else {
		fetchCount = int(float64(len(filesList)) * fetchPercentage / 100)
		if fetchCount > len(filesList) {
			fetchCount = len(filesList)
		}
	}

	// write to response
	jsonList, err := json.Marshal(filesList[0:fetchCount])
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		fmt.Println("Files")
	} else {
		w.Header().Set("content-type", "application/json")
		w.Write(jsonList)
	}

}
func filedata(w http.ResponseWriter, r *http.Request) {
	filenameB, _ := base64.StdEncoding.DecodeString(mux.Vars(r)["b64file"])
	filename := string(filenameB)
	if filenameB == nil {
		return
	}

	/* if filename == "undefined" {
		ViewDir(conn, search)
	}
	*/
	if savefiles == nil {
		//Indexing(filename)
		savefiles = append(savefiles, filename)
	} else {
		for i := 0; i < len(savefiles); i++ {
			if filename != savefiles[i] {
				stringF = true
			} else {
				stringF = false
			}
		}

	}
	if stringF {
		//Indexing(filename)
		savefiles = append(savefiles, filename)

	}

	// sanitize the file if it is present in the index or not.
	fmt.Println("sStart ", filename)

	filename = filepath.Clean(filename)
	ok := false
	for _, wFile := range Conf.Dir {
		if filename == wFile {
			ok = true
			break
		}
	}
	if ok {
		var listdata []string

		listdata = append(listdata, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><catalog>")
		fileN := filepath.Base(filename)
		fmt.Println("Start ", filename)
		t, err := tail.TailFile(pathdata+"/repdata/"+fileN,
			tail.Config{
				//ReOpen: true,
				Follow: false,
				Location: &tail.SeekInfo{
					//Offset: current,
					Whence: io.SeekStart, //!!!

				},
			})
		if err != nil {
			fmt.Fprintln(os.Stderr, "Error occurred in opening the file: ", err)
		}
		for line := range t.Lines {
			xmlsimple := util.ProcLineDecodeXML(line.Text)
			//util.EncodeXML(xmlsimple)
			listdata = append(listdata, util.EncodeXML(xmlsimple))
		}
		//fmt.Println(listdata)
		listdata = append(listdata, "</catalog>")
		result2 := strings.Join(listdata, " ")
		//	fmt.Println(result2)

		w.Header().Set("content-type", "application/xml")
		w.Write([]byte(result2))
	}

}

type files struct {
	Path string
}

var filesList = []files{}

func FileGet(fileName string, w http.ResponseWriter) {
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
		fmt.Println(line.Text)
		xmlsimple := util.ProcLineDecodeXML(line.Text)
		w.Header().Set("content-type", "application/text")
		w.Write([]byte(util.EncodeXML(xmlsimple)))
	}
}
