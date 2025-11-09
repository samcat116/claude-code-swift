import Testing
import Foundation
@testable import ClaudeCode

@Suite("ClaudeConfiguration Tests")
struct ClaudeConfigurationTests {

    @Test("Configuration builds arguments correctly")
    func testBasicArgumentBuilding() {
        var config = ClaudeConfiguration()
        config.model = .sonnet
        config.verbose = true
        config.maxTurns = 5

        let args = config.buildArguments()

        #expect(args.contains("--model"))
        #expect(args.contains("sonnet"))
        #expect(args.contains("--verbose"))
        #expect(args.contains("--max-turns"))
        #expect(args.contains("5"))
    }

    @Test("Default configuration produces minimal arguments")
    func testDefaultConfiguration() {
        let config = ClaudeConfiguration()
        let args = config.buildArguments()

        // Default config should not include output format (text is default)
        #expect(!args.contains("--output-format"))
        // Should not include other optional flags
        #expect(!args.contains("--model"))
        #expect(!args.contains("--verbose"))
    }

    @Test("Custom model configuration")
    func testCustomModel() {
        let config = ClaudeConfiguration.builder
            .model(.custom("claude-sonnet-4-20250514"))
            .build()

        let args = config.buildArguments()

        #expect(args.contains("--model"))
        #expect(args.contains("claude-sonnet-4-20250514"))
    }

    @Test("All models produce correct argument values")
    func testAllModelValues() {
        let models: [(ClaudeConfiguration.Model, String)] = [
            (.sonnet, "sonnet"),
            (.opus, "opus"),
            (.haiku, "haiku"),
            (.custom("test-model"), "test-model")
        ]

        for (model, expectedValue) in models {
            let config = ClaudeConfiguration.builder.model(model).build()
            let args = config.buildArguments()
            #expect(args.contains(expectedValue))
        }
    }

    @Test("Configuration with all options")
    func testComprehensiveConfiguration() {
        let config = ClaudeConfiguration.builder
            .model(.opus)
            .allowedTools(["Read", "Write", "Bash"])
            .disallowedTools(["Delete"])
            .dangerouslySkipPermissions()
            .permissionMode(.allow)
            .systemPrompt("Custom prompt")
            .appendSystemPrompt("Additional context")
            .outputFormat(.json)
            .inputFormat(.streamJSON)
            .includePartialMessages()
            .verbose()
            .maxTurns(10)
            .addDirectory("/path/one")
            .addDirectory("/path/two")
            .permissionPromptTool("myTool")
            .build()

        let args = config.buildArguments()

        // Verify all flags are present
        #expect(args.contains("--model"))
        #expect(args.contains("opus"))
        #expect(args.contains("--allowedTools"))
        #expect(args.contains("Read,Write,Bash"))
        #expect(args.contains("--disallowedTools"))
        #expect(args.contains("Delete"))
        #expect(args.contains("--dangerously-skip-permissions"))
        #expect(args.contains("--permission-mode"))
        #expect(args.contains("allow"))
        #expect(args.contains("--system-prompt"))
        #expect(args.contains("Custom prompt"))
        #expect(args.contains("--append-system-prompt"))
        #expect(args.contains("Additional context"))
        #expect(args.contains("--output-format"))
        #expect(args.contains("json"))
        #expect(args.contains("--input-format"))
        #expect(args.contains("stream-json"))
        #expect(args.contains("--include-partial-messages"))
        #expect(args.contains("--verbose"))
        #expect(args.contains("--max-turns"))
        #expect(args.contains("10"))
        #expect(args.contains("--add-dir"))
        #expect(args.contains("/path/one"))
        #expect(args.contains("/path/two"))
        #expect(args.contains("--permission-prompt-tool"))
        #expect(args.contains("myTool"))
    }

    @Test("Builder pattern works correctly")
    func testBuilderPattern() {
        let config = ClaudeConfiguration.builder
            .model(.opus)
            .verbose()
            .maxTurns(10)
            .allowedTools(["Read", "Write"])
            .build()

        #expect(config.model == .opus)
        #expect(config.verbose == true)
        #expect(config.maxTurns == 10)
        #expect(config.allowedTools == ["Read", "Write"])
    }

