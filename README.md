# ClaudeCode

A Swift package providing a type-safe, Swift-native interface for interacting with the [Claude Code CLI](https://claude.com/code). Built on top of the official [swift-subprocess](https://github.com/swiftlang/swift-subprocess) library for robust process management.

## Features

- 🚀 **Type-safe API** - Compile-time safety for all CLI options and flags
- 🔄 **Async/await** - Modern Swift concurrency support
- 🛠 **Fluent builders** - Convenient configuration building with method chaining
- 📦 **Zero dependencies** (except swift-subprocess)
- ✅ **Comprehensive** - Supports all Claude Code CLI features
- 🎯 **Convenience methods** - Helper functions for common use cases

## Requirements

- Swift 6.0+
- macOS 15.0+ / iOS 18.0+ / watchOS 11.0+ / tvOS 18.0+ / visionOS 2.0+
- [Claude Code CLI](https://claude.com/code) installed and accessible in PATH

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/claude-code-swift.git", from: "1.0.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ClaudeCode"]
)
```

## Usage

### Basic Usage

```swift
import ClaudeCode

// Create a Claude Code instance
let claude = ClaudeCode()

// Execute a simple prompt
let result = try await claude.execute(prompt: "What is 2+2?")
print(result.output) // Prints Claude's response

// Check for success
if result.isSuccess {
    print("Success: \(result.output)")
} else {
    print("Error: \(result.error)")
}
```

### Using Configuration

```swift
// Create configuration manually
var config = ClaudeConfiguration()
config.model = .sonnet
config.maxTurns = 5
config.verbose = true

let result = try await claude.execute(
    prompt: "Analyze this code",
    configuration: config
)
```

### Using the Fluent Builder API

```swift
let config = ClaudeConfiguration.builder
    .model(.sonnet)
    .maxTurns(5)
    .verbose()
    .allowedTools(["Read", "Write", "Bash"])
    .outputFormat(.json)
    .build()

let result = try await claude.execute(
    prompt: "Generate a summary",
    configuration: config
)
```

### Piped Input

```swift
let code = """
func hello() {
    print("Hello, World!")
}
"""

let result = try await claude.execute(
    prompt: "Explain this code",
    input: code
)
```

### Working with Files

```swift
let result = try await claude.executeWithFile(
    prompt: "Review this code for security issues",
    inputFile: "/path/to/code.swift"
)
```

### Session Management

```swift
// Continue the most recent session
let continueResult = try await claude.continueSession(
    prompt: "Can you elaborate on that?"
)

// Resume a specific session
let resumeResult = try await claude.resumeSession(
    sessionId: "abc123",
    prompt: "Let's continue"
)
```

### JSON Output

```swift
// Request JSON formatted output
let config = ClaudeConfiguration.builder
    .jsonOutput()
    .build()

let result = try await claude.execute(
    prompt: "List programming languages as JSON",
    configuration: config
)

// Or decode directly
struct Response: Codable {
    let languages: [String]
}

let decoded: Response = try await claude.executeJSON(
    prompt: "List programming languages as JSON"
)
```

### Permission Management

```swift
let config = ClaudeConfiguration.builder
    .permissionMode(.prompt)
    .allowedTools(["Read", "Grep"])
    .disallowedTools(["Write", "Bash"])
    .build()

let result = try await claude.execute(
    prompt: "Search for TODO comments",
    configuration: config
)
```

### Custom System Prompts

```swift
let config = ClaudeConfiguration.builder
    .systemPrompt("You are a Swift expert. Always provide type-safe solutions.")
    .build()

// Or append to the default prompt
let config2 = ClaudeConfiguration.builder
    .appendSystemPrompt("Focus on Swift 6 concurrency features.")
    .build()
```

### Advanced Configuration

```swift
let config = ClaudeConfiguration.builder
    .model(.sonnet)
    .maxTurns(10)
    .verbose()
    .includePartialMessages()
    .addDirectory("/path/to/project")
    .addDirectory("/path/to/resources")
    .permissionMode(.allow)
    .outputFormat(.streamJSON)
    .build()

let result = try await claude.execute(
    prompt: "Analyze the project structure",
    configuration: config,
    workingDirectory: "/path/to/project"
)
```

### Error Handling

```swift
do {
    let result = try await claude.execute(prompt: "Hello")
    let output = try result.get() // Throws if not successful
    print(output)
} catch ClaudeCodeError.claudeNotFound {
    print("Claude CLI not found. Please install it first.")
} catch ClaudeCodeError.executionFailed(let code, let message) {
    print("Execution failed with code \(code): \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

### Utility Commands

```swift
// Update Claude Code
let updateResult = try await claude.update()

// Configure MCP servers
let mcpResult = try await claude.configureMCP()
```

## Configuration Options

### Models

- `.sonnet` - Claude Sonnet (default)
- `.opus` - Claude Opus
- `.haiku` - Claude Haiku
- `.custom(String)` - Custom model name

### Permission Modes

- `.allow` - Auto-approve tool usage
- `.prompt` - Ask for permission (default)
- `.deny` - Deny tool usage

### Output Formats

- `.text` - Plain text output (default)
- `.json` - JSON formatted output
- `.streamJSON` - Streaming JSON output

### Input Formats

- `.text` - Plain text input (default)
- `.streamJSON` - Streaming JSON input

## API Reference

### ClaudeCode

The main class for interacting with Claude Code CLI.

#### Methods

- `execute(prompt:configuration:workingDirectory:)` - Execute a prompt
- `execute(prompt:input:configuration:workingDirectory:)` - Execute with piped input
- `execute(_:model:)` - Quick execute with optional model
- `executeWithFile(prompt:inputFile:configuration:)` - Execute with file input
- `executeJSON(prompt:configuration:workingDirectory:)` - Execute and decode JSON
- `continueSession(prompt:configuration:workingDirectory:)` - Continue last session
- `resumeSession(sessionId:prompt:configuration:workingDirectory:)` - Resume specific session
- `update()` - Update Claude Code
- `configureMCP()` - Configure MCP servers

### ClaudeConfiguration

Configuration options for Claude Code execution.

#### Builder Pattern

Use `ClaudeConfiguration.builder` to create configurations with a fluent API.

### ClaudeResult

Result from a Claude Code execution.

#### Properties

- `exitCode: Int32` - Process exit code
- `output: String` - Standard output
- `error: String` - Standard error
- `isSuccess: Bool` - Whether execution succeeded

#### Methods

- `get()` - Returns output or throws error
- `decodeJSON(_:)` - Decodes JSON output

## Examples

### Example 1: Code Review

```swift
let config = ClaudeConfiguration.builder
    .model(.sonnet)
    .allowedTools(["Read", "Grep"])
    .verbose()
    .build()

let result = try await claude.executeWithFile(
    prompt: "Review this code for potential bugs and security issues",
    inputFile: "Sources/MyApp/main.swift",
    configuration: config
)

print(result.output)
```

### Example 2: Project Analysis

```swift
let config = ClaudeConfiguration.builder
    .model(.sonnet)
    .addDirectory("./Sources")
    .maxTurns(10)
    .build()

let result = try await claude.execute(
    prompt: "Analyze the project structure and suggest improvements",
    configuration: config,
    workingDirectory: "/path/to/project"
)
```

### Example 3: Generate Documentation

```swift
let config = ClaudeConfiguration.builder
    .jsonOutput()
    .maxTurns(3)
    .build()

struct Documentation: Codable {
    let summary: String
    let functions: [String]
    let examples: [String]
}

let docs: Documentation = try await claude.executeJSON(
    prompt: "Generate documentation for this Swift file",
    configuration: config
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available under the MIT License.

## Related Projects

- [Claude Code](https://claude.com/code) - The official Claude Code CLI
- [swift-subprocess](https://github.com/swiftlang/swift-subprocess) - Swift subprocess library

## Support

For issues and questions:
- Open an issue on [GitHub](https://github.com/yourusername/claude-code-swift/issues)
- Check the [Claude Code documentation](https://docs.claude.com)
