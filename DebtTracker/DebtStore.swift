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
        debts.filter { $0.isOwedToMe && !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var totalIOwe: Double {
        debts.filter { !$0.isOwedToMe && !$0.isPaid }.reduce(0) { $0 + $1.amount }
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