    @Test("JSON output format is configured correctly")
    func testJSONOutput() {
        let config = ClaudeConfiguration.builder
            .jsonOutput()
            .build()

        #expect(config.outputFormat == .json)

        let args = config.buildArguments()
        #expect(args.contains("--output-format"))
        #expect(args.contains("json"))
    }

    @Test("Permission mode is configured correctly")
    func testPermissionMode() {
        let config = ClaudeConfiguration.builder
            .permissionMode(.allow)
            .build()

        #expect(config.permissionMode == .allow)

        let args = config.buildArguments()
        #expect(args.contains("--permission-mode"))
        #expect(args.contains("allow"))
    }

    @Test("Additional directories are configured correctly")
    func testAdditionalDirectories() {
        let config = ClaudeConfiguration.builder
            .addDirectory("/path/one")
            .addDirectory("/path/two")
            .build()

        let args = config.buildArguments()

        // Should appear twice
        let addDirCount = args.filter { $0 == "--add-dir" }.count
        #expect(addDirCount == 2)
        #expect(args.contains("/path/one"))
        #expect(args.contains("/path/two"))
    }

    @Test("System prompt configuration")
    func testSystemPrompt() {
        let customPrompt = "You are a Swift expert"
        let config = ClaudeConfiguration.builder
            .systemPrompt(customPrompt)
            .build()

        #expect(config.systemPrompt == customPrompt)

        let args = config.buildArguments()
        #expect(args.contains("--system-prompt"))
        #expect(args.contains(customPrompt))
    }

    @Test("Append system prompt configuration")
    func testAppendSystemPrompt() {
        let appendPrompt = "Focus on Swift 6 features"
        let config = ClaudeConfiguration.builder
            .appendSystemPrompt(appendPrompt)
            .build()

        #expect(config.appendSystemPrompt == appendPrompt)

        let args = config.buildArguments()
        #expect(args.contains("--append-system-prompt"))
        #expect(args.contains(appendPrompt))
    }

    @Test("Allowed and disallowed tools configuration")
    func testToolPermissions() {
        let config = ClaudeConfiguration.builder
            .allowedTools(["Read", "Grep"])
            .disallowedTools(["Write", "Bash"])
            .build()

        let args = config.buildArguments()

        #expect(args.contains("--allowedTools"))
        #expect(args.contains("Read,Grep"))
        #expect(args.contains("--disallowedTools"))
        #expect(args.contains("Write,Bash"))
    }

    @Test("Dangerous skip permissions flag")
    func testDangerousSkipPermissions() {
        let config = ClaudeConfiguration.builder
            .dangerouslySkipPermissions()
            .build()

        #expect(config.dangerouslySkipPermissions == true)

        let args = config.buildArguments()
        #expect(args.contains("--dangerously-skip-permissions"))
    }

    @Test("Empty tool arrays don't produce arguments")
    func testEmptyToolArrays() {
        let config = ClaudeConfiguration.builder
            .allowedTools([])
            .disallowedTools([])
            .build()

        let args = config.buildArguments()

        #expect(!args.contains("--allowedTools"))
        #expect(!args.contains("--disallowedTools"))
    }

    @Test("Builder can be created from existing configuration")
    func testBuilderFromConfiguration() {
        let original = ClaudeConfiguration.builder
            .model(.sonnet)
            .verbose()
            .maxTurns(5)
            .build()

        let modified = original.toBuilder()
            .maxTurns(10)
            .build()

        #expect(modified.model == .sonnet)
        #expect(modified.verbose == true)
        #expect(modified.maxTurns == 10)
    }

    @Test("Stream JSON output format")
    func testStreamingJsonOutput() {
        let config = ClaudeConfiguration.builder
            .streamingJsonOutput()
            .build()

        #expect(config.outputFormat == .streamJSON)

        let args = config.buildArguments()
        #expect(args.contains("--output-format"))
        #expect(args.contains("stream-json"))
    }

    @Test("All permission modes")
    func testAllPermissionModes() {
        let modes: [(ClaudeConfiguration.PermissionMode, String)] = [
            (.allow, "allow"),
            (.prompt, "prompt"),
            (.deny, "deny")
        ]

        for (mode, expectedValue) in modes {
            let config = ClaudeConfiguration.builder
                .permissionMode(mode)
                .build()

            let args = config.buildArguments()
            #expect(args.contains("--permission-mode"))
            #expect(args.contains(expectedValue))
        }
    }

