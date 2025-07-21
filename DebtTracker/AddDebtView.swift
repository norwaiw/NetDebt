import SwiftUI

struct AddDebtView: View {
    @ObservedObject var debtStore: DebtStore
    @Environment(\.dismiss) var dismiss
    
    @State private var personName = ""
    @State private var amount = ""
    @State private var description = ""
    @State private var isOwedToMe = false
    @State private var currency = "RUB"
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    
    let currencies = ["RUB", "USD", "EUR", "GBP", "CNY"]
    
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
                    
                    Text("Новый долг")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(BankingColors.primaryText)
                    
                    Spacer()
                    
                    Button("Сохранить") {
                        saveDebt()
                    }
                    .foregroundColor(BankingColors.accent)
                    .disabled(personName.isEmpty || amount.isEmpty)
                }
                .padding()
                .background(BankingColors.background)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Debt Type Toggle
                        VStack(spacing: 16) {
                            Text("Тип долга")
                                .font(.system(size: 14))
                                .foregroundColor(BankingColors.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 12) {
                                DebtTypeButton(
                                    title: "Я должен",
                                    isSelected: !isOwedToMe,
                                    action: { isOwedToMe = false }
                                )
                                
                                DebtTypeButton(
                                    title: "Мне должны",
                                    isSelected: isOwedToMe,
                                    action: { isOwedToMe = true }
                                )
                            }
                        }
                        .padding()
                        .bankingCard()
                        
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
    
    private func saveDebt() {
        guard let amountDouble = Double(amount) else { return }
        
        let newDebt = Debt(
            personName: personName,
            amount: amountDouble,
            currency: currency,
            isOwedToMe: isOwedToMe,
            description: description.isEmpty ? nil : description,
            dueDate: hasDueDate ? dueDate : nil,
            reminderDate: hasReminder ? reminderDate : nil
        )
        
        debtStore.addDebt(newDebt)
        
        if hasReminder {
            NotificationManager.shared.scheduleNotification(for: newDebt)
        }
        
        dismiss()
    }
}

// MARK: - Supporting Views
struct DebtTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : BankingColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? BankingColors.accent : BankingColors.tertiaryBackground)
                )
        }
    }
}

struct BankingTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(BankingColors.secondaryText)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(BankingColors.primaryText)
                .padding()
                .background(BankingColors.tertiaryBackground)
                .cornerRadius(12)
                .keyboardType(keyboardType)
        }
    }
}

struct BankingToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BankingColors.primaryText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(BankingColors.accent)
        }
        .padding()
    }
}

struct AddDebtView_Previews: PreviewProvider {
    static var previews: some View {
        AddDebtView(debtStore: DebtStore())
    }
}