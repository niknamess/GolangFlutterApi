package util

import (
	"encoding/base64"
	"encoding/xml"
	"fmt"
	"strings"
)

type LogList struct {
	XMLName         xml.Name `xml:"loglist"` //dont touch XMLName
	XML_RECORD_ROOT []Log    `xml:"log"`
}
type Log struct {
	XML_APPNAME string `xml:"module_name,attr"`
	XML_APPPATH string `xml:"app_path,attr"`
	XML_APPPID  string `xml:"app_pid,attr"`
	XML_THREAD  string `xml:"thread_id,attr"`
	XML_TIME    string `xml:"time,attr"`
	XML_ULID    string `xml:"ulid,attr"`
	XML_TYPE    string `xml:"type,attr"`
	XML_MESSAGE string `xml:"message,attr"`
	XML_DETAILS string `xml:"ext_message,attr"`
	DT_FORMAT   string `xml:"ddMMyyyyhhmmsszzz,omitempty"`
}

const (
	XOR_KEY = 59
	//shortForm = "2006.01.02-15.04.05"
)

func ProcLineDecodeXML(line string) (val LogList) {

	if len(line) == 0 {

		return
	}
	lookFor := "<loglist>"
	xmlline := DecodeLine(line)
	contain := strings.Contains(xmlline, lookFor)
	if !contain {

		return
	}
	val, err := DecodeXML(xmlline)
	if err != nil {

		return
	}
	return val
}

func DecodeLine(line string) string {
	//fmt.Println(line)
	data, err := base64.StdEncoding.DecodeString(line)

	if err != nil {

		fmt.Println("error:", err)
		return ""
	}

	if len(data) <= 0 {
		return ""
	}

	k := 0
	for {
		//XOR with lines
		data[k] ^= XOR_KEY
		k++
		if k >= len(data) {
			break
		}
	}
	//print("start1")
	//print(string(data))
	//print("end1")
	return string(data)
}

func DecodeXML(line string) (LogList, error) {
	//print("DecodeXML")

	var v = LogList{}

	err := xml.Unmarshal([]byte(line), &v)

	return v, err
}

func EncodeXML(tmp LogList) (v string) {
	//print("DecodeXML")

	//var v = LogList{}

	k, _ := xml.Marshal(tmp)
	v = string(k)
	return v
}