    @Test("System prompt file configuration")
    func testSystemPromptFile() {
        let config = ClaudeConfiguration.builder
            .systemPromptFile("/path/to/prompt.txt")
            .build()

        #expect(config.systemPromptFile == "/path/to/prompt.txt")

        let args = config.buildArguments()
        #expect(args.contains("--system-prompt-file"))
        #expect(args.contains("/path/to/prompt.txt"))
    }

    @Test("Agents JSON configuration")
    func testAgentsConfiguration() {
        let agentsJSON = """
        {"name": "test-agent", "tools": ["Read", "Write"]}
        """
        let config = ClaudeConfiguration.builder
            .agents(agentsJSON)
            .build()

        #expect(config.agents == agentsJSON)

        let args = config.buildArguments()
        #expect(args.contains("--agents"))
        #expect(args.contains(agentsJSON))
    }

    @Test("Configuration builder method chaining")
    func testBuilderChaining() {
        // This should compile and work correctly
        let config = ClaudeConfiguration.builder
            .model(.sonnet)
            .verbose()
            .maxTurns(5)
            .jsonOutput()
            .allowedTools(["Read"])
            .build()

        #expect(config.model == .sonnet)
        #expect(config.verbose == true)
        #expect(config.maxTurns == 5)
        #expect(config.outputFormat == .json)
        #expect(config.allowedTools == ["Read"])
    }

    @Test("Input format configuration")
    func testInputFormatConfiguration() {
        let textConfig = ClaudeConfiguration.builder
            .inputFormat(.text)
            .build()
        #expect(textConfig.inputFormat == .text)

        let streamJsonConfig = ClaudeConfiguration.builder
            .inputFormat(.streamJSON)
            .build()
        #expect(streamJsonConfig.inputFormat == .streamJSON)
    }
}

@Suite("ConfigurationBuilder Advanced Tests")
struct ConfigurationBuilderAdvancedTests {

    @Test("Builder preserves all set values")
    func testBuilderPreservesValues() {
        let config = ClaudeConfiguration.builder
            .model(.opus)
            .allowedTools(["Read", "Write", "Bash"])
            .disallowedTools(["Delete"])
            .dangerouslySkipPermissions(true)
            .permissionMode(.allow)
            .systemPrompt("Test prompt")
            .appendSystemPrompt("Additional")
            .systemPromptFile("/path/file.txt")
            .outputFormat(.json)
            .inputFormat(.streamJSON)
            .includePartialMessages(true)
            .verbose(true)
            .maxTurns(15)
            .additionalDirectories(["/path/one", "/path/two"])
            .agents("{}")
            .permissionPromptTool("tool1")
            .build()

        #expect(config.model == .opus)
        #expect(config.allowedTools == ["Read", "Write", "Bash"])
        #expect(config.disallowedTools == ["Delete"])
        #expect(config.dangerouslySkipPermissions == true)
        #expect(config.permissionMode == .allow)
        #expect(config.systemPrompt == "Test prompt")
        #expect(config.appendSystemPrompt == "Additional")
        #expect(config.systemPromptFile == "/path/file.txt")
        #expect(config.outputFormat == .json)
        #expect(config.inputFormat == .streamJSON)
        #expect(config.includePartialMessages == true)
        #expect(config.verbose == true)
        #expect(config.maxTurns == 15)
        #expect(config.additionalDirectories == ["/path/one", "/path/two"])
        #expect(config.agents == "{}")
        #expect(config.permissionPromptTool == "tool1")
    }

    @Test("Builder with false boolean values")
    func testBuilderWithFalseBooleans() {
        let config = ClaudeConfiguration.builder
            .dangerouslySkipPermissions(false)
            .verbose(false)
            .includePartialMessages(false)
            .build()

        #expect(config.dangerouslySkipPermissions == false)
        #expect(config.verbose == false)
        #expect(config.includePartialMessages == false)
    }

