//
// Created by Mats Melke on 12/02/15.
// Copyright (c) 2015 Baresi. All rights reserved.
//

import Foundation
import UIKit

private let logglyQueue: dispatch_queue_t = dispatch_queue_create(
	"slimlogger.loggly", DISPATCH_QUEUE_SERIAL)

class SlimLogglyDestination: LogDestination {

    var userid:String?
    private let dateFormatter = NSDateFormatter()
    private var buffer:[String] = [String]()
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    private lazy var standardFields:NSDictionary = {
        let dict = NSMutableDictionary()
        if let lang = NSLocale.preferredLanguages()[0] as? String {
            dict["lang"] = lang
        }
        if let infodict = NSBundle.mainBundle().infoDictionary {
            if let appname = infodict["CFBundleName"] as? String {
                dict["appname"] = appname
            }
            if let appname = infodict["CFBundleVersion"] as? String {
                dict["appversion"] = appname
            }
        }
        dict["devicename"] = UIDevice.currentDevice().name
        dict["devicemodel"] = UIDevice.currentDevice().model
        dict["osversion"] = UIDevice.currentDevice().systemVersion
        dict["sessionid"] = self.generateRandomNumberAsString()
        return dict
    }()

    init() {
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        NSNotificationCenter.defaultCenter().addObserverForName("UIApplicationWillResignActiveNotification", object: nil, queue: nil, usingBlock: {
            [unowned self] note in
            let tmpbuffer = self.buffer
            self.buffer = [String]()
            self.backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithName("saveLogRecords",
                expirationHandler: {
                    self.endBackgroundTask()
                })
            self.sendLogsInBuffer(tmpbuffer)
        })
    }

    private func toJson(dictionary: NSDictionary) -> NSData? {

        var err: NSError?
        if let json = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions(0), error: &err) {
            return json
        } else {
            let error = err?.description ?? "nil"
            NSLog("ERROR: Unable to serialize json, error: %@", error)
//            NSNotificationCenter.defaultCenter().postNotificationName("CrashlyticsLogNotification", object: self, userInfo: ["string": "unable to serialize json, error: \(error)"])
//            abort()
            return nil
        }
    }

    private func toJsonString(data: NSData) -> String {
        if let jsonstring = NSString(data: data, encoding: NSUTF8StringEncoding) {
            return jsonstring as String
        } else {
            return ""
        }
    }


    func generateRandomNumberAsString() -> String {
        return String(arc4random_uniform(999999))
    }


    func log<T>(@autoclosure message:() -> T, level:LogLevel, filename:String, line:Int) {
        if level.rawValue < SlimLogglyConfig.logglyLogLevel.rawValue {
            // don't log
            return
        }

        var jsonstr = ""
        var mutableDict:NSMutableDictionary = NSMutableDictionary()
        var messageIsaDictionary = false
        if let msgdict = message() as? NSDictionary {
            if let nsmsgdict = msgdict as? [NSObject : AnyObject] {
                mutableDict.addEntriesFromDictionary(nsmsgdict)
                messageIsaDictionary = true
            }
        }
        if !messageIsaDictionary {
            mutableDict.setObject("\(message())", forKey: "rawmsg")
        }
        mutableDict.setObject(level.string, forKey: "level")
        mutableDict.setObject(dateFormatter.stringFromDate(NSDate()), forKey: "timestamp")
        mutableDict.setObject("\(filename):\(line)", forKey: "sourcelocation")
        mutableDict.addEntriesFromDictionary(standardFields as [NSObject : AnyObject])
        if let user = self.userid {
            mutableDict.setObject(user, forKey: "userid")
        }

        if let jsondata = toJson(mutableDict) {
            jsonstr = toJsonString(jsondata)
        }
        addLogMsgToBuffer(jsonstr)
    }

    private func addLogMsgToBuffer(msg:String) {
        dispatch_async(logglyQueue) {
            self.buffer.append(msg)
            if self.buffer.count > SlimLogglyConfig.maxEntriesInBuffer {
                let tmpbuffer = self.buffer
                self.buffer = [String]()
                self.sendLogsInBuffer(tmpbuffer)
            }
        }
    }

    private func sendLogsInBuffer(stringbuffer:[String]) {
        let allMessagesString = join("\n", stringbuffer)
        self.traceMessage("LOGGLY: will try to post \(allMessagesString)")
        if let allMessagesData = (allMessagesString as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
            var urlRequest = NSMutableURLRequest(URL: NSURL(string: SlimLogglyConfig.logglyUrlString)!)
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = allMessagesData
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue(), completionHandler: {
                (response: NSURLResponse!, responsedata: NSData!, error: NSError!) -> Void in
                if let anError = error {
                    // got an error from Loggly
                    self.traceMessage("Error from Loggly: \(anError)")
                } else {
                    self.traceMessage("Posted to Loggly, status = \(NSString(data: responsedata, encoding:NSUTF8StringEncoding))")
                }
                if self.backgroundTaskIdentifier != UIBackgroundTaskInvalid {
                    self.endBackgroundTask()
                }
            })
        }
    }

    private func endBackgroundTask() {
        if self.backgroundTaskIdentifier != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
            println("Ending background task")
        }
    }

    private func traceMessage(msg:String) {
        if SlimConfig.enableConsoleLogging && SlimLogglyConfig.logglyLogLevel == LogLevel.trace {
            println(msg)
        }
    }
}

