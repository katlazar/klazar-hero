package main

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/contrib/static"
	"github.com/gin-gonic/gin"

	"herosi/auth"
	heroc "herosi/controllers"
	"herosi/models"
	"log"
)

var key = []byte("no-te-preocupes-no-te-preocupes")

func main() {
	router := gin.Default()

	//router.Use(cors.Default())
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"*"}
	config.AllowHeaders = []string{"Origin", "Accept", "Accept-Language", "Authorization", "Content-Type", "X-CSRF-Token", "X-Requested-With",
		"Cache-Control", "If-Modified-Since", "User-Agent", "DNT", "Keep-Alive", "X-Mx-ReqToken"}
	router.Use(cors.New(config))
	router.Use(static.Serve("/", static.LocalFile("./AngularApp", true)))

	middleware, err := auth.AuthMiddleware(key)
	if err != nil {
		log.Fatal("Authentication error:" + err.Error())
	}

	db := models.SetupModels()
	router.Use(func(c *gin.Context) {
		c.Set("db", db)
		c.Next()
	})

	api := router.Group("/api")
	cam := "/heroitems"

	api.Use(middleware.MiddlewareFunc())
	{
		api.GET(cam, heroc.GetHeroes)
		api.GET(cam+"/:id", heroc.GetHero)
		api.POST(cam, heroc.AddHero)
		api.PUT(cam+"/:id", heroc.PutHero)
		api.DELETE(cam+"/:id", heroc.DeleteHero)
	}

	router.NoRoute(func(c *gin.Context) {
		c.File("./AngularApp/index.html")
	})

	router.Run(":8080")
}
