import Foundation

struct Debt: Identifiable, Codable {
    let id = UUID()
    var title: String
    var amount: Double
    var creditor: String
    var debtor: String
    var dueDate: Date?
    var isOwedToMe: Bool // true if someone owes me, false if I owe someone
    var isPaid: Bool = false
    var dateCreated: Date = Date()
    var notes: String = ""
    var interestRate: Double = 0.0
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    var statusText: String {
        if isPaid {
            return "Paid"
        } else if isOwedToMe {
            return "Owed to me"
        } else {
            return "I owe"
        }
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isPaid else { return false }
        return dueDate < Date()
    }
    
    var remainingDays: Int? {
        guard let dueDate = dueDate, !isPaid else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: dueDate).day
    }
}