    @Test("Adding directories one by one")
    func testAddingDirectoriesSequentially() {
        let config = ClaudeConfiguration.builder
            .addDirectory("/first")
            .addDirectory("/second")
            .addDirectory("/third")
            .build()

        #expect(config.additionalDirectories.count == 3)
        #expect(config.additionalDirectories.contains("/first"))
        #expect(config.additionalDirectories.contains("/second"))
        #expect(config.additionalDirectories.contains("/third"))
    }

    @Test("Setting directories as array")
    func testSettingDirectoriesAsArray() {
        let dirs = ["/path/a", "/path/b", "/path/c"]
        let config = ClaudeConfiguration.builder
            .additionalDirectories(dirs)
            .build()

        #expect(config.additionalDirectories == dirs)
    }
}

@Suite("ClaudeResult Tests")
struct ClaudeResultTests {

    @Test("Result success detection")
    func testSuccessDetection() {
        let successResult = ClaudeResult(exitCode: 0, output: "Success", error: "")
        #expect(successResult.isSuccess == true)

        let failureResult = ClaudeResult(exitCode: 1, output: "", error: "Failed")
        #expect(failureResult.isSuccess == false)
    }

    @Test("Result get() method throws on failure")
    func testGetMethod() throws {
        let successResult = ClaudeResult(exitCode: 0, output: "Output", error: "")
        let output = try successResult.get()
        #expect(output == "Output")
    }

    @Test("Result get() method throws on error")
    func testGetMethodThrows() {
        let failureResult = ClaudeResult(exitCode: 1, output: "", error: "Error")

        #expect(throws: ClaudeCodeError.self) {
            try failureResult.get()
        }
    }

    @Test("Result with various exit codes")
    func testVariousExitCodes() {
        let codes: [Int32] = [0, 1, 2, 127, 255, -1]

        for code in codes {
            let result = ClaudeResult(exitCode: code, output: "test", error: "")
            if code == 0 {
                #expect(result.isSuccess == true)
            } else {
                #expect(result.isSuccess == false)
            }
        }
    }

    @Test("Result with both output and error")
    func testResultWithBothOutputAndError() {
        let result = ClaudeResult(
            exitCode: 1,
            output: "Some output",
            error: "Some error"
        )

        #expect(result.output == "Some output")
        #expect(result.error == "Some error")
        #expect(result.isSuccess == false)
    }

    @Test("Result decodeJSON with valid JSON")
    func testDecodeValidJSON() throws {
        struct TestData: Codable, Equatable {
            let message: String
            let count: Int
        }

        let jsonOutput = """
        {"message": "hello", "count": 42}
        """

        let result = ClaudeResult(exitCode: 0, output: jsonOutput, error: "")
        let decoded = try result.decodeJSON(TestData.self)

        #expect(decoded == TestData(message: "hello", count: 42))
    }

    @Test("Result decodeJSON with invalid JSON throws")
    func testDecodeInvalidJSON() {
        struct TestData: Codable {
            let message: String
        }

        let invalidJSON = "not valid json"
        let result = ClaudeResult(exitCode: 0, output: invalidJSON, error: "")

        #expect(throws: Error.self) {
            try result.decodeJSON(TestData.self)
        }
    }

    @Test("Result with empty strings")
    func testResultWithEmptyStrings() {
        let result = ClaudeResult(exitCode: 0, output: "", error: "")

        #expect(result.output.isEmpty)
        #expect(result.error.isEmpty)
        #expect(result.isSuccess)
    }

    @Test("Result with multiline output")
    func testResultWithMultilineOutput() {
        let multilineOutput = """
        Line 1
        Line 2
        Line 3
        """

        let result = ClaudeResult(exitCode: 0, output: multilineOutput, error: "")

        #expect(result.output.contains("Line 1"))
        #expect(result.output.contains("Line 2"))
        #expect(result.output.contains("Line 3"))
    }
}

@Suite("Error Handling Tests")
struct ErrorHandlingTests {

    @Test("ClaudeCodeError descriptions")
    func testErrorDescriptions() {
        let errors: [ClaudeCodeError] = [
            .claudeNotFound,
            .executionFailed(1, "Test error"),
            .invalidConfiguration("Bad config"),
            .terminated,
            .unknown(NSError(domain: "test", code: 0))
        ]

        for error in errors {
            let description = error.localizedDescription
            #expect(!description.isEmpty)
        }
    }

