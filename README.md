# Random Number Generator

This is an example application which inserts a random value into Redis every second; and also hosts a web page to expose that information.

## Example Usage

```shell
$ GO111MODULE=on go build -mod=vendor -o app .
$ export REDIS_HOST="example.redis.cache.windows.net"
$ export REDIS_KEY="abc123"
$ ./app
```
