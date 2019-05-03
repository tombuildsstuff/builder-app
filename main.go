package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/go-redis/redis"
	"github.com/tombuildsstuff/builder-app/actions"
)

func main() {
	redisServer := os.Getenv("REDIS_HOST")
	if redisServer == "" {
		panic(fmt.Errorf("`REDIS_HOST` is not set - aborting!"))
	}
	redisKey := os.Getenv("REDIS_KEY")
	if redisServer == "" {
		panic(fmt.Errorf("`REDIS_KEY` is not set - aborting!"))
	}

	redisAddress := fmt.Sprintf("%s:6380", redisServer)

	opts := &redis.Options{
		Addr: redisAddress,
		Password: redisKey,
		TLSConfig: &tls.Config{
			InsecureSkipVerify: false,
		},
	}
	client := redis.NewClient(opts)
	defer client.Close()
	if err := run(client, 8080); err != nil {
		panic(err)
	}
}

func run(client *redis.Client, port int) error {
	signalChan := make(chan os.Signal, 2)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)

	c := actions.NewClient(client, port)

	errChan := make(chan error, 2)
	go func() {
		log.Printf("[DEBUG] Starting update of random value..")
		errChan <- c.SetRandomValueInRedis()
	}()
	go func() {
		log.Printf("[DEBUG] Starting web server to retrieve that value..")
		errChan <- c.RunWebServer()
	}()

	for {
		select {
		case err := <-errChan:
			if err != nil {
				return err
			}

		case s := <-signalChan:
			log.Printf(fmt.Sprintf("Captured %v. Exiting..", s))
			return nil
		}
	}

	return nil
}
