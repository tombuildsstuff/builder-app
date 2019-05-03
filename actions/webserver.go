package actions

import (
	"fmt"
	"net/http"

	"github.com/go-redis/redis"
)

func (c Client) RunWebServer() error {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		val, err := c.client.Get(c.keyName).Result()
		if err != nil {
			if err != redis.Nil {
				panic(err)
			}

			val = "(not yet set)"
		}

		w.Write([]byte(renderTemplate(val)))
	})

	return http.ListenAndServe(fmt.Sprintf(":%d", c.webServerPort), nil)
}

func renderTemplate(randomValue string) string {
	return fmt.Sprintf(`
<!DOCTYPE html>
<html>
 <head>
  <title>Example</title>
  <meta http-equiv="refresh" content="1" />
 </head>
 <body>
  <p>The current random value is:</p>
  <h1>%s</h1>
 </body>
</html>
`, randomValue)
}