import SwiftUI


struct DebtDetailView: View {
    let debt: Debt
    @ObservedObject var debtStore: DebtStore
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingAddPayment = false
    @State private var paymentAmount = ""
    @State private var paymentNote = ""
    
    var body: some View {
        ZStack {
            BankingColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard
                    
                    // Progress Card
                    if !debt.partialPayments.isEmpty {
                        progressCard
                    }
                    
                    // Details Card
                    detailsCard
                    
                    // Actions
                    actionsSection
                    
                    // Payment History
                    if !debt.partialPayments.isEmpty {
                        paymentHistorySection
                    }
                    
                    // Delete Button
                    deleteButton
                }
                .padding()
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Изменить") {
                    showingEditSheet = true
                }
                .foregroundColor(BankingColors.accent)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDebtView(debt: .constant(debt), debtStore: debtStore)
        }
        .sheet(isPresented: $showingAddPayment) {
            addPaymentSheet
        }
        .alert("Удалить долг?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                debtStore.deleteDebt(debt)
                dismiss()
            }
        } message: {
            Text("Это действие нельзя отменить")
        }
    }
    
    var headerCard: some View {
        VStack(spacing: 16) {
            // Person and Type
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(BankingColors.secondaryText)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(debt.personName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(BankingColors.primaryText)
                    
                    Text(debt.isOwedToMe ? "Мне должны" : "Я должен")
                        .font(.system(size: 16))
                        .foregroundColor(BankingColors.secondaryText)
                }
                
                Spacer()
            }
            
            // Amount
            HStack(alignment: .bottom, spacing: 8) {
                Text(String(format: "%.0f", debt.remainingAmount))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(debt.isOwedToMe ? BankingColors.success : BankingColors.accent)
                
                Text(debt.currencySymbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(debt.isOwedToMe ? BankingColors.success : BankingColors.accent)
                    .padding(.bottom, 4)
                
                Spacer()
                
                if debt.isPaid {
                    Label("Оплачено", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BankingColors.success)
                }
            }
            
            if let description = debt.description {
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(BankingColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
        .bankingCard()
    }
    
    var progressCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Прогресс выплаты")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BankingColors.primaryText)
                
                Spacer()
                
                Text("\(Int(debt.paymentProgress * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(BankingColors.accent)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(BankingColors.tertiaryBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(BankingColors.accent)
                        .frame(width: geometry.size.width * debt.paymentProgress, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Выплачено: \(Int(debt.amount - debt.remainingAmount)) \(debt.currencySymbol)")
                    .font(.system(size: 14))
                    .foregroundColor(BankingColors.secondaryText)
                
                Spacer()
                
                Text("Осталось: \(Int(debt.remainingAmount)) \(debt.currencySymbol)")
                    .font(.system(size: 14))
                    .foregroundColor(BankingColors.secondaryText)
            }
        }
        .padding()
        .bankingCard()
    }
    
    var detailsCard: some View {
        VStack(spacing: 20) {
            DetailRow(
                icon: "calendar",
                title: "Дата создания",
                value: debt.dateCreated.formatted(date: .abbreviated, time: .omitted)
            )
            
            if let dueDate = debt.dueDate {
                DetailRow(
                    icon: "clock.fill",
                    title: "Срок возврата",
                    value: dueDate.formatted(date: .abbreviated, time: .omitted),
                    valueColor: debt.isOverdue ? BankingColors.accent : nil
                )
                
                if let days = debt.remainingDays {
                    DetailRow(
                        icon: "hourglass",
                        title: "Осталось дней",
                        value: "\(days)",
                        valueColor: debt.isOverdue ? BankingColors.accent : nil
                    )
                }
            }
            
            DetailRow(
                icon: "banknote",
                title: "Полная сумма",
                value: "\(Int(debt.amount)) \(debt.currencySymbol)"
            )
        }
        .padding()
        .bankingCard()
    }
    
    var actionsSection: some View {
        HStack(spacing: 12) {
            if !debt.isPaid {
                Button(action: { showingAddPayment = true }) {
                    Label("Добавить платеж", systemImage: "plus.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(BankingColors.accent)
                        .cornerRadius(12)
                }
                
                Button(action: { markAsPaid() }) {
                    Label("Оплачено", systemImage: "checkmark.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BankingColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(BankingColors.tertiaryBackground)
                        .cornerRadius(12)
                }
            } else {
                Button(action: { markAsUnpaid() }) {
                    Label("Отменить оплату", systemImage: "arrow.uturn.backward.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BankingColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(BankingColors.tertiaryBackground)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    var paymentHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("История платежей")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(BankingColors.primaryText)
            
            VStack(spacing: 12) {
                ForEach(debt.partialPayments.sorted(by: { $0.date > $1.date })) { payment in
                    PaymentHistoryRow(payment: payment, currency: debt.currencySymbol)
                }
            }
        }
    }
    
    var deleteButton: some View {
        Button(action: { showingDeleteAlert = true }) {
            Text("Удалить долг")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BankingColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(BankingColors.accent.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    var addPaymentSheet: some View {
        NavigationView {
            ZStack {
                BankingColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    BankingTextField(
                        title: "Сумма платежа",
                        text: $paymentAmount,
                        placeholder: "0",
                        keyboardType: .decimalPad
                    )
                    
                    BankingTextField(
                        title: "Примечание (необязательно)",
                        text: $paymentNote,
                        placeholder: "Добавить примечание"
                    )
                    
                    Spacer()
                    
                    Button(action: addPayment) {
                        Text("Добавить платеж")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(BankingColors.accent)
                            .cornerRadius(12)
                    }
                    .disabled(paymentAmount.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Новый платеж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        showingAddPayment = false
                        paymentAmount = ""
                        paymentNote = ""
                    }
                    .foregroundColor(BankingColors.accent)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func markAsPaid() {
        debtStore.togglePaidStatus(debt)
    }
    
    private func markAsUnpaid() {
        debtStore.togglePaidStatus(debt)
    }
    
    private func addPayment() {
        guard let amount = Double(paymentAmount), amount > 0 else { return }
        
        let payment = PartialPayment(
            amount: amount,
            note: paymentNote.isEmpty ? nil : paymentNote
        )
        
        debtStore.addPartialPayment(to: debt, payment: payment)
        
        showingAddPayment = false
        paymentAmount = ""
        paymentNote = ""
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let valueColor: Color?
    
    init(icon: String, title: String, value: String, valueColor: Color? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(BankingColors.secondaryText)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(BankingColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(valueColor ?? BankingColors.primaryText)
        }
    }
}

struct PaymentHistoryRow: View {
    let payment: PartialPayment
    let currency: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Int(payment.amount)) \(currency)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BankingColors.primaryText)
                
                if let note = payment.note {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundColor(BankingColors.secondaryText)
                }
            }
            
            Spacer()
            
            Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 14))
                .foregroundColor(BankingColors.secondaryText)
        }
        .padding()
        .background(BankingColors.tertiaryBackground)
        .cornerRadius(12)
    }
}

struct DebtDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DebtDetailView(debt: Debt.sampleDebts[0], debtStore: DebtStore())
        }
    }
}
