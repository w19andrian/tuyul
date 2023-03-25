package database

import (
	"context"
	"crypto/tls"
	"time"

	"github.com/go-redis/redis/v8"
	"github.com/w19andrian/tuyul/config"
)

var Ctx = context.Background()

func NewDatabaseClient(no int) *redis.Client {
	var t *tls.Config
	if config.Config.RedisTLS == "TRUE" {
		t = &tls.Config{InsecureSkipVerify: true}
	} else {
		t = nil
	}

	rc := redis.NewClient(&redis.Options{
		Addr:      config.Config.RedisAddr,
		DB:        no,
		Username:  config.Config.RedisUser,
		Password:  config.Config.RedisPasswd,
		TLSConfig: t,
	})
	return rc
}

func NewDatabaseClusterClient() *redis.ClusterClient {
	var t *tls.Config
	if config.Config.RedisTLS == "TRUE" {
		t = &tls.Config{InsecureSkipVerify: true}
	} else {
		t = nil
	}

	rc := redis.NewClusterClient(&redis.ClusterOptions{
		Addrs:        []string{config.Config.RedisAddr},
		Username:     config.Config.RedisUser,
		Password:     config.Config.RedisPasswd,
		PoolSize:     100,
		MinIdleConns: 10,

		DialTimeout:  5 * time.Second,
		ReadTimeout:  3 * time.Second,
		WriteTimeout: 3 * time.Second,
		PoolTimeout:  4 * time.Second,

		IdleCheckFrequency: 60 * time.Second,
		IdleTimeout:        5 * time.Minute,
		MaxConnAge:         0 * time.Second,

		MaxRetries:      10,
		MinRetryBackoff: 8 * time.Millisecond,
		MaxRetryBackoff: 512 * time.Millisecond,

		TLSConfig: t,

		ReadOnly:       false,
		RouteRandomly:  false,
		RouteByLatency: false,
	})

	return rc
}
