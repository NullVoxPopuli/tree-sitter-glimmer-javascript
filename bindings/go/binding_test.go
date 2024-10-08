package tree_sitter_glimmer_javascript_test

import (
	"testing"

	tree_sitter "github.com/smacker/go-tree-sitter"
	"github.com/tree-sitter/tree-sitter-glimmer_javascript"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_glimmer_javascript.Language())
	if language == nil {
		t.Errorf("Error loading GlimmerJavascript grammar")
	}
}
