// ----------------------------------------------------------
//
//
//
// Scanners are not extensible, so we have to copy them,
//
// To Update:
//  - replace `tree-sitter-javascript/scanner.h` with `https://github.com/tree-sitter/tree-sitter-javascript/blob/master/src/scanner.c`
//
// ----------------------------------------------------------

#include "./tree-sitter-javascript/scanner.h"
#include <string.h>

enum GlimmerTokenType {
    RAW_TEXT = REGEX_PATTERN + 1,
};

static bool scan_raw_text(void *payload, TSLexer *lexer) {
    lexer->mark_end(lexer);

    const char *end_delimiter = "</TEMPLATE";

    unsigned delimiter_index = 0;
    bool is_valid = false;
    while (lexer->lookahead) {
        if ((char)towupper(lexer->lookahead) == end_delimiter[delimiter_index]) {
            delimiter_index++;
            if (delimiter_index == strlen(end_delimiter)) {
                break;
            }
            advance(lexer);
        } else {
            is_valid = true;
            delimiter_index = 0;
            advance(lexer);
            lexer->mark_end(lexer);
        }
    }
    if (is_valid) {
        lexer->result_symbol = RAW_TEXT;
    }
    return is_valid;
}

void *tree_sitter_glimmer_javascript_external_scanner_create() {
    return tree_sitter_javascript_external_scanner_create();
}

void tree_sitter_glimmer_javascript_external_scanner_destroy(void *payload) {
    tree_sitter_javascript_external_scanner_destroy(payload);
}

unsigned tree_sitter_glimmer_javascript_external_scanner_serialize(void *payload, char *buffer) {
    return tree_sitter_javascript_external_scanner_serialize(payload, buffer);
}

void tree_sitter_glimmer_javascript_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
    tree_sitter_javascript_external_scanner_deserialize(payload, buffer, length);
}

bool tree_sitter_glimmer_javascript_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
    if (valid_symbols[RAW_TEXT]) {
        return scan_raw_text(payload, lexer);
    }
    return tree_sitter_javascript_external_scanner_scan(payload, lexer, valid_symbols);
}
