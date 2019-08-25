package main

import (
	"fmt"
	"github.com/labstack/echo"
	"net/http"
)

func main() {

	ec := echo.New()
	ec.Static("/", "public")
	ec.GET("/", func(c echo.Context) error {
		return c.Redirect(http.StatusMovedPermanently, "http://mirror.azure.cn/")
	})
	ec.GET("/:parmar", func(c echo.Context) error {
		Param := c.Param("parmar")
		fmt.Println(Param)
		return c.Redirect(http.StatusMovedPermanently, "http://mirror.azure.cn/"+Param)
	})
	ec.Logger.Fatal(ec.Start(":8082"))
}
