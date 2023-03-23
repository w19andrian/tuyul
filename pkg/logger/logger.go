package logger

import (
	"log"
	"net/http"
)

func ErrorLogger(msg ...any) {
	log.Printf("ERROR: %v", msg)
}
func AccessLogger(r *http.Request, code int) {
	log.Printf("%v [%v] %v  User-Agent:\"%v\"  %v_%v ", r.RemoteAddr, r.Method, r.RequestURI, r.Header.Get("User-Agent"), code, http.StatusText(code))
}

func FatalLogger(msg ...any) {
	log.Fatalf("ERROR: %v\n", msg)
}
