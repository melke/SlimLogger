struct SlimConfig {
    // Enable or disable console logging. When releasing your app, you should set this to false.
    static let enableConsoleLogging = true

    // Log level for console logging, can be set during runtime
    static var consoleLogLevel = LogLevel.trace

    // Either let all logging through, or specify a list of enabled source files.
    // So, either let all files log:
    static let sourceFilesThatShouldLog:SourceFilesThatShouldLog = .All
    // Or let specific files log:
    // static let sourceFilesThatShouldLog:SourceFilesThatShouldLog = .EnabledSourceFiles([
    //         "AppDelegate.swift",
    //         "AnotherSourceFile.swift"
    // ])
    // Or don't let any class log (use to turn off all logging to for all destinations):
    // static let sourceFilesThatShouldLog:SourceFilesThatShouldLog = .None
}
