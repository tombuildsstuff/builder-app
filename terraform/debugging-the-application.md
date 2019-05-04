## Debugging the Application

In order to run the Application the following Environment Variables must be set:

* `REDIS_HOST` - which is the hostname of the Azure Redis Cache (e.g. `example.redis.cache.windows.net`)
* `REDIS_KEY` - which contains a Primary or Secondary Access Key used to access the Azure Redis Cache.

If neither of these are configured then the application will exit with an error message.

The application connects to Redis using SSL on port 6380 - so you may want to confirm that you can access `[REDIS_HOST]:6380`.

In addition the application attempts to bind a Web Server on port `8080` - so you may wish to ensure that port is available.
