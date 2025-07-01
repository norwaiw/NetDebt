import SwiftUI

struct DebtDetailView: View {
    @EnvironmentObject var debtStore: DebtStore
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
                    Text("People")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        DetailRow(
                            title: debt.isOwedToMe ? "Creditor (You)" : "Creditor",
                            value: debt.creditor,
                            icon: "person.fill"
                        )
                        
                        DetailRow(
                            title: debt.isOwedToMe ? "Debtor" : "Debtor (You)",
                            value: debt.debtor,
                            icon: "person"
                        )
                    }
                }
                .padding(.horizontal)
                
                // Dates
                VStack(alignment: .leading, spacing: 16) {
                    Text("Dates")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        DetailRow(
                            title: "Created",
                            value: debt.dateCreated.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar.badge.plus"
                        )
                        
                        if let dueDate = debt.dueDate {
                            DetailRow(
                                title: "Due Date",
                                value: dueDate.formatted(date: .abbreviated, time: .omitted),
                                icon: "calendar.badge.exclamationmark",
                                valueColor: debt.isOverdue ? .red : .primary
                            )
                            
                            if let remainingDays = debt.remainingDays {
                                DetailRow(
                                    title: "Days Remaining",
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
                        Text("Additional Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            if debt.interestRate > 0 {
                                DetailRow(
                                    title: "Interest Rate",
                                    value: "\(debt.interestRate, specifier: "%.2f")%",
                                    icon: "percent"
                                )
                            }
                            
                            if !debt.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "note.text")
                                            .foregroundColor(.blue)
                                        Text("Notes")
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
                    if !debt.isPaid {
                        Button(action: { debtStore.markAsPaid(debt) }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Mark as Paid")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Debt")
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
                Button("Edit") {
                    startEditing()
                }
            }
        }
        .alert("Delete Debt", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                debtStore.deleteDebt(debt)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this debt? This action cannot be undone.")
        }
    }
    
    private var editingView: some View {
        NavigationView {
            Form {
                Section("Debt Details") {
                    TextField("Title", text: $editTitle)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $editAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Type", selection: $editIsOwedToMe) {
                        Text("Someone owes me").tag(true)
                        Text("I owe someone").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("People") {
                    TextField("Creditor", text: $editCreditor)
                        .textInputAutocapitalization(.words)
                    TextField("Debtor", text: $editDebtor)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $editHasDueDate)
                    
                    if editHasDueDate {
                        DatePicker("Due date", selection: $editDueDate, displayedComponents: .date)
                    }
                }
                
                Section("Additional Details") {
                    HStack {
                        Text("Interest Rate (%)")
                        Spacer()
                        TextField("0.0", text: $editInterestRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    TextField("Notes (optional)", text: $editNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Debt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
        updatedDebt.interestRate = Double(editInterestRate) ?? 0.0
        
        debtStore.updateDebt(updatedDebt)
        isEditing = false
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