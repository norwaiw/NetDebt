import Foundation

struct GoogleSheetsConfig {
    // TODO: Replace with your actual spreadsheet ID (the long string in the sheet URL)
    static let spreadsheetId = "1m7spAKr-3reWF9_ZmoCJNayyLmUIuskDQlPdHEjTTzQ"
    // The range where new rows should be appended (e.g., "Sheet1!A1")
    static let targetRange = "Sheet1!A1"
    // Value input option: RAW or USER_ENTERED
    static let valueInputOption = "USER_ENTERED"
    // TODO: Replace with your Google Cloud API key that has access to Google Sheets API
    static let apiKey = "YOUR_API_KEY"
}