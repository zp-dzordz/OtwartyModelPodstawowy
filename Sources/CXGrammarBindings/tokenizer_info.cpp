#include "xgrammar_bindings/tokenizer_info.h"
#include "xgrammar_bindings/error_handler.h"
#include <xgrammar/tokenizer_info.h>

// Brings the xgrammar namespace into local scope so you can refer to TokenizerInfo and VocabType directly instead of xgrammar::TokenizerInfo.
using namespace xgrammar;

// Again marks the function as C-compatible (so no mangling), but here we’re implementing it.
// Its signature matches the header declaration.
extern "C" void* tokenizer_info_new(
  const char* const* vocab, size_t vocab_size, const int vocab_type,
  const int32_t* eos_tokens, size_t eos_tokens_size
) {
  // Since this code will be called from Swift (through C), it must never let a C++ exception escape, because Swift cannot handle them.
  // So this block ensures all exceptions are caught.
  try {
    std::vector<std::string> encoded_vocab;
    encoded_vocab.reserve(vocab_size);
    for (size_t i = 0; i < vocab_size; ++i) {
      encoded_vocab.emplace_back(vocab[i]);
    }
    std::vector<int32_t> stops;
    stops.reserve(eos_tokens_size);
    for (size_t i = 0; i < eos_tokens_size; ++i) {
      stops.emplace_back(eos_tokens[i]);
    }
    
    auto* tokenizer_info = new TokenizerInfo(encoded_vocab, VocabType(vocab_type), vocab_size, stops, false);
    return tokenizer_info;
  } catch (const std::exception& e) {
    catch_error(e.what());
    return nullptr;
  }
}

extern "C" void tokenizer_info_free(void* tokenizer_info) {
  if (tokenizer_info) {
    delete static_cast<TokenizerInfo*>(tokenizer_info);
  }
}
