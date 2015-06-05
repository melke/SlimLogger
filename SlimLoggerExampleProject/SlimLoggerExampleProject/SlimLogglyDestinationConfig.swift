struct SlimLogglyConfig {

// Replace your-loggly-api-key below with a "Customer Token" (you can create a customer token in the Loggly UI)
// Replace your-app-name below with a short name for your app (no spaces or crazy characters). You can use this
// tag in the Loggly UI to create Source Group for each app you have in Loggly.
    static let logglyUrlString = "https://logs-01.loggly.com/bulk/your-loggly-api-key/tag/your-app-name/"

// Number of log entries in buffer before posting entries to Loggly. Entries will also be posted when the user
// exits the app.
    static let maxEntriesInBuffer = 100

// Loglevel for the Loggly destination
    static let logglyLogLevel = LogLevel.info

}