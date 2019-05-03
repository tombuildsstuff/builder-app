package actions

import "github.com/go-redis/redis"

type Client struct {
	client *redis.Client
	keyName string
	webServerPort int
}

func NewClient(client *redis.Client, port int) Client {
	return Client{
		client: client,
		keyName: "example",
		webServerPort: port,
	}
}