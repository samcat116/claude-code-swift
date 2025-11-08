import Foundation

// MARK: - Convenience Extensions

extension ClaudeCode {
    /// Quick execute with string prompt and optional model
    public func execute(
        _ prompt: String,
        model: ClaudeConfiguration.Model? = nil
    ) async throws -> ClaudeResult {
        var config = ClaudeConfiguration()
        config.model = model
        return try await execute(prompt: prompt, configuration: config)
    }

    /// Execute with file input
    public func executeWithFile(
        prompt: String,
        inputFile: String,
        configuration: ClaudeConfiguration? = nil
    ) async throws -> ClaudeResult {
        let fileContent = try String(contentsOfFile: inputFile)
        return try await execute(
            prompt: prompt,
            input: fileContent,
            configuration: configuration
        )
    }

    /// Execute and decode JSON response
    public func executeJSON<T: Decodable>(
        prompt: String,
        configuration: ClaudeConfiguration? = nil,
        workingDirectory: String? = nil
    ) async throws -> T {
        var config = configuration ?? ClaudeConfiguration()
        config.outputFormat = .json

        let result = try await execute(
            prompt: prompt,
            configuration: config,
            workingDirectory: workingDirectory
        )

        guard result.isSuccess else {
            throw ClaudeCodeError.executionFailed(result.exitCode, result.error)
        }

        let data = result.output.data(using: .utf8) ?? Data()
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Result Extensions

extension ClaudeResult {
    /// Returns output if successful, throws error otherwise
    public func get() throws -> String {
        guard isSuccess else {
            throw ClaudeCodeError.executionFailed(exitCode, error)
        }
        return output
    }

    /// Decodes JSON output
    public func decodeJSON<T: Decodable>(_ type: T.Type) throws -> T {
        let data = output.data(using: .utf8) ?? Data()
        return try JSONDecoder().decode(type, from: data)
    }
}
