// Package core provides the logic consumed by cmd/__PROJECT_NAME__.
package core

import "fmt"

// Greet returns a greeting for name.
func Greet(name string) string {
	return fmt.Sprintf("hello, %s", name)
}
