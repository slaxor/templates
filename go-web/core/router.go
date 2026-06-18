// Package core wires routes to handlers, consumed by cmd/__PROJECT_NAME__.
package core

import (
	"net/http"
	"path"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

// NewRouter builds the application's route table with logging enabled.
func NewRouter() http.Handler {
	r := chi.NewRouter()
	r.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			if req.URL.Path == "/favicon.ico" {
				w.WriteHeader(http.StatusNoContent)
				return
			}

			next.ServeHTTP(w, req)
		})
	})
	r.Use(
		middleware.Logger,
		middleware.Recoverer,
	)
	r.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			cleanPath := path.Clean(req.URL.Path)

			if cleanPath == "." {
				cleanPath = "/"
			}

			if cleanPath != req.URL.Path {
				http.Redirect(w, req, cleanPath, http.StatusMovedPermanently)
				return
			}

			next.ServeHTTP(w, req)
		})
	})
	r.Get("/greet/{name}", GreetHandler)
	r.Get("/greet", GreetHandler)

	return r
}
