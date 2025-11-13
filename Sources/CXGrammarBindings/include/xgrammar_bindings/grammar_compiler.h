#pragma once

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

void* compile_json_schema_grammar(
  void* tokenizer_info,
  const char *__counted_by(schema_len) schema_utf8,
  size_t schema_len,
  int indent
);

void* compile_structural_tag(
  void* tokenizer_info,
  const char *__counted_by(structural_tag_len) structural_tag_utf8,
  size_t structural_tag_len
);

void compiled_grammar_free(void* compiled_grammar);

#ifdef __cplusplus
}
#endif
