package handler

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/w19andrian/tuyul/internal/database"
	"github.com/w19andrian/tuyul/pkg/logger"
	"github.com/w19andrian/tuyul/pkg/random"
)

type Server struct {
	Address string
	MinChar int
	MaxChar int
	Port    string
}

func init() {
	err := database.NewDatabaseClient(0).Ping(database.Ctx).Err()
	if err != nil {
		logger.FatalLogger(err)
	}
}

// Handler for "/" path and all the trailing path except the static one
func (svr *Server) RootHandler(w http.ResponseWriter, r *http.Request) {
	path := strings.Split(strings.TrimPrefix(r.URL.Path, "/"), "/")

	if len(path) == 1 && (len(path[0]) >= svr.MinChar && len(path[0]) <= svr.MaxChar) {
		db := database.NewDatabaseClient(0)
		defer db.Close()

		url, err := db.Get(database.Ctx, path[0]).Result()
		if err != nil {
			statusResponse(w, http.StatusNotFound)
			logger.ErrorLogger(err.Error())
			logger.AccessLogger(r, http.StatusNotFound)
			return
		}
		http.Redirect(w, r, url, http.StatusPermanentRedirect)
		logger.AccessLogger(r, http.StatusPermanentRedirect)
		return
	}
	statusResponse(w, http.StatusForbidden)
	logger.AccessLogger(r, http.StatusForbidden)
}

// Handler for "/minime" endpoint
func (svr *Server) MinimeHandler(w http.ResponseWriter, r *http.Request) {
	q, ok := r.URL.Query()["uri"]
	if ok {
		// create random string between MinChar to MaxChar
		id := random.String(rand.Intn(svr.MaxChar-svr.MinChar) + svr.MinChar)

		db := database.NewDatabaseClient(0)
		defer db.Close()

		url, _ := db.Get(database.Ctx, id).Result()

		if url != "" {
			customStatusResponse(w, http.StatusInternalServerError, "whoops this is very unlikely to happen :(")
			logger.AccessLogger(r, http.StatusInternalServerError)
			logger.ErrorLogger(fmt.Sprintf("found duplication on key '%v'\n", id))
			return
		}
		err := db.Set(database.Ctx, id, q[0], 365*24*3600*time.Second).Err()
		if err != nil {
			logger.ErrorLogger(err.Error())
		}

		url, _ = db.Get(database.Ctx, id).Result()

		full_url := fmt.Sprintf("%v/%v", r.Host, id)

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusAccepted)

		err = json.NewEncoder(w).Encode(&ShortUrlResponse{
			ShortUrl: full_url,
			Target:   url,
		})
		if err != nil {
			logger.ErrorLogger(err)
		}
		logger.AccessLogger(r, http.StatusAccepted)
		return
	}
}

// Handler for "/health" endpoint
func (svr *Server) HealthHandler(w http.ResponseWriter, r *http.Request) {
	statusResponse(w, http.StatusOK)
	logger.AccessLogger(r, http.StatusOK)
}
