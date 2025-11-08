import Foundation

/// Configuration options for Claude Code CLI execution
public struct ClaudeConfiguration: Sendable {
    /// The model to use for execution
    public enum Model: String, Sendable {
        case sonnet
        case opus
        case haiku
        case custom(String)

        var argumentValue: String {
            switch self {
            case .sonnet: return "sonnet"
            case .opus: return "opus"
            case .haiku: return "haiku"
            case .custom(let name): return name
            }
        }
    }

    /// Permission mode for tool execution
    public enum PermissionMode: String, Sendable {
        case allow
        case prompt
        case deny
    }

    /// Output format for the response
    public enum OutputFormat: String, Sendable {
        case text
        case json
        case streamJSON = "stream-json"
    }

    /// Input format for the request
    public enum InputFormat: String, Sendable {
        case text
        case streamJSON = "stream-json"
    }

    // MARK: - Properties

    /// The model to use
    public var model: Model?

    /// Tools that are pre-approved for use
    public var allowedTools: [String]?

    /// Tools that are prohibited from use
    public var disallowedTools: [String]?

    /// Whether to skip permission checks (use with caution)
    public var dangerouslySkipPermissions: Bool

    /// Initial permission mode
    public var permissionMode: PermissionMode?

    /// Custom system prompt to replace the default
    public var systemPrompt: String?

    /// Additional system prompt to append to the default
    public var appendSystemPrompt: String?

    /// Path to file containing system prompt (print mode only)
    public var systemPromptFile: String?

    /// Output format for responses
    public var outputFormat: OutputFormat

    /// Input format for requests
    public var inputFormat: InputFormat

    /// Include partial messages in streaming output
    public var includePartialMessages: Bool

    /// Enable verbose logging
    public var verbose: Bool

    /// Maximum number of agentic turns
    public var maxTurns: Int?

    /// Additional accessible working directories
    public var additionalDirectories: [String]

    /// Custom subagents definition (as JSON string)
    public var agents: String?

    /// MCP tool for permission handling
    public var permissionPromptTool: String?

    // MARK: - Initialization

    public init(
        model: Model? = nil,
        allowedTools: [String]? = nil,
        disallowedTools: [String]? = nil,
        dangerouslySkipPermissions: Bool = false,
        permissionMode: PermissionMode? = nil,
        systemPrompt: String? = nil,
        appendSystemPrompt: String? = nil,
        systemPromptFile: String? = nil,
        outputFormat: OutputFormat = .text,
        inputFormat: InputFormat = .text,
        includePartialMessages: Bool = false,
        verbose: Bool = false,
        maxTurns: Int? = nil,
        additionalDirectories: [String] = [],
        agents: String? = nil,
        permissionPromptTool: String? = nil
    ) {
        self.model = model
        self.allowedTools = allowedTools
        self.disallowedTools = disallowedTools
        self.dangerouslySkipPermissions = dangerouslySkipPermissions
        self.permissionMode = permissionMode
        self.systemPrompt = systemPrompt
        self.appendSystemPrompt = appendSystemPrompt
        self.systemPromptFile = systemPromptFile
        self.outputFormat = outputFormat
        self.inputFormat = inputFormat
        self.includePartialMessages = includePartialMessages
        self.verbose = verbose
        self.maxTurns = maxTurns
        self.additionalDirectories = additionalDirectories
        self.agents = agents
        self.permissionPromptTool = permissionPromptTool
    }

    // MARK: - Argument Building

    /// Converts configuration to CLI arguments
    func buildArguments() -> [String] {
        var args: [String] = []

        if let model = model {
            args.append("--model")
            args.append(model.argumentValue)
        }

        if let allowedTools = allowedTools, !allowedTools.isEmpty {
            args.append("--allowedTools")
            args.append(allowedTools.joined(separator: ","))
        }

        if let disallowedTools = disallowedTools, !disallowedTools.isEmpty {
            args.append("--disallowedTools")
            args.append(disallowedTools.joined(separator: ","))
        }

        if dangerouslySkipPermissions {
            args.append("--dangerously-skip-permissions")
        }

        if let permissionMode = permissionMode {
            args.append("--permission-mode")
            args.append(permissionMode.rawValue)
        }

        if let systemPrompt = systemPrompt {
            args.append("--system-prompt")
            args.append(systemPrompt)
        }

        if let appendSystemPrompt = appendSystemPrompt {
            args.append("--append-system-prompt")
            args.append(appendSystemPrompt)
        }

        if let systemPromptFile = systemPromptFile {
            args.append("--system-prompt-file")
            args.append(systemPromptFile)
        }

        if outputFormat != .text {
            args.append("--output-format")
            args.append(outputFormat.rawValue)
        }

        if inputFormat != .text {
            args.append("--input-format")
            args.append(inputFormat.rawValue)
        }

        if includePartialMessages {
            args.append("--include-partial-messages")
        }

        if verbose {
            args.append("--verbose")
        }

        if let maxTurns = maxTurns {
            args.append("--max-turns")
            args.append(String(maxTurns))
        }

        for directory in additionalDirectories {
            args.append("--add-dir")
            args.append(directory)
        }

        if let agents = agents {
            args.append("--agents")
            args.append(agents)
        }

        if let permissionPromptTool = permissionPromptTool {
            args.append("--permission-prompt-tool")
            args.append(permissionPromptTool)
        }

        return args
    }
}
