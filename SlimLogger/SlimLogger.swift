//
// Created by Mats Melke on 12/02/15.
// Copyright (c) 2015 Baresi. All rights reserved.
//

import Foundation


enum SourceFilesThatShouldLog {
    case All
    case None
    case EnabledSourceFiles([String])
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
        case trace:
            return "TRACE"
        case debug:
            return "DEBUG"
        case info:
            return "INFO "
        case warn:
            return "WARN "
        case error:
            return "ERROR"
        case fatal:
            return "FATAL"
        }
    }

}

public protocol LogDestination {
    func log<T>(@autoclosure message: () -> T, level:LogLevel,
        filename: String, line: Int)
}

private let slim = Slim()

public class Slim {

    var logDestinations: [LogDestination] = []
    var cleanedFilenamesCache:NSCache = NSCache()

    init() {
        if SlimConfig.enableConsoleLogging {
            logDestinations.append(ConsoleDestination())
        }
    }

    public class func addLogDestination(destination: LogDestination) {
        slim.logDestinations.append(destination)
    }

    public class func trace<T>(@autoclosure message: () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.trace, filename: filename, line: line)
    }

    public class func debug<T>(@autoclosure message: () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.debug, filename: filename, line: line)
    }

    public class func info<T>(@autoclosure message: () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.info, filename: filename, line: line)
    }

    public class func warn<T>(@autoclosure message: () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.warn, filename: filename, line: line)
    }

    public class func error<T>(@autoclosure message: () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.error, filename: filename, line: line)
    }

    public class func fatal<T>(@autoclosure message: () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message, level: LogLevel.fatal, filename: filename, line: line)
    }

    private func logInternal<T>(@autoclosure message: () -> T, level:LogLevel,
        filename: String, line: Int) {
        let cleanedfile = cleanedFilename(filename)
        if isSourceFileEnabled(cleanedfile) {
            for dest in logDestinations {
                dest.log(message, level: level, filename: cleanedfile, line: line)
            }
        }
    }

    private func cleanedFilename(filename:String) -> String {
        if let cleanedfile:String = cleanedFilenamesCache.objectForKey(filename) as? String {
            return cleanedfile
        } else {
            var retval = ""
            let items = filename.characters.split(allowEmptySlices: false, isSeparator:{$0=="/"}).map { String($0) }
            if items.count > 0 {
                retval = items.last!
            }
            cleanedFilenamesCache.setObject(retval, forKey:filename)
            return retval
        }
    }

    private func isSourceFileEnabled(cleanedFile:String) -> Bool {
        switch SlimConfig.sourceFilesThatShouldLog {
            case .All:
                return true
            case .None:
                return false
            case .EnabledSourceFiles(let enabledFiles):
                if enabledFiles.contains(cleanedFile) {
                    return true
                } else {
                    return false
                }
        }
    }
}

class ConsoleDestination: LogDestination {

    let dateFormatter = NSDateFormatter()
    let serialLogQueue = dispatch_queue_create("ConsoleDestinationQueue", DISPATCH_QUEUE_SERIAL)

    init() {
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
    }


    func log<T>(@autoclosure message: () -> T, level:LogLevel,
        filename: String, line: Int) {
        if level.rawValue >= SlimConfig.consoleLogLevel.rawValue {
            let msg = message()
            dispatch_async(self.serialLogQueue) {
                print("\(self.dateFormatter.stringFromDate(NSDate())):\(level.string):\(filename):\(line) - \(msg)")
            }
        }
    }
}

