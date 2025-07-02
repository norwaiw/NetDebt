import Foundation
import SwiftUI

class DebtStore: ObservableObject {
    @Published var debts: [Debt] = []
    
    private let saveKey = "SavedDebts"
    
    init() {
        loadDebts()
    }
    
    func addDebt(_ debt: Debt) {
        debts.append(debt)
        saveDebts()
        NotificationManager.shared.scheduleNotification(for: debt)
    }
    
    func updateDebt(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            NotificationManager.shared.cancelNotification(for: debts[index])
            debts[index] = debt
            saveDebts()
            NotificationManager.shared.scheduleNotification(for: debt)
        }
    }
    
    func deleteDebt(_ debt: Debt) {
        NotificationManager.shared.cancelNotification(for: debt)
        debts.removeAll { $0.id == debt.id }
        saveDebts()
    }
    
    func markAsPaid(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index].isPaid = true
            saveDebts()
            NotificationManager.shared.cancelNotification(for: debts[index])
        }
    }
    
    // New methods for partial payments
    func addPartialPayment(to debt: Debt, amount: Double, note: String = "") {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            let payment = PartialPayment(amount: amount, date: Date(), note: note)
            debts[index].partialPayments.append(payment)
            
            // Check if debt is fully paid
            if debts[index].remainingAmount <= 0 {
                debts[index].isPaid = true
                NotificationManager.shared.cancelNotification(for: debts[index])
            }
            
            saveDebts()
        }
    }
    
    func deletePartialPayment(from debt: Debt, paymentId: UUID) {
        if let debtIndex = debts.firstIndex(where: { $0.id == debt.id }),
           let paymentIndex = debts[debtIndex].partialPayments.firstIndex(where: { $0.id == paymentId }) {
            debts[debtIndex].partialPayments.remove(at: paymentIndex)
            
            // Update paid status if needed
            if debts[debtIndex].isPaid && debts[debtIndex].remainingAmount > 0 {
                debts[debtIndex].isPaid = false
                NotificationManager.shared.scheduleNotification(for: debts[debtIndex])
            }
            
            saveDebts()
        }
    }
    
    private func saveDebts() {
        if let encoded = try? JSONEncoder().encode(debts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadDebts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Debt].self, from: data) {
            debts = decoded
            // Ensure notifications are scheduled for existing debts.
            for debt in debts {
                NotificationManager.shared.scheduleNotification(for: debt)
            }
        }
    }
    
    // Computed properties for statistics
    var totalOwedToMe: Double {
        debts.filter { $0.isOwedToMe && !$0.isPaid }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var totalIOwe: Double {
        debts.filter { !$0.isOwedToMe && !$0.isPaid }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var overdueDebts: [Debt] {
        debts.filter { $0.isOverdue }
    }
    
    var unpaidDebts: [Debt] {
        debts.filter { !$0.isPaid }
    }
    
    var paidDebts: [Debt] {
        debts.filter { $0.isPaid }
    }
}