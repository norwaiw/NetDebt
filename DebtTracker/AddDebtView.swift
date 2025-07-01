import SwiftUI

struct AddDebtView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var debtStore: DebtStore
    
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
                Section("Debt Details") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .focused($isAmountFocused)
                    }
                    
                    Picker("Type", selection: $isOwedToMe) {
                        Text("Someone owes me").tag(true)
                        Text("I owe someone").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("People") {
                    if isOwedToMe {
                        TextField("Who owes you?", text: $debtor)
                            .textInputAutocapitalization(.words)
                        TextField("Your name", text: $creditor)
                            .textInputAutocapitalization(.words)
                    } else {
                        TextField("Who do you owe?", text: $creditor)
                            .textInputAutocapitalization(.words)
                        TextField("Your name", text: $debtor)
                            .textInputAutocapitalization(.words)
                    }
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }
                
                Section("Additional Details") {
                    HStack {
                        Text("Interest Rate (%)")
                        Spacer()
                        TextField("0.0", text: $interestRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Debt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
}

#Preview {
    AddDebtView()
        .environmentObject(DebtStore())
}