import SwiftUI

struct DebtListView: View {
    @ObservedObject var debtStore: DebtStore
    @State private var showingAddDebt = false
    @State private var searchText = ""
    @State private var selectedFilter: DebtFilter = .all
    
    enum DebtFilter: String, CaseIterable {
        case all = "Все"
        case owedToMe = "Мне должны"
        case iOwe = "Я должен"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .owedToMe: return "arrow.down.circle"
            case .iOwe: return "arrow.up.circle"
            }
        }
    }
    
    var filteredDebts: [Debt] {
        let filtered = debtStore.debts.filter { debt in
            switch selectedFilter {
            case .all:
                return true
            case .owedToMe:
                return debt.isOwedToMe
            case .iOwe:
                return !debt.isOwedToMe
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { debt in
                debt.personName.localizedCaseInsensitiveContains(searchText) ||
                (debt.description ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var totalOwedToMe: Double {
        debtStore.debts.filter { $0.isOwedToMe }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var totalIOwe: Double {
        debtStore.debts.filter { !$0.isOwedToMe }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var body: some View {
        ZStack {
            BankingColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("История долгов")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(BankingColors.primaryText)
                        
                        Spacer()
                        
                        Button(action: { showingAddDebt = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(BankingColors.accent)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Search Bar
//                    BankingSearchBar(searchText: $searchText, placeholder: "Поиск долгов")
//                        .padding(.horizontal)
                    
                    // Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DebtFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    icon: filter.icon,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Summary Cards
                    if totalOwedToMe > 0 || totalIOwe > 0 {
                        HStack(spacing: 12) {
                            if totalOwedToMe > 0 {
                                SummaryCard(
                                    title: "Мне должны",
                                    amount: totalOwedToMe,
                                    color: BankingColors.success
                                )
                            }
                            
                            if totalIOwe > 0 {
                                SummaryCard(
                                    title: "Я должен",
                                    amount: totalIOwe,
                                    color: BankingColors.accent
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 16)
                
                // Debt List
                if filteredDebts.isEmpty {
                    EmptyStateView(filter: selectedFilter)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredDebts) { debt in
                                NavigationLink(destination: DebtDetailView(debt: debt, debtStore: debtStore)) {
                                    DebtRowCard(debt: debt)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddDebt) {
            AddDebtView(debtStore: debtStore)
        }
    }
}

// MARK: - Supporting Views
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : BankingColors.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? BankingColors.accent : BankingColors.tertiaryBackground)
            )
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(BankingColors.secondaryText)
            
            Text("\(Int(amount)) ₽")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DebtRowCard: View {
    let debt: Debt
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(debt.isOwedToMe ? BankingColors.success.opacity(0.2) : BankingColors.accent.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: debt.isOwedToMe ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(debt.isOwedToMe ? BankingColors.success : BankingColors.accent)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.personName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BankingColors.primaryText)
                
                HStack(spacing: 8) {
                    if let description = debt.description {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(BankingColors.secondaryText)
                            .lineLimit(1)
                    }
                    
                    if let dueDate = debt.dueDate {
                        Text("• \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.system(size: 12))
                            .foregroundColor(debt.isOverdue ? BankingColors.accent : BankingColors.secondaryText)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(debt.isOwedToMe ? "+" : "-")\(Int(debt.remainingAmount))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(debt.isOwedToMe ? BankingColors.success : BankingColors.primaryText)
                
                Text(debt.currency)
                    .font(.system(size: 12))
                    .foregroundColor(BankingColors.secondaryText)
            }
        }
        .padding()
        .bankingCard()
    }
}

struct EmptyStateView: View {
    let filter: DebtListView.DebtFilter
    
    var message: String {
        switch filter {
        case .all:
            return "У вас пока нет долгов"
        case .owedToMe:
            return "Вам никто не должен"
        case .iOwe:
            return "Вы никому не должны"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(BankingColors.success)
            
            Text(message)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BankingColors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct DebtListView_Previews: PreviewProvider {
    static var previews: some View {
        DebtListView(debtStore: DebtStore())
    }
}
