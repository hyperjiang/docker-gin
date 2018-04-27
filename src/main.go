package main

import (
	"docker-gin/router"

	"github.com/gin-gonic/gin"
)

func main() {
	app := gin.Default()

	app.StaticFile("/favicon.ico", "/app/public/favicon.ico")

	router.Route(app)

	// Listen and Serve
	app.Run(":80")
}
