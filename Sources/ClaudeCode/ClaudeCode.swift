import Foundation
import Subprocess

/// A Swift wrapper for the Claude Code CLI
///
/// This class provides a type-safe, Swift-native interface for interacting with
/// the Claude Code command-line tool using the swift-subprocess library.
///
/// Example usage:
/// ```swift
/// let claude = ClaudeCode()
///
/// // Execute a simple prompt
/// let result = try await claude.execute(prompt: "What is 2+2?")
/// print(result.output)
///
/// // Execute with configuration
/// var config = ClaudeConfiguration()
/// config.model = .sonnet
/// config.maxTurns = 5
/// let result = try await claude.execute(
///     prompt: "Analyze this code",
///     configuration: config
/// )
/// ```
public actor ClaudeCode {

    // MARK: - Properties

    /// Path to the claude executable
    private let executablePath: String

    /// Default configuration to use
    private var defaultConfiguration: ClaudeConfiguration

    // MARK: - Initialization

    /// Creates a new Claude Code wrapper
    /// - Parameters:
    ///   - executablePath: Path to the claude executable. If nil, searches in PATH.
    ///   - defaultConfiguration: Default configuration to use for all executions
    public init(
        executablePath: String? = nil,
        defaultConfiguration: ClaudeConfiguration = ClaudeConfiguration()
    ) {
        self.executablePath = executablePath ?? "claude"
        self.defaultConfiguration = defaultConfiguration
    }

    // MARK: - Public Methods

    /// Executes a prompt using Claude Code in print mode
    /// - Parameters:
    ///   - prompt: The prompt to send to Claude
    ///   - configuration: Optional configuration to override defaults
    ///   - workingDirectory: Working directory for the process
    /// - Returns: The result of the execution
    /// - Throws: ClaudeCodeError if execution fails
    public func execute(
        prompt: String,
        configuration: ClaudeConfiguration? = nil,
        workingDirectory: String? = nil
    ) async throws -> ClaudeResult {
        let config = configuration ?? defaultConfiguration
        var arguments = config.buildArguments()
        arguments.append("-p")
        arguments.append(prompt)

        return try await runProcess(arguments: arguments, workingDirectory: workingDirectory)
    }

    /// Executes a prompt with piped input
    /// - Parameters:
    ///   - prompt: The prompt to send to Claude
    ///   - input: The input to pipe to the process
    ///   - configuration: Optional configuration to override defaults
    ///   - workingDirectory: Working directory for the process
    /// - Returns: The result of the execution
    /// - Throws: ClaudeCodeError if execution fails
    public func execute(
        prompt: String,
        input: String,
        configuration: ClaudeConfiguration? = nil,
        workingDirectory: String? = nil
    ) async throws -> ClaudeResult {
        let config = configuration ?? defaultConfiguration
        var arguments = config.buildArguments()
        arguments.append("-p")
        arguments.append(prompt)

        return try await runProcess(
            arguments: arguments,
            input: input,
            workingDirectory: workingDirectory
        )
    }

    /// Continues the most recent session
    /// - Parameters:
    ///   - prompt: Optional prompt to send
    ///   - configuration: Optional configuration to override defaults
    ///   - workingDirectory: Working directory for the process
    /// - Returns: The result of the execution
    /// - Throws: ClaudeCodeError if execution fails
    public func continueSession(
        prompt: String? = nil,
        configuration: ClaudeConfiguration? = nil,
        workingDirectory: String? = nil
    ) async throws -> ClaudeResult {
        let config = configuration ?? defaultConfiguration
        var arguments = config.buildArguments()
        arguments.append("-c")

        if let prompt = prompt {
            arguments.append(prompt)
        }

        return try await runProcess(arguments: arguments, workingDirectory: workingDirectory)
    }

    /// Resumes a specific session by ID
    /// - Parameters:
    ///   - sessionId: The session ID to resume
    ///   - prompt: Optional prompt to send
    ///   - configuration: Optional configuration to override defaults
    ///   - workingDirectory: Working directory for the process
    /// - Returns: The result of the execution
    /// - Throws: ClaudeCodeError if execution fails
    public func resumeSession(
        sessionId: String,
        prompt: String? = nil,
        configuration: ClaudeConfiguration? = nil,
        workingDirectory: String? = nil
    ) async throws -> ClaudeResult {
        let config = configuration ?? defaultConfiguration
        var arguments = config.buildArguments()
        arguments.append("-r")
        arguments.append(sessionId)

        if let prompt = prompt {
            arguments.append(prompt)
        }

        return try await runProcess(arguments: arguments, workingDirectory: workingDirectory)
    }

    /// Updates Claude Code to the latest version
    /// - Returns: The result of the update command
    /// - Throws: ClaudeCodeError if execution fails
    public func update() async throws -> ClaudeResult {
        try await runProcess(arguments: ["update"])
    }

    /// Configures MCP (Model Context Protocol) servers
    /// - Returns: The result of the MCP configuration
    /// - Throws: ClaudeCodeError if execution fails
    public func configureMCP() async throws -> ClaudeResult {
        try await runProcess(arguments: ["mcp"])
    }

    // MARK: - Private Methods

    /// Runs the claude process with the given arguments
    private func runProcess(
        arguments: [String],
        input: String? = nil,
        workingDirectory: String? = nil
    ) async throws -> ClaudeResult {
        do {
            // Build the executable configuration
            var executable = Executable.named(executablePath)

            // Configure arguments
            let args = ExecutionInput.arguments(arguments)

            // Configure working directory if provided
            let environment = ExecutionInput.environment(.inherit)

            var workingDir: ExecutionInput.WorkingDirectory = .inherit
            if let workingDirectory = workingDirectory {
                workingDir = .path(workingDirectory)
            }

            // Run the process and collect output
            let result: CollectedResult<String, String>

            if let input = input {
                // Execute with input
                result = try await run(
                    executable,
                    args,
                    environment,
                    workingDir,
                    input: .string(input),
                    output: .string(limit: 10_000_000), // 10MB limit
                    error: .string(limit: 1_000_000)     // 1MB limit
                )
            } else {
                // Execute without input
                result = try await run(
                    executable,
                    args,
                    environment,
                    workingDir,
                    output: .string(limit: 10_000_000), // 10MB limit
                    error: .string(limit: 1_000_000)     // 1MB limit
                )
            }

            // Extract exit code
            let exitCode: Int32
            switch result.terminationStatus {
            case .exit(let code):
                exitCode = code
            case .signal(let signal):
                throw ClaudeCodeError.terminated
            case .abnormal:
                throw ClaudeCodeError.terminated
            }

            return ClaudeResult(
                exitCode: exitCode,
                output: result.standardOutput,
                error: result.standardError
            )

        } catch let error as ClaudeCodeError {
            throw error
        } catch {
            throw ClaudeCodeError.unknown(error)
        }
    }
}
