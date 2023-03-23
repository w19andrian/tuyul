package handler

import (
	"encoding/json"
	"log"
	"net/http"
)

type statusResponseMsg struct {
	Status  int    `json:"status"`
	Message string `json:"message"`
}

func statusResponse(w http.ResponseWriter, code int) {
	err := json.NewEncoder(w).Encode(&statusResponseMsg{
		Status:  code,
		Message: http.StatusText(code),
	})
	if err != nil {
		log.Fatal(err)
	}
}
func customStatusResponse(w http.ResponseWriter, code int, msg string) {
	w.WriteHeader(code)
	w.Header().Set("Content-Type", "application/json")
	err := json.NewEncoder(w).Encode(&statusResponseMsg{
		Status:  code,
		Message: msg,
	})
	if err != nil {
		log.Fatal(err)
	}
}
