package main

import (
	"fmt"
	"os"

	"github.com/slaxor/__PROJECT_NAME__/core"
)

func main() {
	name := "world"
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	fmt.Println(core.Greet(name))
}
