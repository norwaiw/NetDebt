import SwiftUI

struct EditDebtView: View {
    @Binding var debt: Debt
    @ObservedObject var debtStore: DebtStore
    @Environment(\.dismiss) var dismiss
    
    @State private var personName: String
    @State private var amount: String
    @State private var description: String
    @State private var currency: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var hasReminder: Bool
    @State private var reminderDate: Date
    
    let currencies = ["RUB", "USD", "EUR", "GBP", "CNY"]
    
    init(debt: Binding<Debt>, debtStore: DebtStore) {
        self._debt = debt
        self.debtStore = debtStore
        
        // Initialize state variables
        _personName = State(initialValue: debt.wrappedValue.personName)
        _amount = State(initialValue: String(format: "%.0f", debt.wrappedValue.amount))
        _description = State(initialValue: debt.wrappedValue.description ?? "")
        _currency = State(initialValue: debt.wrappedValue.currency)
        _dueDate = State(initialValue: debt.wrappedValue.dueDate ?? Date())
        _hasDueDate = State(initialValue: debt.wrappedValue.dueDate != nil)
        _hasReminder = State(initialValue: debt.wrappedValue.reminderDate != nil)
        _reminderDate = State(initialValue: debt.wrappedValue.reminderDate ?? Date())
    }
    
    var body: some View {
        ZStack {
            BankingColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(BankingColors.accent)
                    
                    Spacer()
                    
                    Text("Редактировать долг")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(BankingColors.primaryText)
                    
                    Spacer()
                    
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .foregroundColor(BankingColors.accent)
                    .disabled(personName.isEmpty || amount.isEmpty)
                }
                .padding()
                .background(BankingColors.background)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Person Info
                        VStack(spacing: 16) {
                            BankingTextField(
                                title: "Имя",
                                text: $personName,
                                placeholder: "Введите имя"
                            )
                            
                            HStack(spacing: 16) {
                                BankingTextField(
                                    title: "Сумма",
                                    text: $amount,
                                    placeholder: "0",
                                    keyboardType: .decimalPad
                                )
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Валюта")
                                        .font(.system(size: 14))
                                        .foregroundColor(BankingColors.secondaryText)
                                    
                                    Menu {
                                        ForEach(currencies, id: \.self) { curr in
                                            Button(curr) {
                                                currency = curr
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(currency)
                                                .foregroundColor(BankingColors.primaryText)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(BankingColors.secondaryText)
                                        }
                                        .padding()
                                        .background(BankingColors.tertiaryBackground)
                                        .cornerRadius(12)
                                    }
                                }
                                .frame(width: 100)
                            }
                            
                            BankingTextField(
                                title: "Описание",
                                text: $description,
                                placeholder: "Добавить описание (необязательно)"
                            )
                        }
                        .padding()
                        .bankingCard()
                        
                        // Due Date
                        VStack(spacing: 0) {
                            BankingToggleRow(
                                title: "Срок возврата",
                                isOn: $hasDueDate
                            )
                            
                            if hasDueDate {
                                DatePicker(
                                    "",
                                    selection: $dueDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.graphical)
                                .accentColor(BankingColors.accent)
                                .padding()
                            }
                        }
                        .bankingCard()
                        
                        // Reminder
                        VStack(spacing: 0) {
                            BankingToggleRow(
                                title: "Напоминание",
                                isOn: $hasReminder
                            )
                            
                            if hasReminder {
                                DatePicker(
                                    "",
                                    selection: $reminderDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.wheel)
                                .padding()
                            }
                        }
                        .bankingCard()
                    }
                    .padding()
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountDouble = Double(amount) else { return }
        
        debt.personName = personName
        debt.amount = amountDouble
        debt.currency = currency
        debt.description = description.isEmpty ? nil : description
        debt.dueDate = hasDueDate ? dueDate : nil
        debt.reminderDate = hasReminder ? reminderDate : nil
        
        debtStore.updateDebt(debt)
        
        if hasReminder {
            NotificationManager.shared.scheduleNotification(for: debt)
        }
        
        dismiss()
    }
}

struct EditDebtView_Previews: PreviewProvider {
    static var previews: some View {
        EditDebtView(debt: .constant(Debt.sampleDebts[0]), debtStore: DebtStore())
    }
}