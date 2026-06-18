package core

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestGreet(t *testing.T) {
	tests := []struct {
		name string
		in   string
		want string
	}{
		{name: "simple name", in: "world", want: "hello, world"},
		{name: "empty name", in: "", want: "hello, "},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			require.Equal(t, tt.want, Greet(tt.in))
		})
	}
}
