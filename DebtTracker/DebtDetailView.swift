import SwiftUI


struct DebtDetailView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    @Environment(\.dismiss) private var dismiss
    
    let debt: Debt
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    // Editing states
    @State private var editTitle = ""
    @State private var editAmount = ""
    @State private var editCreditor = ""
    @State private var editDebtor = ""
    @State private var editIsOwedToMe = true
    @State private var editHasDueDate = false
    @State private var editDueDate = Date()
    @State private var editNotes = ""
    @State private var editInterestRate = ""
    
    // New states for partial payments
    @State private var showingAddPayment = false
    @State private var paymentAmount = ""
    @State private var paymentNote = ""
    
    private var isValidForm: Bool {
        !editTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !editAmount.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(editAmount) != nil &&
        !editCreditor.trimmingCharacters(in: .whitespaces).isEmpty &&
        !editDebtor.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        if isEditing {
            editingView
        } else {
            detailView
        }
    }
    
    private var detailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(debt.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if debt.isPaid {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(debt.formattedAmount)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(debt.isOwedToMe ? .green : .red)
                    
                    Text(debt.statusText)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // People
                VStack(alignment: .leading, spacing: 16) {
                    Text(localizedString("people"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        DetailRow(
                            title: debt.isOwedToMe ? localizedString("creditor_you") : localizedString("creditor"),
                            value: debt.creditor,
                            icon: "person.fill"
                        )
                        
                        DetailRow(
                            title: debt.isOwedToMe ? localizedString("debtor") : localizedString("debtor_you"),
                            value: debt.debtor,
                            icon: "person"
                        )
                    }
                }
                .padding(.horizontal)
                
                // Payment Progress Section (New)
                if !debt.isPaid && debt.amount > 0 {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(localizedString("payment_progress"))
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            // Urgency indicator badge
                            if debt.dueDate != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: debt.urgencyLevel.systemImageName)
                                        .font(.caption)
                                    Text(urgencyText(for: debt.urgencyLevel))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(debt.urgencyLevel.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(debt.urgencyLevel.color.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Progress bar
                        PaymentProgressView(debt: debt)
                        
                        // Partial payments list
                        if debt.partialPayments.count > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizedString("partial_payments"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                ForEach(debt.partialPayments.sorted(by: { $0.date > $1.date })) { payment in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(payment.amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                                                .font(.body)
                                                .fontWeight(.medium)
                                            Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            if !payment.note.isEmpty {
                                                Text(payment.note)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            debtStore.deletePartialPayment(from: debt, paymentId: payment.id)
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Add payment button
                        Button(action: { showingAddPayment = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text(localizedString("add_payment"))
                            }
                            .font(.body)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Dates
                VStack(alignment: .leading, spacing: 16) {
                    Text(localizedString("dates"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        DetailRow(
                            title: localizedString("created"),
                            value: debt.dateCreated.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar.badge.plus"
                        )
                        
                        if let dueDate = debt.dueDate {
                            DetailRow(
                                title: localizedString("due_date"),
                                value: dueDate.formatted(date: .abbreviated, time: .omitted),
                                icon: "calendar.badge.exclamationmark",
                                valueColor: debt.isOverdue ? .red : .primary
                            )
                            
                            if let remainingDays = debt.remainingDays {
                                DetailRow(
                                    title: localizedString("days_remaining"),
                                    value: remainingDays >= 0 ? "\(remainingDays) days" : "\(abs(remainingDays)) days overdue",
                                    icon: "clock",
                                    valueColor: remainingDays >= 0 ? .primary : .red
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Additional Details
                if debt.interestRate > 0 || !debt.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(localizedString("additional_details"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            if debt.interestRate > 0 {
                                DetailRow(
                                    title: localizedString("interest_rate_percent"),
                                    value: String(format: "%.2f%%", debt.interestRate),
                                    icon: "percent"
                                )
                            }
                            
                            if !debt.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "note.text")
                                            .foregroundColor(.blue)
                                        Text(localizedString("notes"))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Text(debt.notes)
                                        .font(.body)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: { debtStore.togglePaidStatus(debt) }) {
                        HStack {
                            Image(systemName: debt.isPaid ? "arrow.uturn.backward.circle" : "checkmark.circle")
                            Text(debt.isPaid ? localizedString("mark_as_unpaid") : localizedString("mark_as_paid"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(debt.isPaid ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text(localizedString("delete_debt"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(localizedString("edit")) {
                    startEditing()
                }
            }
        }
        .alert(localizedString("delete_debt_title"), isPresented: $showingDeleteAlert) {
            Button(localizedString("delete_debt"), role: .destructive) {
                debtStore.deleteDebt(debt)
                dismiss()
            }
            Button(localizedString("cancel"), role: .cancel) { }
        } message: {
            Text(localizedString("delete_debt_message"))
        }
        .sheet(isPresented: $showingAddPayment) {
            addPaymentView
        }
    }
    
    private var editingView: some View {
        NavigationView {
            Form {
                Section(localizedString("debt_details")) {
                    TextField(localizedString("title_field"), text: $editTitle)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text("$")
                        TextField(localizedString("amount"), text: $editAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker(localizedString("type"), selection: $editIsOwedToMe) {
                        Text(localizedString("someone_owes_me")).tag(true)
                        Text(localizedString("i_owe_someone")).tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(localizedString("people")) {
                    TextField(localizedString("creditor"), text: $editCreditor)
                        .textInputAutocapitalization(.words)
                    TextField(localizedString("debtor"), text: $editDebtor)
                        .textInputAutocapitalization(.words)
                }
                
                Section(localizedString("due_date")) {
                    Toggle(localizedString("set_due_date"), isOn: $editHasDueDate)
                    
                    if editHasDueDate {
                        DatePicker(localizedString("due_date"), selection: $editDueDate, displayedComponents: .date)
                    }
                }
                
                Section(localizedString("additional_details")) {
                    HStack {
                        Text(localizedString("interest_rate_percent"))
                        Spacer()
                        TextField("0.0", text: $editInterestRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    TextField(localizedString("notes_optional"), text: $editNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(localizedString("edit_debt"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizedString("cancel")) {
                        isEditing = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizedString("save")) {
                        saveChanges()
                    }
                    .disabled(!isValidForm)
                }
            }
        }
    }
    
    private func startEditing() {
        editTitle = debt.title
        editAmount = String(debt.amount)
        editCreditor = debt.creditor
        editDebtor = debt.debtor
        editIsOwedToMe = debt.isOwedToMe
        editHasDueDate = debt.dueDate != nil
        editDueDate = debt.dueDate ?? Date()
        editNotes = debt.notes
        editInterestRate = debt.interestRate > 0 ? String(debt.interestRate) : ""
        isEditing = true
    }
    
    private func saveChanges() {
        guard let amountValue = Double(editAmount) else { return }
        
        var updatedDebt = debt
        updatedDebt.title = editTitle.trimmingCharacters(in: .whitespaces)
        updatedDebt.amount = amountValue
        updatedDebt.creditor = editCreditor.trimmingCharacters(in: .whitespaces)
        updatedDebt.debtor = editDebtor.trimmingCharacters(in: .whitespaces)
        updatedDebt.isOwedToMe = editIsOwedToMe
        updatedDebt.dueDate = editHasDueDate ? editDueDate : nil
        updatedDebt.notes = editNotes.trimmingCharacters(in: .whitespaces)
        updatedDebt.interestRate = max(Double(editInterestRate) ?? 0.0, 0.0)
        
        debtStore.updateDebt(updatedDebt)
        isEditing = false
    }
    
    private var addPaymentView: some View {
        NavigationView {
            Form {
                Section(localizedString("payment_details")) {
                    HStack {
                        Text("$")
                        TextField(localizedString("amount"), text: $paymentAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    TextField(localizedString("note_optional"), text: $paymentNote)
                }
                
                Section {
                    Text(localizedString("remaining_after_payment") + ": " + remainingAfterPaymentText)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(localizedString("add_payment"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizedString("cancel")) {
                        paymentAmount = ""
                        paymentNote = ""
                        showingAddPayment = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizedString("add")) {
                        addPayment()
                    }
                    .disabled(!isValidPayment)
                }
            }
        }
    }
    
    private var isValidPayment: Bool {
        guard let amount = Double(paymentAmount), amount > 0 else { return false }
        return amount <= debt.remainingAmount
    }
    
    private var remainingAfterPaymentText: String {
        guard let amount = Double(paymentAmount) else {
            return debt.formattedRemainingAmount
        }
        let remaining = max(0, debt.remainingAmount - amount)
        return remaining.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
    
    private func addPayment() {
        guard let amount = Double(paymentAmount) else { return }
        debtStore.addPartialPayment(to: debt, amount: amount, note: paymentNote)
        paymentAmount = ""
        paymentNote = ""
        showingAddPayment = false
    }
    
    private func urgencyText(for level: Debt.UrgencyLevel) -> String {
        switch level {
        case .normal:
            return localizedString("on_track")
        case .medium:
            return localizedString("approaching")
        case .high:
            return localizedString("urgent")
        case .critical:
            return localizedString("very_urgent")
        case .overdue:
            return localizedString("overdue")
        }
    }
    
    private func localizedString(_ key: String) -> String {
        localizationHelper.localizedString(key, language: userSettings.selectedLanguage)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
        }
    }
}

#if swift(>=5.9)
#Preview {
    NavigationView {
        DebtDetailView(debt: Debt(
            title: "Lunch Money",
            amount: 25.50,
            creditor: "John Doe",
            debtor: "Jane Smith",
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            isOwedToMe: true,
            notes: "Pizza from last Friday"
        ))
    }
    .environmentObject(DebtStore())
}
#endif
