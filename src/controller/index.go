package controller

import (
	"net/http"

	"docker-gin/config"

	"github.com/gin-gonic/gin"
)

// IndexController is the default controller
type IndexController struct{}

// Index the default page
func (ctrl *IndexController) Index(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"version": config.Server.Version,
	})
}
