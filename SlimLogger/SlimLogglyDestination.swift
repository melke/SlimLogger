//
// Created by Mats Melke on 12/02/15.
// Copyright (c) 2015 Baresi. All rights reserved.
//

import Foundation
import UIKit

private let logglyQueue: DispatchQueue = DispatchQueue(label: "slimlogger.loggly")

class SlimLogglyDestination: LogDestination {

    var userid: String?
    fileprivate let dateFormatter = DateFormatter()
    fileprivate var buffer: [String] = []
    fileprivate var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    fileprivate lazy var standardFields: [String: String] = {
        var dict: [String: String] = [:]
        dict["lang"] = Locale.preferredLanguages[0]
        if let infodict = Bundle.main.infoDictionary {
            if let appname = infodict["CFBundleName"] as? String {
                dict["appname"] = appname
            }
            if let appname = infodict["CFBundleVersion"] as? String {
                dict["appversion"] = appname
            }
        }
        dict["devicename"] = UIDevice.current.name
        dict["devicemodel"] = UIDevice.current.model
        dict["osversion"] = UIDevice.current.systemVersion
        dict["sessionid"] = self.generateRandomNumberAsString()
        return dict
    }()

    fileprivate var observer: NSObjectProtocol?

    init() {
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UIApplicationWillResignActiveNotification"), object: nil, queue: nil, using: {
            [unowned self] note in
            let tmpbuffer = self.buffer
            self.buffer = [String]()
            self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "saveLogRecords",
                expirationHandler: {
                    self.endBackgroundTask()
                })
            self.sendLogsInBuffer(stringbuffer: tmpbuffer)
        })
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func toJson(dictionary: NSDictionary) -> Data? {
        var err: NSError?
        do {
            let json = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions(rawValue: 0))
            return json
        } catch let error1 as NSError {
            err = error1
            let error = err?.description ?? "nil"
            NSLog("ERROR: Unable to serialize json, error: %@", error)
            return nil
        }
    }

    private func toJsonString(data: Data) -> String {
        if let jsonstring = String(data: data, encoding: .utf8) {
            return jsonstring
        } else {
            return ""
        }
    }

    func generateRandomNumberAsString() -> String {
        return String(arc4random_uniform(999999))
    }

    func log<T>( _ message: @autoclosure () -> T, level: LogLevel, filename: String, line: Int) {
        if level.rawValue < SlimLogglyConfig.logglyLogLevel.rawValue {
            // don't log
            return
        }

        var jsonstr = ""
        let mutableDict: NSMutableDictionary = NSMutableDictionary()
        var messageIsaDictionary = false
        if let msgdict = message() as? [NSObject : AnyObject] {
            mutableDict.addEntries(from: msgdict)
            messageIsaDictionary = true
        }
        if !messageIsaDictionary {
            mutableDict.setObject("\(message())", forKey: "rawmsg" as NSCopying)
        }
        mutableDict.setObject(level.string, forKey: "level" as NSCopying)
        mutableDict.setObject(dateFormatter.string(from: Date()), forKey: "timestamp" as NSCopying)
        mutableDict.setObject("\(filename):\(line)", forKey: "sourcelocation" as NSCopying)
        mutableDict.addEntries(from: standardFields as [NSObject : AnyObject])
        if let user = self.userid {
            mutableDict.setObject(user, forKey: "userid" as NSCopying)
        }

        if let jsondata = toJson(dictionary: mutableDict) {
            jsonstr = toJsonString(data: jsondata)
        }
        addLogMsgToBuffer(msg: jsonstr)
    }

    private func addLogMsgToBuffer(msg: String) {
        logglyQueue.async {
            self.buffer.append(msg)
            if self.buffer.count > SlimLogglyConfig.maxEntriesInBuffer {
                let tmpbuffer = self.buffer
                self.buffer = [String]()
                self.sendLogsInBuffer(stringbuffer: tmpbuffer)
            }
        }
    }

    private func sendLogsInBuffer(stringbuffer: [String]) {
        let allMessagesString = stringbuffer.joined(separator: "\n")
        self.traceMessage(msg: "LOGGLY: will try to post \(allMessagesString)")
        if let url = URL(string: SlimLogglyConfig.logglyUrlString),
            let allMessagesData = allMessagesString.data(using: .utf8) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = allMessagesData
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: {(responsedata, response, error) in
                if let anError = error {
                    self.traceMessage(msg: "Error from Loggly: \(anError)")
                } else if let data = responsedata {
                    self.traceMessage(msg: "Posted to Loggly, status = \(String(data: data, encoding: .utf8) ?? "-")")
                } else {
                    self.traceMessage(msg: "Neither error nor responsedata, something's wrong")
                }
                if self.backgroundTaskIdentifier != UIBackgroundTaskInvalid {
                    self.endBackgroundTask()
                }
            })
            task.resume()
        }
    }

    private func endBackgroundTask() {
        if self.backgroundTaskIdentifier != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
            print("Ending background task")
        }
    }

    private func traceMessage(msg: String) {
        if SlimConfig.enableConsoleLogging && SlimLogglyConfig.logglyLogLevel == LogLevel.trace {
            print(msg)
        }
    }
}
