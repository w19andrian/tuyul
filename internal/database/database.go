package database

import (
	"context"
	"crypto/tls"

	"github.com/go-redis/redis/v8"
	"github.com/w19andrian/tuyul/config"
)

var Ctx = context.Background()

func NewDatabaseClient(no int) *redis.Client {
	var rc *redis.Client
	if config.Config.RedisTLS == "TRUE" {
		rc = redis.NewClient(&redis.Options{
			Addr:      config.Config.RedisAddr,
			DB:        no,
			Username:  config.Config.RedisUser,
			Password:  config.Config.RedisPasswd,
			TLSConfig: &tls.Config{},
		})
		return rc
	} else {
		rc = redis.NewClient(&redis.Options{
			Addr:     config.Config.RedisAddr,
			DB:       no,
			Username: config.Config.RedisUser,
			Password: config.Config.RedisPasswd,
		})
		return rc
	}
}
