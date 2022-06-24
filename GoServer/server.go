package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"strconv"
	"time"

	"github.com/alecthomas/kingpin"
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/shurcooL/httpfs/union"
	"github.com/spf13/afero"
)

const port = ":5500"

var (
	pathdata = "/var/local/logi2"
	//pathdata = "/var/local/logi2"
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}
	search       string
	datestartend string
	savefiles    []string
	stringF      bool
	//SearchMap     map[string]logenc.LogList
	date_layout   = "01/02/2006"
	startUnixTime int64
	endUnixTime   int64
	pointH        string
	filename      string
	PrevNetConn   net.Conn
	dir           = kingpin.Arg("dir", "Directory path(s) to look for files").Default(pathdata + "/repdata").ExistingFilesOrDirs()
	cron          = kingpin.Flag("cron", "").Short('t').Default("1h").String()
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
	fmt.Println(filesList)
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
	router.HandleFunc("/products/{fetchCountPercentage}", products).Methods("GET")
	router.HandleFunc("/files/{fetchPercentage}", products).Methods("GET")

	router.PathPrefix("/vfs/").Handler(http.StripPrefix("/vfs/", fileserver))
	router.HandleFunc("/ws/{b64file}", WSHandler).Methods("GET")

	fmt.Println("Serving @ http://127.0.0.1" + port)
	log.Fatal(http.ListenAndServe(port, router))

}

func rootPage(w http.ResponseWriter, r *http.Request) {

	w.Write([]byte("This is root page"))
}

func products(w http.ResponseWriter, r *http.Request) {

	fetchCountPercentage, errInput := strconv.ParseFloat(mux.Vars(r)["fetchCountPercentage"], 64)

	fetchCount := 0

	if errInput != nil {
		fmt.Println(errInput.Error())
	} else {
		fetchCount = int(float64(len(productList)) * fetchCountPercentage / 100)
		if fetchCount > len(productList) {
			fetchCount = len(productList)
		}
	}

	// write to response
	jsonList, err := json.Marshal(productList[0:fetchCount])
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)

	} else {
		w.Header().Set("content-type", "application/json")
		w.Write(jsonList)
	}

}
func filesL(w http.ResponseWriter, r *http.Request) {

	fetchPercentage, errInput := strconv.ParseFloat(mux.Vars(r)["fetchPercentage"], 64)

	fetchCount := 0

	if errInput != nil {
		fmt.Println("gg ", errInput.Error())
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

// WSHandler - Websocket handler

type product struct {
	Name  string
	Price float64
	Count int
}

var productList = []product{

	product{"p1", 25.0, 30},
	product{"p2", 20.0, 10},
	product{"p3", 250.0, 320},
	product{"p4", 256.0, 730},
	product{"p5", 24.0, 340},
	product{"p6", 10.0, 300},
	product{"p7", 100.0, 230},
	product{"p8", 2543.0, 120},
	product{"p9", 255.0, 10},
	product{"p10", 175.0, 20},
}

type files struct {
	Name string
}

var filesList = []files{
	files{"KEK"},
}
