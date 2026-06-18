package main

import (
	"fmt"
	"os"

	"codeberg.org/slaxor/__PROJECT_NAME__/core"
)

func main() {
	name := "world"
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	fmt.Println(core.Greet(name))
}
