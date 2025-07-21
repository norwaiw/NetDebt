import Foundation
import SwiftUI

struct Debt: Identifiable, Codable {
    let id: UUID
    let personName: String
    let amount: Double
    let currency: String
    let isOwedToMe: Bool
    let description: String?
    let dateCreated: Date
    let dueDate: Date?
    let reminderDate: Date?
    var isPaid: Bool
    var partialPayments: [PartialPayment]
    
    init(
        id: UUID = UUID(),
        personName: String,
        amount: Double,
        currency: String = "RUB",
        isOwedToMe: Bool = false,
        description: String? = nil,
        dateCreated: Date = Date(),
        dueDate: Date? = nil,
        reminderDate: Date? = nil,
        isPaid: Bool = false,
        partialPayments: [PartialPayment] = []
    ) {
        self.id = id
        self.personName = personName
        self.amount = amount
        self.currency = currency
        self.isOwedToMe = isOwedToMe
        self.description = description
        self.dateCreated = dateCreated
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.isPaid = isPaid
        self.partialPayments = partialPayments
    }
    
    var remainingAmount: Double {
        let totalPaid = partialPayments.reduce(0) { $0 + $1.amount }
        return max(0, amount - totalPaid)
    }
    
    var paymentProgress: Double {
        guard amount > 0 else { return 0 }
        let totalPaid = partialPayments.reduce(0) { $0 + $1.amount }
        return min(1.0, totalPaid / amount)
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isPaid else { return false }
        return Date() > dueDate
    }
    
    var remainingDays: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount)) \(currencySymbol)"
    }
    
    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: remainingAmount)) ?? "\(Int(remainingAmount)) \(currencySymbol)"
    }
    
    var currencySymbol: String {
        switch currency {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "CNY": return "¥"
        default: return currency
        }
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
    
    var urgencyLevel: UrgencyLevel {
        guard dueDate != nil, !isPaid else { return .normal }
        let daysRemaining = remainingDays ?? 0
        
        if daysRemaining < 0 {
            return .overdue
        } else if daysRemaining <= 3 {
            return .critical
        } else if daysRemaining <= 7 {
            return .high
        } else if daysRemaining <= 14 {
            return .medium
        } else {
            return .normal
        }
    }
    
    enum UrgencyLevel {
        case normal
        case medium
        case high
        case critical
        case overdue
        
        var color: Color {
            switch self {
            case .normal:
                return Color.green
            case .medium:
                return Color.yellow
            case .high:
                return Color.orange
            case .critical:
                return Color.red
            case .overdue:
                return Color.purple
            }
        }
        
        var systemImageName: String {
            switch self {
            case .normal:
                return "clock"
            case .medium:
                return "clock.badge.exclamationmark"
            case .high:
                return "exclamationmark.triangle"
            case .critical:
                return "exclamationmark.2"
            case .overdue:
                return "exclamationmark.octagon"
            }
        }
    }
}

struct PartialPayment: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let date: Date
    let note: String?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
    }
}

// MARK: - Sample Data
extension Debt {
    static let sampleDebts: [Debt] = [
        Debt(
            personName: "Иван Петров",
            amount: 5000,
            currency: "RUB",
            isOwedToMe: true,
            description: "За ужин в ресторане",
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        ),
        Debt(
            personName: "Мария Сидорова",
            amount: 15000,
            currency: "RUB",
            isOwedToMe: false,
            description: "Займ на ремонт",
            dueDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())
        ),
        Debt(
            personName: "Алексей Козлов",
            amount: 3000,
            currency: "RUB",
            isOwedToMe: true,
            description: "Билеты на концерт"
        )
    ]
}
