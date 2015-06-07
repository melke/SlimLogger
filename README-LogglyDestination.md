# SlimLogger - Loggly Destination

The Loggly destination logs to the cloud service [Loggly](https://www.loggly.com/).

##Installation

  * Add SlimLogglyDestination.swift and SlimLogglyDestinationConfig.template to your project
  * Rename SlimLogglyDestinationConfig.template to SlimLogglyDestinationConfig.swift

##Configuration
  
  * Edit SlimLogglyDestinationConfig.swift and change the api key and app name in the Loggly URL. (See instructions in the config file)

##Usage

In `didFinishLaunchingWithOptions` in your app delegate, add the Loggly destination:

```swift
Slim.addLogDestination(SlimLogglyDestination())    
```
  
This is all there is to it. The log posts will include your log message plus some standard fields that the log destination adds automatically:

  - **level** - The log level
  - **timestamp** - Timestamp in iso8601 format (required by Loggly)
  - **sourcelocation** - Source file and line number in that file (nice for doing facet searches in Loggly)
  - **appname** - The name of your app
  - **appversion** - The version of your app
  - **devicemodel** - The device model
  - **devicename** - The device name
  - **lang** - The primary lang the app user has selected in Settings on the device
  - **osversion** - the iOS version
  - **rawmsg** - The log message that you sent, unparsed. This is also where simple non-JSON log messages will show up.
  - **sessionid** - A generated random id, to let you search in loggly for log statements from the same session.
  - **userid** - A userid string. Note, you must set this userid yourself in the SlimLogglyDestination object. No default value.

Note that if you log a type that can be casted to an NSDictionary, all dictionary keys will be logged as separate keys
to Loggly. This makes it much easier to do filtered field searches in Loggly. 
Word of warning, don't use too many different keys, it will make it harder to get a good overlook of your data 
in the Loggly UI. Figure out smart keys that you can reuse in many of your log statements.

##Tracking users

To track a specific user you can set the userid property on the SlimLogglyDestination object. The userid
will then be included in every log statement until the app is terminated by iOS.

Let's say that a user complains about having problems in your app. You can then search the Loggly UI for all log entries
that this user has created. You can also have some secret button in your app, and when the user taps this
button, you can set the log level to a finer level in SlimLogglyConfig. Now you can follow
the detailed logs in Loggly for this particular user, by filtering out all but this particular session.
Pretty nice, huh?

##Feedback and Contribution

All feedback and contribution is very appreciated. Please send pull requests, create issues
or just send an email to [mats.melke@gmail.com](mailto:mats.melke@gmail.com).

##License

* Copyright (c) 2015- Mats Melke. Please see LICENSE for details.
