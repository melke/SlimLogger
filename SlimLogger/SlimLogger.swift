//
// Created by Mats Melke on 12/02/15.
// Copyright (c) 2015 Baresi. All rights reserved.
//

import Foundation

enum SourceFilesThatShouldLog {
    case all
    case none
    case enabledSourceFiles([String])
}

public enum LogLevel: Int {
    case trace  = 100
    case debug  = 200
    case info   = 300
    case warn   = 400
    case error  = 500
    case fatal  = 600

    var string:String {
        switch self {
        case .trace:
            return "TRACE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO "
        case .warn:
            return "WARN "
        case .error:
            return "ERROR"
        case .fatal:
            return "FATAL"
        }
    }
}

public protocol LogDestination {
    func log<T>( _ message: @autoclosure () -> T, level: LogLevel, filename: String, line: Int)
}

private let slim = Slim()

open class Slim {

    var logDestinations: [LogDestination] = []
    var cleanedFilenamesCache: NSCache<AnyObject, AnyObject> = NSCache()

    init() {
        if SlimConfig.enableConsoleLogging {
            logDestinations.append(ConsoleDestination())
        }
    }

    open class func addLogDestination(_ destination: LogDestination) {
        slim.logDestinations.append(destination)
    }

    open class func trace<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.trace, filename: filename, line: line)
    }

    open class func debug<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.debug, filename: filename, line: line)
    }

    open class func info<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.info, filename: filename, line: line)
    }

    open class func warn<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.warn, filename: filename, line: line)
    }

    open class func error<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.error, filename: filename, line: line)
    }

    open class func fatal<T>( _ message: @autoclosure () -> T, filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.fatal, filename: filename, line: line)
    }

    fileprivate func logInternal<T>( _ message: @autoclosure () -> T, level: LogLevel, filename: String, line: Int) {
        let cleanedfile = cleanedFilename(filename)
        if isSourceFileEnabled(cleanedfile) {
            for dest in logDestinations {
                dest.log(message, level: level, filename: cleanedfile, line: line)
            }
        }
    }

    fileprivate func cleanedFilename(_ filename: String) -> String {
        if let cleanedfile:String = cleanedFilenamesCache.object(forKey: filename as AnyObject) as? String {
            return cleanedfile
        } else {
            var retval = ""
            let items = filename.split{$0 == "/"}.map(String.init)
            
            if items.count > 0 {
                retval = items.last!
            }
            cleanedFilenamesCache.setObject(retval as AnyObject, forKey: filename as AnyObject)
            return retval
        }
    }

    fileprivate func isSourceFileEnabled(_ cleanedFile: String) -> Bool {
        switch SlimConfig.sourceFilesThatShouldLog {
        case .all:
            return true
        case .none:
            return false
        case .enabledSourceFiles(let enabledFiles):
            if enabledFiles.contains(cleanedFile) {
                return true
            } else {
                return false
            }
        }
    }
}

class ConsoleDestination: LogDestination {

    let dateFormatter = DateFormatter()
    let serialLogQueue: DispatchQueue = DispatchQueue(label: "ConsoleDestinationQueue")

    init() {
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
    }

    func log<T>( _ message: @autoclosure () -> T, level: LogLevel, filename: String, line: Int) {
        if level.rawValue >= SlimConfig.consoleLogLevel.rawValue {
            let msg = message()
            self.serialLogQueue.async {
                print("\(self.dateFormatter.string(from: Date())):\(level.string):\(filename):\(line) - \(msg)")
            }
        }
    }
}
