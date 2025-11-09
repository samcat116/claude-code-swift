import Foundation
import Subprocess

#if canImport(System)
import System
#else
import SystemPackage
#endif

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

    /// Environment configuration to use
    private var environment: ClaudeEnvironment?

    // MARK: - Initialization

    /// Creates a new Claude Code wrapper
    /// - Parameters:
    ///   - executablePath: Path to the claude executable. If nil, searches in PATH.
    ///   - defaultConfiguration: Default configuration to use for all executions
    ///   - environment: Optional environment configuration for Claude Code
    public init(
        executablePath: String? = nil,
        defaultConfiguration: ClaudeConfiguration = ClaudeConfiguration(),
        environment: ClaudeEnvironment? = nil
    ) {
        self.executablePath = executablePath ?? "claude"
        self.defaultConfiguration = defaultConfiguration
        self.environment = environment
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
            // Configure environment
            let environmentInput: Environment
            if let customEnv = self.environment {
                let envDict = customEnv.mergeWithInheritedEnvironment()
                let convertedDict: [Environment.Key: String] = Dictionary(
                    uniqueKeysWithValues: envDict.map { (Environment.Key(stringLiteral: $0.key), $0.value) }
                )
                environmentInput = .custom(convertedDict)
            } else {
                environmentInput = .inherit
            }

            // Configure working directory if provided
            let workingDir: FilePath? = workingDirectory.map { FilePath($0) }

            // Create configuration
            let config = Configuration(
                executable: .path(FilePath(executablePath)),
                arguments: Arguments(arguments),
                environment: environmentInput,
                workingDirectory: workingDir
            )

            // Run the process and collect output
            let result: CollectedResult<StringOutput<UTF8>, StringOutput<UTF8>>

            if let input = input {
                // Execute with input
                result = try await run(
                    config,
                    input: .string(input),
                    output: .string(limit: 10_000_000), // 10MB limit
                    error: .string(limit: 1_000_000)     // 1MB limit
                )
            } else {
                // Execute without input
                result = try await run(
                    config,
                    output: .string(limit: 10_000_000), // 10MB limit
                    error: .string(limit: 1_000_000)     // 1MB limit
                )
            }

            // Extract exit code
            let exitCode: Int32
            switch result.terminationStatus {
            case .exited(let code):
                exitCode = code
            case .unhandledException(_):
                throw ClaudeCodeError.terminated
            }

            return ClaudeResult(
                exitCode: exitCode,
                output: result.standardOutput ?? "",
                error: result.standardError ?? ""
            )

        } catch let error as ClaudeCodeError {
            throw error
        } catch {
            throw ClaudeCodeError.unknown(error)
        }
    }
}
