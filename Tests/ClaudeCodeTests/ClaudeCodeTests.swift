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