    @Test("ClaudeCodeError claudeNotFound message")
    func testClaudeNotFoundMessage() {
        let error = ClaudeCodeError.claudeNotFound
        let message = error.localizedDescription

        #expect(message.contains("Claude"))
        #expect(message.contains("not found"))
    }

    @Test("ClaudeCodeError executionFailed includes details")
    func testExecutionFailedMessage() {
        let error = ClaudeCodeError.executionFailed(42, "Custom error message")
        let message = error.localizedDescription

        #expect(message.contains("42"))
        #expect(message.contains("Custom error message"))
    }

    @Test("ClaudeCodeError invalidConfiguration includes message")
    func testInvalidConfigurationMessage() {
        let error = ClaudeCodeError.invalidConfiguration("Missing API key")
        let message = error.localizedDescription

        #expect(message.contains("Missing API key"))
    }

    @Test("ClaudeCodeError terminated message")
    func testTerminatedMessage() {
        let error = ClaudeCodeError.terminated
        let message = error.localizedDescription

        #expect(message.contains("terminated"))
    }

    @Test("Result get throws correct error type")
    func testResultGetThrowsCorrectError() {
        let result = ClaudeResult(exitCode: 5, output: "", error: "Test error")

        do {
            _ = try result.get()
            Issue.record("Should have thrown an error")
        } catch let error as ClaudeCodeError {
            if case .executionFailed(let code, let message) = error {
                #expect(code == 5)
                #expect(message == "Test error")
            } else {
                Issue.record("Wrong error type")
            }
        } catch {
            Issue.record("Unexpected error type")
        }
    }
}

@Suite("Model Tests")
struct ModelTests {

    @Test("Model argument values")
    func testModelArgumentValues() {
        #expect(ClaudeConfiguration.Model.sonnet.argumentValue == "sonnet")
        #expect(ClaudeConfiguration.Model.opus.argumentValue == "opus")
        #expect(ClaudeConfiguration.Model.haiku.argumentValue == "haiku")
    }
}

@Suite("ClaudeEnvironment Tests")
struct ClaudeEnvironmentTests {

    @Test("Environment builds variables correctly")
    func testBasicEnvironmentBuilding() {
        let env = ClaudeEnvironment(
            apiKey: "test-key",
            model: "claude-sonnet-4",
            disableTelemetry: true
        )

        let vars = env.buildEnvironment()

        #expect(vars["ANTHROPIC_API_KEY"] == "test-key")
        #expect(vars["ANTHROPIC_MODEL"] == "claude-sonnet-4")
        #expect(vars["DISABLE_TELEMETRY"] == "1")
    }

    @Test("Environment builder pattern works correctly")
    func testEnvironmentBuilder() {
        let env = ClaudeEnvironment.builder
            .apiKey("my-key")
            .model("claude-opus-4")
            .disableTelemetry()
            .bashDefaultTimeout(60000)
            .maxThinkingTokens(10000)
            .build()

        #expect(env.apiKey == "my-key")
        #expect(env.model == "claude-opus-4")
        #expect(env.disableTelemetry == true)
        #expect(env.bashDefaultTimeout == 60000)
        #expect(env.maxThinkingTokens == 10000)
    }

    @Test("Proxy configuration")
    func testProxyConfiguration() {
        let env = ClaudeEnvironment.builder
            .httpProxy("http://proxy.example.com:8080")
            .httpsProxy("https://proxy.example.com:8443")
            .noProxy("localhost,127.0.0.1")
            .build()

        let vars = env.buildEnvironment()

        #expect(vars["HTTP_PROXY"] == "http://proxy.example.com:8080")
        #expect(vars["HTTPS_PROXY"] == "https://proxy.example.com:8443")
        #expect(vars["NO_PROXY"] == "localhost,127.0.0.1")
    }

