"use strict";

const JavaScript = require("tree-sitter-javascript/grammar");

/**
 * A <template></template> block can exist in
 * two types of locations:
 * 1. class body
 * 2. any expression
 *
 * The contents of `<template>contents</template>`
 * are handled by tree-sitter-glimmer
 *   https://github.com/ember-tooling/tree-sitter-glimmer
 */
module.exports = grammar(JavaScript, {
  name: "glimmer_javascript",
  rules: {
    /**
     * TODO: add support for attributes
     *       e.g.:
     *
     *       <template trim-invisibles>
     *       <template signature:{SomeInterface}>
     *
     *       Either will require RFC
     *         https://github.com/emberjs/rfcs/
     */
    glimmer_template: ($) =>
      choice(
        seq(
          field("open_tag", $.glimmer_opening_tag),
          // field("content", $.glimmer_template_content),
          field("content", repeat($._glimmer_template_content)),
          field("close_tag", $.glimmer_closing_tag),
        ),
        // empty template has no content
        // <template></template>
        seq(
          field("open_tag", $.glimmer_opening_tag),
          field("close_tag", $.glimmer_closing_tag),
        ),
      ),

    _glimmer_template_content: (_) => /.{1,}/,
    // glimmer_template_content: ($) => repeat1($._glimmer_template_content),
    glimmer_opening_tag: (_) => "<template>",
    glimmer_closing_tag: (_) => "</template>",

    /**
     * 2. Any Expression.
     * e.g.:
     *
     *   ```gts
     *   export const Foo = <template>...</template>
     *   ```
     *
     * TS: https://github.com/tree-sitter/tree-sitter-typescript/blob/master/common/define-grammar.js#L212
     * JS: https://github.com/tree-sitter/tree-sitter-javascript/blob/master/grammar.js#L479
     */
    expression: ($, previous) => {
      const choices = [
        ...previous.members.filter((member) => {
          // glimmer stuff is already in the upstream javascript grammar,
          // but they want to remove it.
          // So as a transitional step, I'll pretend it's already removed here.
          return (
            member.name !== "_jsx_element" && !member.name.includes("glimmer")
          );
        }),
        $.glimmer_template,
      ];

      return choice(...choices);
    },

    /**
     * This one can't be extended as nicely as Expression, because this node
     * contains a character sequence (seq)
     *
     * Most of thish is copied from upstream (TS), and only $.glimmer_template is added
     *
     * TS: https://github.com/tree-sitter/tree-sitter-typescript/blob/master/common/define-grammar.js#L419
     * JS: https://github.com/tree-sitter/tree-sitter-javascript/blob/master/grammar.js#L1150
     */
    class_body: ($) =>
      seq(
        "{",
        repeat(
          choice(
            seq(field("member", $.method_definition), optional(";")),
            seq(field("member", $.field_definition), $._semicolon),
            field("member", $.class_static_block),
            field("template", $.glimmer_template),
            ";",
          ),
        ),
        "}",
      ),
  },
});
