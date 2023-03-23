package server

import (
	"fmt"
	"log"
	"net/http"

	"github.com/w19andrian/tuyul/config"
	"github.com/w19andrian/tuyul/internal/handler"
)

func Start() {
	svr := &handler.Server{
		Address: config.Config.Address,
		MinChar: 6,
		MaxChar: 10,
		Port:    config.Config.Port,
	}
	http.HandleFunc("/minime", svr.MinimeHandler)
	http.HandleFunc("/health", svr.HealthHandler)
	http.HandleFunc("/", svr.RootHandler)

	if svr.Port == "" {
		svr.Port = "3000"
	}
	if svr.Address == "" {
		svr.Address = "127.0.0.1"
	}

	log.Printf("Listening on %v:%v\n", svr.Address, svr.Port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf("%v:%v", svr.Address, svr.Port), nil))
}
