import SwiftUI

struct DebtListView: View {
    @EnvironmentObject var debtStore: DebtStore
    @State private var showingAddDebt = false
    @State private var filterOption: FilterOption = .all
    @State private var sortOption: SortOption = .dateCreated
    @State private var searchText = ""
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case owedToMe = "Owed to Me"
        case iOwe = "I Owe"
        case unpaid = "Unpaid"
        case paid = "Paid"
        case overdue = "Overdue"
    }
    
    enum SortOption: String, CaseIterable {
        case dateCreated = "Date Created"
        case amount = "Amount"
        case dueDate = "Due Date"
        case title = "Title"
    }
    
    private var filteredAndSortedDebts: [Debt] {
        var debts = debtStore.debts
        
        // Apply search filter
        if !searchText.isEmpty {
            debts = debts.filter { debt in
                debt.title.localizedCaseInsensitiveContains(searchText) ||
                debt.creditor.localizedCaseInsensitiveContains(searchText) ||
                debt.debtor.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        switch filterOption {
        case .all:
            break
        case .owedToMe:
            debts = debts.filter { $0.isOwedToMe }
        case .iOwe:
            debts = debts.filter { !$0.isOwedToMe }
        case .unpaid:
            debts = debts.filter { !$0.isPaid }
        case .paid:
            debts = debts.filter { $0.isPaid }
        case .overdue:
            debts = debts.filter { $0.isOverdue }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateCreated:
            debts.sort { $0.dateCreated > $1.dateCreated }
        case .amount:
            debts.sort { $0.amount > $1.amount }
        case .dueDate:
            debts.sort { (debt1, debt2) in
                guard let date1 = debt1.dueDate, let date2 = debt2.dueDate else {
                    return debt1.dueDate != nil
                }
                return date1 < date2
            }
        case .title:
            debts.sort { $0.title < $1.title }
        }
        
        return debts
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter and Sort Controls
                VStack(spacing: 12) {
                    HStack {
                        Menu {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                Button(option.rawValue) {
                                    filterOption = option
                                }
                            }
                        } label: {
                            HStack {
                                Text("Filter: \(filterOption.rawValue)")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(option.rawValue) {
                                    sortOption = option
                                }
                            }
                        } label: {
                            HStack {
                                Text("Sort: \(sortOption.rawValue)")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Debt List
                if filteredAndSortedDebts.isEmpty {
                    EmptyStateView(filterOption: filterOption)
                } else {
                    List {
                        ForEach(filteredAndSortedDebts) { debt in
                            NavigationLink(destination: DebtDetailView(debt: debt)) {
                                DebtRowView(debt: debt)
                            }
                        }
                        .onDelete(perform: deleteDebts)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Debt Tracker")
            .searchable(text: $searchText, prompt: "Search debts...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDebt = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDebt) {
                AddDebtView()
            }
        }
    }
    
    private func deleteDebts(offsets: IndexSet) {
        for index in offsets {
            debtStore.deleteDebt(filteredAndSortedDebts[index])
        }
    }
}

struct DebtRowView: View {
    let debt: Debt
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.title)
                    .font(.headline)
                    .foregroundColor(debt.isPaid ? .secondary : .primary)
                
                Text(debt.isOwedToMe ? "From: \(debt.debtor)" : "To: \(debt.creditor)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let dueDate = debt.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(dueDate, style: .date)
                            .font(.caption)
                        
                        if debt.isOverdue {
                            Text("(Overdue)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(debt.formattedAmount)
                    .font(.headline)
                    .foregroundColor(debt.isPaid ? .secondary : (debt.isOwedToMe ? .green : .red))
                
                HStack {
                    if debt.isPaid {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Paid")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Button(action: { debtStore.markAsPaid(debt) }) {
                            Image(systemName: "circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(debt.isPaid ? 0.6 : 1.0)
    }
}

struct EmptyStateView: View {
    let filterOption: DebtListView.FilterOption
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(emptyMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var emptyMessage: String {
        switch filterOption {
        case .all:
            return "No debts found.\nTap + to add your first debt."
        case .owedToMe:
            return "No one owes you money.\nLucky you!"
        case .iOwe:
            return "You don't owe anyone money.\nGreat job!"
        case .unpaid:
            return "No unpaid debts found."
        case .paid:
            return "No paid debts found."
        case .overdue:
            return "No overdue debts.\nEverything is on track!"
        }
    }
}

#Preview {
    DebtListView()
        .environmentObject(DebtStore())
}