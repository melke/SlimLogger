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
    func log<T>( message: @autoclosure () -> T, level:LogLevel,
        filename: String, line: Int)
}

private let slim = Slim()

public class Slim {

    var logDestinations: [LogDestination] = []
    var cleanedFilenamesCache:NSCache<AnyObject,AnyObject> = NSCache<AnyObject,AnyObject>()

    init() {
        if SlimConfig.enableConsoleLogging {
            logDestinations.append(ConsoleDestination())
        }
    }

    public class func addLogDestination(destination: LogDestination) {
        slim.logDestinations.append(destination)
    }

    public class func trace<T>( message: @autoclosure () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message: message, level: LogLevel.trace, filename: filename, line: line)
    }

    public class func debug<T>( message: @autoclosure () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message: message, level: LogLevel.debug, filename: filename, line: line)
    }

    public class func info<T>( message: @autoclosure () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message: message, level: LogLevel.info, filename: filename, line: line)
    }

    public class func warn<T>( message: @autoclosure () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message: message, level: LogLevel.warn, filename: filename, line: line)
    }

    public class func error<T>( message: @autoclosure () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message: message, level: LogLevel.error, filename: filename, line: line)
    }

    public class func fatal<T>( message: @autoclosure () -> T,
        filename: String = #file, line: Int = #line) {
        slim.logInternal(message: message, level: LogLevel.fatal, filename: filename, line: line)
    }

    private func logInternal<T>( message: @autoclosure () -> T, level:LogLevel,
        filename: String, line: Int) {
        let cleanedfile = cleanedFilename(filename: filename)
        if isSourceFileEnabled(cleanedFile: cleanedfile) {
            for dest in logDestinations {
                dest.log(message: message, level: level, filename: cleanedfile, line: line)
            }
        }
    }

    private func cleanedFilename(filename:String) -> String {
        if let cleanedfile:String = cleanedFilenamesCache.object(forKey:filename as AnyObject) as? String {
            return cleanedfile
        } else {
            var retval = ""
            let items = filename.characters.split{$0 == "/"}.map(String.init)
            
            
            if items.count > 0 {
                retval = items.last!
            }
            cleanedFilenamesCache.setObject(retval as AnyObject, forKey:filename as AnyObject)
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

    let dateFormatter = DateFormatter()
    let serialLogQueue: DispatchQueue = DispatchQueue(label: "ConsoleDestinationQueue")

    init() {
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
    }


    func log<T>( message: @autoclosure () -> T, level:LogLevel,
        filename: String, line: Int) {
        if level.rawValue >= SlimConfig.consoleLogLevel.rawValue {
            let msg = message()
            self.serialLogQueue.async {
                print("\(self.dateFormatter.string(from: NSDate() as Date)):\(level.string):\(filename):\(line) - \(msg)")
            }
        }
    }
}

