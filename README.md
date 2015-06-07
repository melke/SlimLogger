# SlimLogger

SlimLogger is a small logging utility written entirely in Swift, without any dependencies to other libraries.
SlimLogger is deliberately designed to be as slim as possible. 
SlimLogger tries to be as lean as possible, but still flexible enough to fit the requirements for most projects.

##Features

  * **Log levels** - Log at different log levels. Log levels are set by log destination, not by class.
  * **Log filtering** - Enable logging from all your source files, or enable logging only for a list of source files.
   This filtering is done in the central log config class, so you don't need to edit individual source files.
  * **Log formatting** - The console log destination will log timestamp, level, source filename, line number and the message.
  * **Injectable log destinations** - Besides logging to the console, you can also inject your own custom log destination classes. 
  Just create a class that implements a single method in the `LogDestination` protocol. There is already a premade 
   [log destination class for logging to the cloud service Loggly](README-LogglyDestination.md).
  * **Async, serial logging** - Logging is done asynchronously on a separate serial thread, making sure that log entries are printed in the correct
  order, without blocking the main thread.
  
##Installation

  * Add `SlimLogger.swift` and `SlimLoggerConfig.template` to your project
  * Rename `SlimLoggerConfig.template` to `SlimLoggerConfig.swift`
  
##Configuration

Edit the SlimConfig struct in `SlimLoggerConfig.swift`
 
```swift
struct SlimConfig {
    // Enable or disable console logging. When releasing your app, you should set this to false.
    static let enableConsoleLogging = true

    // Log level for console logging, can be set during runtime
    static var consoleLogLevel = LogLevel.trace

    // Either let all logging through, or specify a list of enabled source files.
    // So, either let all files log:
    static let sourceFilesThatShouldLog:SourceFilesThatShouldLog = .All
    // Or let specific files log:
    static let sourceFilesThatShouldLog:SourceFilesThatShouldLog = .EnabledSourceFiles([
             "AppDelegate.swift",
             "AnotherSourceFile.swift"
    ])
    // Or don't let any class log (use to turn off all logging to for all destinations):
    static let sourceFilesThatShouldLog:SourceFilesThatShouldLog = .None
} 
```

##Usage

```swift
Slim.trace("message")    
Slim.debug("message")    
Slim.info("message")    
Slim.warn("message")    
Slim.error("message")    
Slim.fatal("message")    
```

##Feedback and Contribution

All feedback and contribution is very appreciated. For example, contribute with a new log destination class! 
Please send pull requests, create issues
or just send an email to [mats.melke@gmail.com](mailto:mats.melke@gmail.com).

##License

* Copyright (c) 2015- Mats Melke. Please see LICENSE for details.

