import Foundation

/// Environment configuration for Claude Code CLI execution
///
/// This struct provides type-safe access to Claude Code environment variables.
/// Environment variables can be set to customize Claude's behavior without
/// modifying command-line arguments.
///
/// Example usage:
/// ```swift
/// let env = ClaudeEnvironment.builder
///     .apiKey("your-api-key")
///     .model("claude-sonnet-4")
///     .disableTelemetry()
///     .build()
///
/// let claude = ClaudeCode(environment: env)
/// ```
public struct ClaudeEnvironment: Sendable {

    // MARK: - Properties

    // Authentication & API
    /// API key sent as X-Api-Key header
    public var apiKey: String?

    /// Custom value for the Authorization header
    public var authToken: String?

    /// Custom headers to add to requests (JSON format)
    public var customHeaders: String?

    // Model Configuration
    /// Specifies which model to use
    public var model: String?

    /// Default Haiku model version
    public var defaultHaikuModel: String?

    /// Default Opus model version
    public var defaultOpusModel: String?

    /// Default Sonnet model version
    public var defaultSonnetModel: String?

    /// Model to use for subagents
    public var subagentModel: String?

    // Bash & Command Execution
    /// Default timeout for long-running bash commands (in milliseconds)
    public var bashDefaultTimeout: Int?

    /// Maximum number of characters in bash outputs
    public var bashMaxOutputLength: Int?

    /// Maximum timeout the model can set (in milliseconds)
    public var bashMaxTimeout: Int?

    // Feature Controls
    /// Disable telemetry collection
    public var disableTelemetry: Bool

    /// Disable error reporting
    public var disableErrorReporting: Bool

    /// Disable automatic updates
    public var disableAutoUpdater: Bool

    /// Disable prompt caching
    public var disablePromptCaching: Bool

    /// Enable extended thinking for complex tasks (maximum thinking tokens)
    public var maxThinkingTokens: Int?

    // Proxy & Network
    /// HTTP proxy configuration
    public var httpProxy: String?

    /// HTTPS proxy configuration
    public var httpsProxy: String?

    /// Comma-separated list of hosts to bypass proxy
    public var noProxy: String?

    // MARK: - Initialization

    public init(
        apiKey: String? = nil,
        authToken: String? = nil,
        customHeaders: String? = nil,
        model: String? = nil,
        defaultHaikuModel: String? = nil,
        defaultOpusModel: String? = nil,
        defaultSonnetModel: String? = nil,
        subagentModel: String? = nil,
        bashDefaultTimeout: Int? = nil,
        bashMaxOutputLength: Int? = nil,
        bashMaxTimeout: Int? = nil,
        disableTelemetry: Bool = false,
        disableErrorReporting: Bool = false,
        disableAutoUpdater: Bool = false,
        disablePromptCaching: Bool = false,
        maxThinkingTokens: Int? = nil,
        httpProxy: String? = nil,
        httpsProxy: String? = nil,
        noProxy: String? = nil
    ) {
        self.apiKey = apiKey
        self.authToken = authToken
        self.customHeaders = customHeaders
        self.model = model
        self.defaultHaikuModel = defaultHaikuModel
        self.defaultOpusModel = defaultOpusModel
        self.defaultSonnetModel = defaultSonnetModel
        self.subagentModel = subagentModel
        self.bashDefaultTimeout = bashDefaultTimeout
        self.bashMaxOutputLength = bashMaxOutputLength
        self.bashMaxTimeout = bashMaxTimeout
        self.disableTelemetry = disableTelemetry
        self.disableErrorReporting = disableErrorReporting
        self.disableAutoUpdater = disableAutoUpdater
        self.disablePromptCaching = disablePromptCaching
        self.maxThinkingTokens = maxThinkingTokens
        self.httpProxy = httpProxy
        self.httpsProxy = httpsProxy
        self.noProxy = noProxy
    }

    // MARK: - Environment Building

