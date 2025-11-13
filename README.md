# OtwartyModelPodstawowy

Preliminary work on an open-source, drop-in replacement for Apple’s **FoundationModels** framework.  
The goal is to enable:

- Users with older iOS and macOS devices.  
- Users working with unsupported languages (such as Polish).  
- Developers who want to learn syntax and experiment with the framework’s concepts.  

This project is also a personal learning exercise for me — I want to understand LLMs better while building something practical.  

⚠️ **Note:** This is a toy project compared to the original FoundationModels.  
Apple’s framework integrates an expertly trained small local model embedded into the OS plus a privacy-conscious larger network model.  
Therefore, **efficiency and performance here are not expected to be comparable**.  

---

## Thank you note

I’m using parts of the source code from the following projects:
- https://github.com/apple/swift-openapi-generator - JSON schema support
- https://github.com/petrukha-ivan/mlx-swift-structured - constrained token generation

Thanks for sharing your work!

---

## Current Status

The current implementation uses [`speakleash/Bielik-7B-Instruct-v0.1-MLX`](https://huggingface.co/speakleash/Bielik-7B-Instruct-v0.1-MLX),  
which requires ~4 GB of RAM.  
For now, I’m testing and developing it on a MacBook Pro with M1 chip (16 GB RAM).  

---

## TODO

- [ ] Find a smaller, localized model, better suited for on-device tasks (see hints in Apple’s [Foundation Models 2025 Updates](https://machinelearning.apple.com/research/apple-foundation-models-2025-updates))  
- [ ] Tool calling — mandatory for more serious tasks  
- [ ] Guided generation — a very interesting feature to explore  

---

## License

[MIT](./LICENSE)
