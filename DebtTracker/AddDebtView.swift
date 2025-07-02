import SwiftUI

struct AddDebtView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    @State private var title = ""
    @State private var amount = ""
    @State private var creditor = ""
    @State private var debtor = ""
    @State private var isOwedToMe = true
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var notes = ""
    @State private var interestRate = ""
    
    @FocusState private var isAmountFocused: Bool
    
    private var isValidForm: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !amount.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) != nil &&
        !creditor.trimmingCharacters(in: .whitespaces).isEmpty &&
        !debtor.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(localizedString("debt_details")) {
                    TextField(localizedString("title_field"), text: $title)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text("$")
                        TextField(localizedString("amount"), text: $amount)
                            .keyboardType(.decimalPad)
                            .focused($isAmountFocused)
                    }
                    
                    Picker(localizedString("type"), selection: $isOwedToMe) {
                        Text(localizedString("someone_owes_me")).tag(true)
                        Text(localizedString("i_owe_someone")).tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(localizedString("people")) {
                    if isOwedToMe {
                        TextField(localizedString("who_owes_you"), text: $debtor)
                            .textInputAutocapitalization(.words)
                        TextField(localizedString("your_name"), text: $creditor)
                            .textInputAutocapitalization(.words)
                    } else {
                        TextField(localizedString("who_do_you_owe"), text: $creditor)
                            .textInputAutocapitalization(.words)
                        TextField(localizedString("your_name"), text: $debtor)
                            .textInputAutocapitalization(.words)
                    }
                }
                
                Section(localizedString("due_date")) {
                    Toggle(localizedString("set_due_date"), isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(localizedString("due_date"), selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }
                
                Section(localizedString("additional_details")) {
                    HStack {
                        Text(localizedString("interest_rate_percent"))
                        Spacer()
                        TextField("0.0", text: $interestRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    TextField(localizedString("notes_optional"), text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(localizedString("add_debt"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizedString("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizedString("save")) {
                        saveDebt()
                    }
                    .disabled(!isValidForm)
                }
            }
        }
    }
    
    private func saveDebt() {
        guard let amountValue = Double(amount) else { return }
        
        let debt = Debt(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amountValue,
            creditor: creditor.trimmingCharacters(in: .whitespaces),
            debtor: debtor.trimmingCharacters(in: .whitespaces),
            dueDate: hasDueDate ? dueDate : nil,
            isOwedToMe: isOwedToMe,
            notes: notes.trimmingCharacters(in: .whitespaces),
            interestRate: Double(interestRate) ?? 0.0
        )
        
        debtStore.addDebt(debt)
        dismiss()
    }
    
    private func localizedString(_ key: String) -> String {
        localizationHelper.localizedString(key, language: userSettings.selectedLanguage)
    }
}

#Preview {
    AddDebtView()
        .environmentObject(DebtStore())
}