    /// Converts configuration to environment variables dictionary
    func buildEnvironment() -> [String: String] {
        var env: [String: String] = [:]

        if let apiKey = apiKey {
            env["ANTHROPIC_API_KEY"] = apiKey
        }

        if let authToken = authToken {
            env["ANTHROPIC_AUTH_TOKEN"] = authToken
        }

        if let customHeaders = customHeaders {
            env["ANTHROPIC_CUSTOM_HEADERS"] = customHeaders
        }

        if let model = model {
            env["ANTHROPIC_MODEL"] = model
        }

        if let defaultHaikuModel = defaultHaikuModel {
            env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = defaultHaikuModel
        }

        if let defaultOpusModel = defaultOpusModel {
            env["ANTHROPIC_DEFAULT_OPUS_MODEL"] = defaultOpusModel
        }

        if let defaultSonnetModel = defaultSonnetModel {
            env["ANTHROPIC_DEFAULT_SONNET_MODEL"] = defaultSonnetModel
        }

        if let subagentModel = subagentModel {
            env["CLAUDE_CODE_SUBAGENT_MODEL"] = subagentModel
        }

        if let bashDefaultTimeout = bashDefaultTimeout {
            env["BASH_DEFAULT_TIMEOUT_MS"] = String(bashDefaultTimeout)
        }

        if let bashMaxOutputLength = bashMaxOutputLength {
            env["BASH_MAX_OUTPUT_LENGTH"] = String(bashMaxOutputLength)
        }

        if let bashMaxTimeout = bashMaxTimeout {
            env["BASH_MAX_TIMEOUT_MS"] = String(bashMaxTimeout)
        }

        if disableTelemetry {
            env["DISABLE_TELEMETRY"] = "1"
        }

        if disableErrorReporting {
            env["DISABLE_ERROR_REPORTING"] = "1"
        }

        if disableAutoUpdater {
            env["DISABLE_AUTOUPDATER"] = "1"
        }

        if disablePromptCaching {
            env["DISABLE_PROMPT_CACHING"] = "1"
        }

        if let maxThinkingTokens = maxThinkingTokens {
            env["MAX_THINKING_TOKENS"] = String(maxThinkingTokens)
        }

        if let httpProxy = httpProxy {
            env["HTTP_PROXY"] = httpProxy
        }

        if let httpsProxy = httpsProxy {
            env["HTTPS_PROXY"] = httpsProxy
        }

        if let noProxy = noProxy {
            env["NO_PROXY"] = noProxy
        }

        return env
    }

    /// Merges with inherited environment variables
    func mergeWithInheritedEnvironment() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        let customEnv = buildEnvironment()

        for (key, value) in customEnv {
            env[key] = value
        }

        return env
    }
}

// MARK: - Builder Pattern

/// A builder for creating ClaudeEnvironment instances with a fluent API
public struct ClaudeEnvironmentBuilder {
    fileprivate var environment = ClaudeEnvironment()

    public init() {}

    // Authentication & API

    public func apiKey(_ key: String) -> Self {
        var builder = self
        builder.environment.apiKey = key
        return builder
    }

    public func authToken(_ token: String) -> Self {
        var builder = self
        builder.environment.authToken = token
        return builder
    }

    public func customHeaders(_ headers: String) -> Self {
        var builder = self
        builder.environment.customHeaders = headers
        return builder
    }

    // Model Configuration

    public func model(_ model: String) -> Self {
        var builder = self
        builder.environment.model = model
        return builder
    }

    public func defaultHaikuModel(_ model: String) -> Self {
        var builder = self
        builder.environment.defaultHaikuModel = model
        return builder
    }

    public func defaultOpusModel(_ model: String) -> Self {
        var builder = self
        builder.environment.defaultOpusModel = model
        return builder
    }

    public func defaultSonnetModel(_ model: String) -> Self {
        var builder = self
        builder.environment.defaultSonnetModel = model
        return builder
    }

    public func subagentModel(_ model: String) -> Self {
        var builder = self
        builder.environment.subagentModel = model
        return builder
    }

    // Bash & Command Execution

    public func bashDefaultTimeout(_ timeout: Int) -> Self {
        var builder = self
        builder.environment.bashDefaultTimeout = timeout
        return builder
    }

    public func bashMaxOutputLength(_ length: Int) -> Self {
        var builder = self
        builder.environment.bashMaxOutputLength = length
        return builder
    }

    public func bashMaxTimeout(_ timeout: Int) -> Self {
        var builder = self
        builder.environment.bashMaxTimeout = timeout
        return builder
    }

    // Feature Controls

    public func disableTelemetry(_ disable: Bool = true) -> Self {
        var builder = self
        builder.environment.disableTelemetry = disable
        return builder
    }

    public func disableErrorReporting(_ disable: Bool = true) -> Self {
        var builder = self
        builder.environment.disableErrorReporting = disable
        return builder
    }

    public func disableAutoUpdater(_ disable: Bool = true) -> Self {
        var builder = self
        builder.environment.disableAutoUpdater = disable
        return builder
    }

    public func disablePromptCaching(_ disable: Bool = true) -> Self {
        var builder = self
        builder.environment.disablePromptCaching = disable
        return builder
    }

    public func maxThinkingTokens(_ tokens: Int) -> Self {
        var builder = self
        builder.environment.maxThinkingTokens = tokens
        return builder
    }

    // Proxy & Network

    public func httpProxy(_ proxy: String) -> Self {
        var builder = self
        builder.environment.httpProxy = proxy
        return builder
    }

    public func httpsProxy(_ proxy: String) -> Self {
        var builder = self
        builder.environment.httpsProxy = proxy
        return builder
    }

    public func noProxy(_ hosts: String) -> Self {
        var builder = self
        builder.environment.noProxy = hosts
        return builder
    }

    public func build() -> ClaudeEnvironment {
        environment
    }
}

extension ClaudeEnvironment {
    /// Creates a new environment builder
    public static var builder: ClaudeEnvironmentBuilder {
        ClaudeEnvironmentBuilder()
    }

    /// Creates a builder from an existing environment
    public func toBuilder() -> ClaudeEnvironmentBuilder {
        var builder = ClaudeEnvironmentBuilder()
        builder.environment = self
        return builder
    }
}
