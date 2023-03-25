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

type ShortUrlResponse struct {
	ShortUrl string `json:"short_url"`
	Target   string `json:"target"`
}

func statusResponse(w http.ResponseWriter, code int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)

	err := json.NewEncoder(w).Encode(&statusResponseMsg{
		Status:  code,
		Message: http.StatusText(code),
	})
	if err != nil {
		log.Fatal(err)
	}
}
func customStatusResponse(w http.ResponseWriter, code int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)

	err := json.NewEncoder(w).Encode(&statusResponseMsg{
		Status:  code,
		Message: msg,
	})
	if err != nil {
		log.Fatal(err)
	}
}
