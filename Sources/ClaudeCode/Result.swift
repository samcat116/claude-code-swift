import Foundation

/// Result from a Claude Code execution
public struct ClaudeResult: Sendable {
    /// The process exit code
    public let exitCode: Int32

    /// Standard output from the process
    public let output: String

    /// Standard error from the process
    public let error: String

    /// Whether the execution was successful (exit code 0)
    public var isSuccess: Bool {
        exitCode == 0
    }

    public init(exitCode: Int32, output: String, error: String) {
        self.exitCode = exitCode
        self.output = output
        self.error = error
    }
}

/// Errors that can occur during Claude Code execution
public enum ClaudeCodeError: Error, Sendable {
    /// The claude executable was not found
    case claudeNotFound

    /// The process execution failed
    case executionFailed(Int32, String)

    /// Invalid configuration provided
    case invalidConfiguration(String)

    /// Process was terminated
    case terminated

    /// Unknown error occurred
    case unknown(Error)
}

extension ClaudeCodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .claudeNotFound:
            return "Claude executable not found. Please ensure Claude Code is installed."
        case .executionFailed(let code, let message):
            return "Claude execution failed with exit code \(code): \(message)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .terminated:
            return "Process was terminated"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