    @Test("Model defaults configuration")
    func testModelDefaults() {
        let env = ClaudeEnvironment.builder
            .defaultSonnetModel("claude-sonnet-4-20250514")
            .defaultOpusModel("claude-opus-4-20250514")
            .defaultHaikuModel("claude-haiku-4-20250514")
            .subagentModel("claude-haiku-4")
            .build()

        let vars = env.buildEnvironment()

        #expect(vars["ANTHROPIC_DEFAULT_SONNET_MODEL"] == "claude-sonnet-4-20250514")
        #expect(vars["ANTHROPIC_DEFAULT_OPUS_MODEL"] == "claude-opus-4-20250514")
        #expect(vars["ANTHROPIC_DEFAULT_HAIKU_MODEL"] == "claude-haiku-4-20250514")
        #expect(vars["CLAUDE_CODE_SUBAGENT_MODEL"] == "claude-haiku-4")
    }

    @Test("Bash execution configuration")
    func testBashConfiguration() {
        let env = ClaudeEnvironment.builder
            .bashDefaultTimeout(30000)
            .bashMaxOutputLength(100000)
            .bashMaxTimeout(120000)
            .build()

        let vars = env.buildEnvironment()

        #expect(vars["BASH_DEFAULT_TIMEOUT_MS"] == "30000")
        #expect(vars["BASH_MAX_OUTPUT_LENGTH"] == "100000")
        #expect(vars["BASH_MAX_TIMEOUT_MS"] == "120000")
    }

    @Test("Feature toggles configuration")
    func testFeatureToggles() {
        let env = ClaudeEnvironment.builder
            .disableTelemetry()
            .disableErrorReporting()
            .disableAutoUpdater()
            .disablePromptCaching()
            .build()

        let vars = env.buildEnvironment()

        #expect(vars["DISABLE_TELEMETRY"] == "1")
        #expect(vars["DISABLE_ERROR_REPORTING"] == "1")
        #expect(vars["DISABLE_AUTOUPDATER"] == "1")
        #expect(vars["DISABLE_PROMPT_CACHING"] == "1")
    }

    @Test("Authentication configuration")
    func testAuthenticationConfiguration() {
        let env = ClaudeEnvironment.builder
            .apiKey("test-api-key")
            .authToken("test-auth-token")
            .customHeaders("{\"X-Custom\": \"value\"}")
            .build()

        let vars = env.buildEnvironment()

        #expect(vars["ANTHROPIC_API_KEY"] == "test-api-key")
        #expect(vars["ANTHROPIC_AUTH_TOKEN"] == "test-auth-token")
        #expect(vars["ANTHROPIC_CUSTOM_HEADERS"] == "{\"X-Custom\": \"value\"}")
    }

    @Test("Extended thinking configuration")
    func testExtendedThinking() {
        let env = ClaudeEnvironment.builder
            .maxThinkingTokens(20000)
            .build()

        let vars = env.buildEnvironment()

        #expect(vars["MAX_THINKING_TOKENS"] == "20000")
    }

    @Test("Empty environment builds no variables")
    func testEmptyEnvironment() {
        let env = ClaudeEnvironment()
        let vars = env.buildEnvironment()

        #expect(vars.isEmpty)
    }

    @Test("Builder can be created from existing environment")
    func testBuilderFromEnvironment() {
        let original = ClaudeEnvironment.builder
            .apiKey("original-key")
            .disableTelemetry()
            .build()

        let modified = original.toBuilder()
            .apiKey("new-key")
            .disableErrorReporting()
            .build()

        #expect(modified.apiKey == "new-key")
        #expect(modified.disableTelemetry == true)
        #expect(modified.disableErrorReporting == true)
    }

    @Test("Environment with all options set")
    func testComprehensiveEnvironment() {
        let env = ClaudeEnvironment.builder
            .apiKey("test-key")
            .authToken("test-token")
            .customHeaders("{}")
            .model("claude-sonnet-4")
            .defaultHaikuModel("haiku-v1")
            .defaultOpusModel("opus-v1")
            .defaultSonnetModel("sonnet-v1")
            .subagentModel("haiku-v1")
            .bashDefaultTimeout(30000)
            .bashMaxOutputLength(50000)
            .bashMaxTimeout(60000)
            .disableTelemetry()
            .disableErrorReporting()
            .disableAutoUpdater()
            .disablePromptCaching()
            .maxThinkingTokens(15000)
            .httpProxy("http://proxy")
            .httpsProxy("https://proxy")
            .noProxy("localhost")
            .build()

        let vars = env.buildEnvironment()

        #expect(vars.count == 19) // All 19 environment variables should be set
        #expect(vars["ANTHROPIC_API_KEY"] == "test-key")
        #expect(vars["ANTHROPIC_AUTH_TOKEN"] == "test-token")
        #expect(vars["ANTHROPIC_CUSTOM_HEADERS"] == "{}")
        #expect(vars["ANTHROPIC_MODEL"] == "claude-sonnet-4")
        #expect(vars["MAX_THINKING_TOKENS"] == "15000")
    }

