import Foundation
import SwiftUI

struct Debt: Identifiable, Codable {
    var id = UUID()
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
    var partialPayments: [PartialPayment] = [] // New field for partial payments
    
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
    
    // New computed properties for partial payments
    var totalPaid: Double {
        partialPayments.reduce(0) { $0 + $1.amount }
    }
    
    var remainingAmount: Double {
        max(0, amount - totalPaid)
    }
    
    var paymentProgress: Double {
        guard amount > 0 else { return 0 }
        return min(1.0, totalPaid / amount)
    }
    
    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: remainingAmount)) ?? "$0.00"
    }
    
    // Urgency level based on due date
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

// New struct for partial payments
struct PartialPayment: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var date: Date
    var note: String = ""
}
