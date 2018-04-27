package router

import (
	"docker-gin/controller"

	"github.com/gin-gonic/gin"
)

// Route makes the routing
func Route(app *gin.Engine) {
	indexController := new(controller.IndexController)

	app.GET(
		"/", indexController.Index,
	)
}
