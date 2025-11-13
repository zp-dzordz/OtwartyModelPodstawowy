// This is a header guard. It ensures the file is only included once per compilation unit, preventing multiple definition errors. It’s equivalent to the classic
#pragma once

#include <stdio.h>

// This chunk declares that what follows should use C linkage, not C++.
/* That’s crucial because Swift (and the C runtime it calls into) can only talk to C-style functions, not C++ ones (which have name mangling).
In essence: it says “if we’re compiling as C++, don’t mangle these names.”*/
#ifdef __cplusplus
extern "C" {
#endif

void* tokenizer_info_new(
    const char* const* vocab, size_t vocab_size, const int vocab_type,
    const int32_t* eos_tokens, size_t eos_tokens_size
);

//This declares a function that creates a new TokenizerInfo object and returns it as an opaque void* pointer — meaning “some memory I can’t see inside.”
void tokenizer_info_free(void* tokenizer_info);

#ifdef __cplusplus
}
#endif
