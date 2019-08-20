package main

import (
	"github.com/labstack/echo"
)

func main() {
	e := echo.New()
	e.Static("/", "public")
	e.GET("/", func(c echo.Context) error {
		c.Response().Writer.Header().Set("Accept-Ranges", "bytes")
		c.Response().Writer.Header().Set("ETag", "5d5bd2b1-2402")
		c.Response().Writer.Header().Set("Connection", "keep-alive")
		c.Response().Writer.Header().Set("Last-Modified", "Tue, 20 Aug 2019 11:30:01 GMT")
		c.Response().Writer.Header().Set("Content-Length", "9218")
		c.Response().Writer.Header().Set("Content-Type", "text/html; charset=utf-8")
		c.Response().Writer.Header().Set("Date", "Tue, 20 Aug 2019 11:32:36 GMT")
		c.Response().Writer.Header().Set("Server", "nginx/1.10.2")
		return c.File("public/index.html")
		//return c.String(http.StatusOK, "Hello, World!")
	})
	e.Logger.Fatal(e.Start(":8081"))

}
