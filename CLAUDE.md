# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Environment Overview

This is a macOS development environment with multiple Node.js, TypeScript, Python, and Go projects located primarily in `Documents/GitHub/`. Projects span various domains including:

- **WhatsApp/Messaging**: Baileys WhatsApp API library and related tools
- **AI/ML**: Web LLM applications, transformers, bedtime story generator
- **Security/Cryptography**: TLS implementations, Bleichenbacher attacks, x-ray analysis tools  
- **Browser Extensions**: WhatsApp privacy extensions, web assistant tools
- **AWS/Cloud**: Token decoders, STS tools, general AWS utilities

## Common Development Commands

### Node.js Projects (Most Common)
```bash
# Install dependencies
npm install
# or
yarn install

# Development server
npm run dev

# Build project
npm run build

# Lint and type checking
npm run lint
npm run typecheck  # if available

# Testing
npm test
```

### TypeScript Projects
Many projects use TypeScript with these common patterns:
- `tsc` for compilation
- `ts-node` for running TypeScript directly
- ESLint + Prettier for code quality
- Vite or Parcel for bundling (modern projects)
- Webpack or Gulp for older projects

### Python Projects
```bash
# Virtual environment (common pattern)
python -m venv venv
source venv/bin/activate  # macOS

# Install dependencies
pip install -r requirements.txt

# Run scripts
python main.py
```

## Project Architecture Patterns

### React/Vite Projects (e.g., bedtime-story-generator)
- **Modern stack**: React 19, TypeScript, Vite, TailwindCSS
- **WebGPU integration** for local ML models
- **Custom hooks** for LLM and TTS functionality
- **Audio worklets** for real-time audio processing

### Browser Extensions (e.g., web-llm-assistant)
- **Manifest V3** structure
- **Parcel bundling** with `@parcel/config-webextension`
- **Content scripts** and background workers
- **WebExtension APIs** for browser integration

### Library Projects (e.g., Baileys)
- **Layered architecture** with composition pattern
- **Protocol implementations** (WebSocket, Signal, custom binary)
- **Event-driven** using EventEmitter patterns
- **TypeScript** with comprehensive type definitions
- **Multi-device targeting** capabilities

### Security/Crypto Projects
- **Pure implementations** of cryptographic protocols
- **Research-oriented** code for vulnerability analysis
- **Educational** examples and proof-of-concepts
- **Python/JavaScript** hybrid implementations

## Key Technologies and Patterns

### AI/ML Integration
- **Hugging Face Transformers** for local inference
- **ONNX models** running in browser via WebGPU
- **Streaming generation** with real-time UI updates
- **Audio synthesis** (Kokoro TTS) with worklet processing

### Authentication and Security  
- **Signal protocol** implementation for E2E encryption
- **Multi-file auth state** for session persistence
- **AWS token handling** and STS operations
- **TLS/SSL** protocol analysis and implementation

### Real-time Communication
- **WebSocket** connections with custom protocols
- **Binary protocol** encoding/decoding
- **Message queuing** and device targeting
- **Event sourcing** patterns

## Development Best Practices

### Code Style
- **TypeScript strict mode** enabled across projects
- **ESLint** with project-specific configurations
- **Prettier** for consistent formatting
- **Conventional commits** for changelog generation

### Testing Strategy
- **Jest** for unit testing
- **Integration tests** for protocol implementations
- **Example applications** as living documentation
- **CLI tools** for manual testing and development

### Build and Deployment
- **GitHub Actions** for CI/CD (where applicable)
- **Hugging Face Spaces** for ML demo deployments
- **Browser extension stores** for extension distribution
- **npm/yarn** package management

## Project-Specific Notes

### When working with Baileys
- Use yarn (specified in packageManager)
- Run `yarn example` for interactive testing
- Protocol changes require `yarn gen:protobuf`
- Authentication state is file-based and persistent

### When working with React/AI projects  
- Check for WebGPU requirements
- Models are cached globally to prevent re-downloads
- Audio worklets require careful timing coordination
- Build processes often include bundling of large ML models

### When working with security projects
- Code may implement known vulnerabilities for research
- Focus on educational/defensive security applications
- Implementations may be proof-of-concept rather than production

### When working with browser extensions
- Manifest V3 restrictions on background scripts
- Content Security Policy limitations
- Cross-origin request handling via background scripts
- Extension-specific APIs and permissions

## Environment Setup

### Node.js
- Using nvm for version management (`.nvm` directory present)
- Multiple Node versions supported across different projects

### Package Managers
- **npm** and **yarn** both used depending on project
- Check `packageManager` field in package.json for preference
- Some projects have yarn.lock, others package-lock.json

### Python
- **pyenv** available for Python version management  
- Virtual environments used for project isolation

### Go
- Go workspace in `~/go` directory
- Standard Go module structure where applicable

## Debugging and Development

### Common debugging approaches
- **VSCode/Cursor** debugging configurations
- **Chrome DevTools** for browser-based projects  
- **Node.js inspector** for server-side debugging
- **Console logging** with structured formats (pino, etc.)

### Performance considerations
- **WebGPU** compute shaders for ML workloads
- **Audio worklets** for low-latency audio processing
- **Binary protocols** for efficient network communication
- **Streaming** for real-time user experience