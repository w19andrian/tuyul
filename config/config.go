package config

import "os"

type TuyulConfig struct {
	Address     string
	Port        string
	RedisAddr   string
	RedisUser   string
	RedisPasswd string
	RedisTLS    string
}

var Config = &TuyulConfig{
	Address:     os.Getenv("TUYUL_ADDR"),
	Port:        os.Getenv("TUYUL_PORT"),
	RedisAddr:   os.Getenv("REDIS_ADDR"),
	RedisUser:   os.Getenv("REDIS_USER"),
	RedisPasswd: os.Getenv("REDIS_PASSWD"),
	RedisTLS:    os.Getenv("REDIS_TLS_ENABLED"),
}
