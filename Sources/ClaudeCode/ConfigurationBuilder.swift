import Foundation

/// A builder for creating ClaudeConfiguration instances with a fluent API
///
/// Example usage:
/// ```swift
/// let config = ClaudeConfiguration.builder
///     .model(.sonnet)
///     .maxTurns(5)
///     .verbose()
///     .allowedTools(["Read", "Write", "Bash"])
///     .build()
/// ```
public struct ClaudeConfigurationBuilder {
    fileprivate var configuration = ClaudeConfiguration()

    public init() {}

    /// Sets the model to use
    public func model(_ model: ClaudeConfiguration.Model) -> Self {
        var builder = self
        builder.configuration.model = model
        return builder
    }

    /// Sets the allowed tools
    public func allowedTools(_ tools: [String]) -> Self {
        var builder = self
        builder.configuration.allowedTools = tools
        return builder
    }

    /// Sets the disallowed tools
    public func disallowedTools(_ tools: [String]) -> Self {
        var builder = self
        builder.configuration.disallowedTools = tools
        return builder
    }

    /// Enables dangerous permission skipping (use with caution)
    public func dangerouslySkipPermissions(_ skip: Bool = true) -> Self {
        var builder = self
        builder.configuration.dangerouslySkipPermissions = skip
        return builder
    }

    /// Sets the permission mode
    public func permissionMode(_ mode: ClaudeConfiguration.PermissionMode) -> Self {
        var builder = self
        builder.configuration.permissionMode = mode
        return builder
    }

    /// Sets a custom system prompt
    public func systemPrompt(_ prompt: String) -> Self {
        var builder = self
        builder.configuration.systemPrompt = prompt
        return builder
    }

    /// Appends to the system prompt
    public func appendSystemPrompt(_ prompt: String) -> Self {
        var builder = self
        builder.configuration.appendSystemPrompt = prompt
        return builder
    }

    /// Sets the system prompt file path
    public func systemPromptFile(_ path: String) -> Self {
        var builder = self
        builder.configuration.systemPromptFile = path
        return builder
    }

    /// Sets the output format
    public func outputFormat(_ format: ClaudeConfiguration.OutputFormat) -> Self {
        var builder = self
        builder.configuration.outputFormat = format
        return builder
    }

    /// Sets the input format
    public func inputFormat(_ format: ClaudeConfiguration.InputFormat) -> Self {
        var builder = self
        builder.configuration.inputFormat = format
        return builder
    }

    /// Enables JSON output
    public func jsonOutput() -> Self {
        outputFormat(.json)
    }

    /// Enables streaming JSON output
    public func streamingJsonOutput() -> Self {
        outputFormat(.streamJSON)
    }

    /// Includes partial messages in output
    public func includePartialMessages(_ include: Bool = true) -> Self {
        var builder = self
        builder.configuration.includePartialMessages = include
        return builder
    }

    /// Enables verbose logging
    public func verbose(_ enable: Bool = true) -> Self {
        var builder = self
        builder.configuration.verbose = enable
        return builder
    }

    /// Sets the maximum number of turns
    public func maxTurns(_ turns: Int) -> Self {
        var builder = self
        builder.configuration.maxTurns = turns
        return builder
    }

    /// Adds additional working directories
    public func additionalDirectories(_ directories: [String]) -> Self {
        var builder = self
        builder.configuration.additionalDirectories = directories
        return builder
    }

    /// Adds a single additional working directory
    public func addDirectory(_ directory: String) -> Self {
        var builder = self
        builder.configuration.additionalDirectories.append(directory)
        return builder
    }

    /// Sets custom agents JSON
    public func agents(_ json: String) -> Self {
        var builder = self
        builder.configuration.agents = json
        return builder
    }

    /// Sets the permission prompt tool
    public func permissionPromptTool(_ tool: String) -> Self {
        var builder = self
        builder.configuration.permissionPromptTool = tool
        return builder
    }

    /// Builds the configuration
    public func build() -> ClaudeConfiguration {
        configuration
    }
}

extension ClaudeConfiguration {
    /// Creates a new configuration builder
    public static var builder: ClaudeConfigurationBuilder {
        ClaudeConfigurationBuilder()
    }

    /// Creates a builder from an existing configuration
    public func toBuilder() -> ClaudeConfigurationBuilder {
        var builder = ClaudeConfigurationBuilder()
        builder.configuration = self
        return builder
    }
}
