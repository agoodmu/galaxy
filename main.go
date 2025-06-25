package main

import (
	"net/http"
	"os"

	"github.com/agoodmu/galaxy/assets"
	"github.com/agoodmu/galaxy/ginrender"
	"github.com/agoodmu/galaxy/ui/pages"
	"github.com/gin-gonic/gin"
)

var listen_port = "8080"

func init() {
	port, exists := os.LookupEnv("Port")
	if exists {
		listen_port = port
	}
}

func main() {
	router := gin.Default()

	ginHtmlRenderer := router.HTMLRender
	router.HTMLRender = &ginrender.HTMLTemplRenderer{FallbackHtmlRenderer: ginHtmlRenderer}

	v := router.Group("/")
	{
		v.GET("/", func(c *gin.Context) {
			c.Render(http.StatusOK, ginrender.New(c, http.StatusOK, pages.Landing()))
		})
		v.StaticFS("/assets", http.FS(assets.Assets))
		router.GET("/ping", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message": "pong",
			})
		})
	}

	router.Run("0.0.0.0:" + listen_port)
}
