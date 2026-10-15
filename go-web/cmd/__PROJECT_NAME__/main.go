package main

import (
	"log"
	"net/http"

	"github.com/slaxor/__PROJECT_NAME__/core"
)

func main() {
	addr := ":8080"
	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, core.NewRouter()); err != nil {
		log.Fatal(err)
	}
}
