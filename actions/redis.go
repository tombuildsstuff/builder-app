package actions

import (
	"log"
	"math/rand"
	"time"
)

func (c Client) SetRandomValueInRedis() error {
	for true {
		randomValue := generateRandomValue()
		log.Printf("[DEBUG] Setting the Random Value to %d", randomValue)

		_, err := c.client.Set(c.keyName, randomValue, 0).Result()
		if err != nil {
			return err
		}

		time.Sleep(1 * time.Second)
		continue
	}

	return nil
}

func generateRandomValue() int {
	rand.Seed(time.Now().UTC().UnixNano())
	return rand.New(rand.NewSource(time.Now().UnixNano())).Int()
}