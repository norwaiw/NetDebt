import Foundation
import SwiftUI

class DebtStore: ObservableObject {
    @Published var debts: [Debt] = [] {
        didSet {
            saveDebts()
        }
    }
    
    private let saveKey = "SavedDebts"
    
    init() {
        loadDebts()
    }
    
    private func loadDebts() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Debt].self, from: data) {
            debts = decoded
        } else {
            // Load sample data for demo
            debts = Debt.sampleDebts
        }
    }
    
    private func saveDebts() {
        if let encoded = try? JSONEncoder().encode(debts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func addDebt(_ debt: Debt) {
        debts.append(debt)
    }
    
    func updateDebt(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index] = debt
        }
    }
    
    func deleteDebt(_ debt: Debt) {
        debts.removeAll { $0.id == debt.id }
    }
    
    func togglePaidStatus(_ debt: Debt) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index].isPaid.toggle()
            
            // If marking as paid, set remaining amount to 0
            if debts[index].isPaid && debts[index].partialPayments.isEmpty {
                let fullPayment = PartialPayment(
                    amount: debts[index].amount,
                    note: "Полная оплата"
                )
                debts[index].partialPayments.append(fullPayment)
            }
        }
    }
    
    func addPartialPayment(to debt: Debt, payment: PartialPayment) {
        if let index = debts.firstIndex(where: { $0.id == debt.id }) {
            debts[index].partialPayments.append(payment)
            
            // Check if debt is fully paid
            if debts[index].remainingAmount <= 0 {
                debts[index].isPaid = true
            }
        }
    }
    
    func deletePartialPayment(from debt: Debt, paymentId: UUID) {
        if let debtIndex = debts.firstIndex(where: { $0.id == debt.id }),
           let paymentIndex = debts[debtIndex].partialPayments.firstIndex(where: { $0.id == paymentId }) {
            debts[debtIndex].partialPayments.remove(at: paymentIndex)
            
            // Update paid status if needed
            if debts[debtIndex].isPaid && debts[debtIndex].remainingAmount > 0 {
                debts[debtIndex].isPaid = false
            }
        }
    }
    
    // Statistics
    var totalOwedToMe: Double {
        debts.filter { $0.isOwedToMe && !$0.isPaid }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var totalIOwe: Double {
        debts.filter { !$0.isOwedToMe && !$0.isPaid }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var overdueDebts: [Debt] {
        debts.filter { $0.isOverdue }
    }
}