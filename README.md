# SlimLogger

SlimLogger is a small logging utility written entirely in Swift, without any dependencies to other libraries.
SlimLogger is deliberately designed to be as slim as possible. 
SlimLogger tries to be as lean as possible, but still flexible enough to fit the requirements for most projects.

##Features

  * **Easy installation** - If you only want console logging, you only need to add one file and one config file to your project.
  * **Easy usage** - No initialization needed, just make the logging calls.
  * **Easy configuration** - All config is done by changing static properties in a central config file.
  * **Log levels** - Log at different log levels
  * **Log filtering** - Enable logging from all your source files, or enable logging only for a single source file or a list of source files.
   This filtering is done in the central log config class, so you don't need to edit individual source files.
  * **Async, serial logging** - Logging is done asynchronously on a separate serial thread, making sure that log entries are printed in the correct
  order, without blocking the main thread.
  * **No unnecessary code execution** - Log messages are autoclosures, so code evaluations in the log messages are only executed if the loglevel
   matches the log level set in the config.
  * **Injectable log destinations** - Besides logging to the console, you can also inject your own custom log destination classes. 
  Just create a class that implements a single method in the `LogDestination` protocol. There is already a premade 
   [log destination class for logging to the cloud service Loggly](README-LogglyDestination.md).
  
##Installation

  * Add `SlimLogger.swift` and `SlimLoggerConfig.template` to your project
  * Rename `SlimLoggerConfig.template` to `SlimLoggerConfig.swift`
  
##Configuration

  * Edit `SlimLoggerConfig.swift`. (See instructions in the config file.)

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