    @Test("Feature toggles with false values don't appear")
    func testFeatureTogglesWithFalse() {
        let env = ClaudeEnvironment.builder
            .disableTelemetry(false)
            .disableErrorReporting(false)
            .build()

        let vars = env.buildEnvironment()

        #expect(!vars.keys.contains("DISABLE_TELEMETRY"))
        #expect(!vars.keys.contains("DISABLE_ERROR_REPORTING"))
    }
}

@Suite("ClaudeCode Initialization Tests")
struct ClaudeCodeInitializationTests {

    @Test("Default initialization")
    func testDefaultInitialization() async {
        let claude = ClaudeCode()
        // Should not crash and should use defaults
        #expect(true) // If we got here, initialization succeeded
    }

    @Test("Custom executable path initialization")
    func testCustomExecutablePath() async {
        let claude = ClaudeCode(executablePath: "/custom/path/to/claude")
        // Should not crash
        #expect(true)
    }

    @Test("Initialization with default configuration")
    func testInitializationWithDefaultConfiguration() async {
        let config = ClaudeConfiguration.builder
            .model(.sonnet)
            .verbose()
            .build()

        let claude = ClaudeCode(defaultConfiguration: config)
        #expect(true)
    }

    @Test("Initialization with environment")
    func testInitializationWithEnvironment() async {
        let env = ClaudeEnvironment.builder
            .apiKey("test-key")
            .disableTelemetry()
            .build()

        let claude = ClaudeCode(environment: env)
        #expect(true)
    }

    @Test("Initialization with all parameters")
    func testInitializationWithAllParameters() async {
        let config = ClaudeConfiguration.builder.verbose().build()
        let env = ClaudeEnvironment.builder.disableTelemetry().build()

        let claude = ClaudeCode(
            executablePath: "/custom/claude",
            defaultConfiguration: config,
            environment: env
        )
        #expect(true)
    }
}

@Suite("Edge Case Tests")
struct EdgeCaseTests {

    @Test("Configuration with special characters in strings")
    func testSpecialCharactersInConfiguration() {
        let config = ClaudeConfiguration.builder
            .systemPrompt("Test with \"quotes\" and 'apostrophes'")
            .appendSystemPrompt("Line 1\nLine 2\nLine 3")
            .build()

        let args = config.buildArguments()
        #expect(args.contains("--system-prompt"))
        #expect(args.contains("Test with \"quotes\" and 'apostrophes'"))
    }

    @Test("Configuration with very long strings")
    func testVeryLongStrings() {
        let longString = String(repeating: "a", count: 10000)
        let config = ClaudeConfiguration.builder
            .systemPrompt(longString)
            .build()

        #expect(config.systemPrompt?.count == 10000)
    }

    @Test("Configuration with empty arrays")
    func testEmptyArrays() {
        let config = ClaudeConfiguration(
            allowedTools: [],
            disallowedTools: [],
            additionalDirectories: []
        )

        let args = config.buildArguments()
        #expect(!args.contains("--allowedTools"))
        #expect(!args.contains("--disallowedTools"))
    }

    @Test("Environment with special characters")
    func testEnvironmentWithSpecialCharacters() {
        let env = ClaudeEnvironment.builder
            .customHeaders("{\"key\": \"value with spaces\"}")
            .noProxy("localhost,*.example.com,192.168.*.*")
            .build()

        let vars = env.buildEnvironment()
        #expect(vars["ANTHROPIC_CUSTOM_HEADERS"] == "{\"key\": \"value with spaces\"}")
        #expect(vars["NO_PROXY"] == "localhost,*.example.com,192.168.*.*")
    }

