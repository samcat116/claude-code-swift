import Testing
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
