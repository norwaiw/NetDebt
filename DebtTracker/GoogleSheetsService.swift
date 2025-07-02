import Foundation

/// A lightweight helper for pushing new debt rows to Google Sheets using the public Sheets API.
/// The service relies on an API key with the Google Sheets API enabled.
/// For production apps you should use OAuth, but for simple personal usage a restricted API key
/// tied to the spreadsheet will suffice.
final class GoogleSheetsService {
    static let shared = GoogleSheetsService()
    private init() {}

    // MARK: - Public API

    /// Appends a single `Debt` entry as a row at the bottom of the configured sheet.
    /// - Parameter debt: The `Debt` instance to upload.
    func append(debt: Debt) {
        guard !GoogleSheetsConfig.apiKey.isEmpty && GoogleSheetsConfig.apiKey != "YOUR_API_KEY" else {
            #if DEBUG
            print("[GoogleSheets] API key is not configured – skipping upload.")
            #endif
            return
        }

        guard let request = makeURLRequest(for: debt) else {
            #if DEBUG
            print("[GoogleSheets] Failed to construct URL request.")
            #endif
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                #if DEBUG
                print("[GoogleSheets] Error sending data: \(error.localizedDescription)")
                #endif
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                #if DEBUG
                print("[GoogleSheets] Response status: \(httpResponse.statusCode)")
                #endif
            }
        }
        task.resume()
    }

    // MARK: - Helpers

    private func makeURLRequest(for debt: Debt) -> URLRequest? {
        let baseURL = "https://sheets.googleapis.com/v4/spreadsheets/\(GoogleSheetsConfig.spreadsheetId)/values/\(GoogleSheetsConfig.targetRange):append"
        guard var components = URLComponents(string: baseURL) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "valueInputOption", value: GoogleSheetsConfig.valueInputOption),
            URLQueryItem(name: "key", value: GoogleSheetsConfig.apiKey)
        ]

        guard let url = components.url else { return nil }

        // Construct the row values – adjust fields/order to match your sheet columns.
        var row: [Any] = []
        row.append(debt.title)
        row.append(debt.amount)
        row.append(debt.creditor)
        row.append(debt.debtor)
        row.append(debt.dueDate != nil ? ISO8601DateFormatter().string(from: debt.dueDate!) : "")
        row.append(debt.isOwedToMe ? "OwedToMe" : "IOwe")
        row.append(debt.notes)
        row.append(debt.interestRate)
        row.append(debt.isPaid ? "Paid" : "Unpaid")

        let body: [String: Any] = [
            "values": [row]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        return request
    }
}