    @Test("Result with very large output")
    func testResultWithLargeOutput() {
        let largeOutput = String(repeating: "x", count: 1_000_000)
        let result = ClaudeResult(exitCode: 0, output: largeOutput, error: "")

        #expect(result.output.count == 1_000_000)
        #expect(result.isSuccess)
    }

    @Test("Result with Unicode characters")
    func testResultWithUnicode() {
        let unicodeOutput = "Hello 世界 🌍 émojis and spëcial çharacters"
        let result = ClaudeResult(exitCode: 0, output: unicodeOutput, error: "")

        #expect(result.output == unicodeOutput)
    }

    @Test("Configuration with nil optional values")
    func testConfigurationWithNilValues() {
        let config = ClaudeConfiguration(
            model: nil,
            allowedTools: nil,
            disallowedTools: nil,
            systemPrompt: nil,
            maxTurns: nil
        )

        let args = config.buildArguments()
        #expect(!args.contains("--model"))
        #expect(!args.contains("--allowedTools"))
        #expect(!args.contains("--max-turns"))
    }

    @Test("Multiple directories with same path")
    func testDuplicateDirectories() {
        let config = ClaudeConfiguration.builder
            .addDirectory("/same/path")
            .addDirectory("/same/path")
            .addDirectory("/same/path")
            .build()

        let args = config.buildArguments()
        let dirCount = args.filter { $0 == "--add-dir" }.count
        #expect(dirCount == 3) // Should allow duplicates
    }

    @Test("Zero max turns")
    func testZeroMaxTurns() {
        let config = ClaudeConfiguration.builder
            .maxTurns(0)
            .build()

        let args = config.buildArguments()
        #expect(args.contains("--max-turns"))
        #expect(args.contains("0"))
    }

    @Test("Negative timeout values")
    func testNegativeTimeouts() {
        let env = ClaudeEnvironment.builder
            .bashDefaultTimeout(-1)
            .build()

        let vars = env.buildEnvironment()
        #expect(vars["BASH_DEFAULT_TIMEOUT_MS"] == "-1")
    }
}

@Suite("Integration Between Components Tests")
struct ComponentIntegrationTests {

    @Test("Configuration and environment work together")
    func testConfigurationAndEnvironmentTogether() {
        let config = ClaudeConfiguration.builder
            .model(.sonnet)
            .verbose()
            .build()

        let env = ClaudeEnvironment.builder
            .apiKey("test-key")
            .disableTelemetry()
            .build()

        // Both should be independently valid
        let configArgs = config.buildArguments()
        let envVars = env.buildEnvironment()

        #expect(configArgs.contains("--model"))
        #expect(envVars["ANTHROPIC_API_KEY"] == "test-key")
    }

    @Test("Builder pattern maintains immutability")
    func testBuilderImmutability() {
        let builder = ClaudeConfiguration.builder
        let config1 = builder.model(.sonnet).build()
        let config2 = builder.model(.opus).build()

        // Each build should produce independent configurations
        #expect(config1.model == .sonnet)
        #expect(config2.model == .opus)
    }

    @Test("Environment builder maintains immutability")
    func testEnvironmentBuilderImmutability() {
        let builder = ClaudeEnvironment.builder
        let env1 = builder.apiKey("key1").build()
        let env2 = builder.apiKey("key2").build()

        #expect(env1.apiKey == "key1")
        #expect(env2.apiKey == "key2")
    }
}

// Note: Integration tests that actually execute the claude CLI would go here
// but are commented out since they require the CLI to be installed and configured

/*
@Suite("Integration Tests", .disabled("Requires Claude CLI installation"))
struct IntegrationTests {

    @Test("Basic execution works")
    func testBasicExecution() async throws {
        let claude = ClaudeCode()
        let result = try await claude.execute(prompt: "Say hello in one word")

        #expect(result.isSuccess)
        #expect(!result.output.isEmpty)
    }

    @Test("Configuration is applied")
    func testConfigurationApplication() async throws {
        let claude = ClaudeCode()
        let config = ClaudeConfiguration.builder
            .verbose()
            .maxTurns(1)
            .build()

        let result = try await claude.execute(
            prompt: "What is 2+2?",
            configuration: config
        )

        #expect(result.isSuccess)
    }
}
*/
