package core

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
)

type greeting struct {
	Message string `json:"message"`
}

// GreetHandler responds with a JSON greeting for the {name} path value.
func GreetHandler(w http.ResponseWriter, r *http.Request) {
	name := chi.URLParam(r, "name")
	if name == "" {
		name = "world"
	}
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(greeting{Message: "hello, " + name}); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
