#include "xgrammar_bindings/error_handler.h"
#include "xgrammar_bindings/grammar_compiler.h"
#include <xgrammar/matcher.h>

using namespace xgrammar;

extern "C" void* compile_json_schema_grammar(
  void* tokenizer_info,
  const char* schema_utf8,
  size_t schema_len,
  int indent
) {
  try {
    const std::string schema(schema_utf8, schema_len);
    const std::optional<int> opt_indent = (indent >= 0) ? std::optional<int>(indent) : std::nullopt;
    auto& tokenizer_info_ptr = *static_cast<TokenizerInfo*>(tokenizer_info);
    auto* compiled_grammar_ptr = new CompiledGrammar(
      GrammarCompiler(tokenizer_info_ptr).CompileJSONSchema(schema, false, opt_indent, std::nullopt, true, std::nullopt)
    );
    return compiled_grammar_ptr;
  } catch (const std::exception& e) {
    catch_error(e.what());
    return nullptr;
  }
}

extern "C" void* compile_structural_tag(
  void* tokenizer_info,
  const char* structural_tag_utf8,
  size_t structural_tag_len
) {
  try {
    const std::string structural_tag(structural_tag_utf8, structural_tag_len);
    auto& tokenizer_info_ptr = *static_cast<TokenizerInfo*>(tokenizer_info);
    auto* compiled_grammar_ptr = new CompiledGrammar(
      GrammarCompiler(tokenizer_info_ptr).CompileStructuralTag(structural_tag)
    );
    return compiled_grammar_ptr;
  } catch (const std::exception& e) {
    catch_error(e.what());
    return nullptr;
  }
}

extern "C" void compiled_grammar_free(void* compiled_grammar) {
  if (compiled_grammar) {
    delete static_cast<CompiledGrammar*>(compiled_grammar);
  }
}
