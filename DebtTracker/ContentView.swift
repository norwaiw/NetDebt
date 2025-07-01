import SwiftUI

struct ContentView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        TabView {
            DebtListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Debts")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Statistics")
                }
        }
        .accentColor(.blue)
    }
}

struct StatisticsView: View {
    @EnvironmentObject var debtStore: DebtStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    VStack(spacing: 16) {
                        SummaryCard(
                            title: "Owed to Me",
                            amount: debtStore.totalOwedToMe,
                            color: .green,
                            icon: "arrow.down.circle.fill"
                        )
                        
                        SummaryCard(
                            title: "I Owe",
                            amount: debtStore.totalIOwe,
                            color: .red,
                            icon: "arrow.up.circle.fill"
                        )
                        
                        SummaryCard(
                            title: "Net Balance",
                            amount: debtStore.totalOwedToMe - debtStore.totalIOwe,
                            color: debtStore.totalOwedToMe >= debtStore.totalIOwe ? .green : .red,
                            icon: "equal.circle.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Overdue Debts
                    if !debtStore.overdueDebts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Overdue Debts")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            ForEach(debtStore.overdueDebts) { debt in
                                OverdueDebtRow(debt: debt)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Quick Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Stats")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            StatItem(title: "Total Debts", value: "\(debtStore.debts.count)")
                            Spacer()
                            StatItem(title: "Unpaid", value: "\(debtStore.unpaidDebts.count)")
                            Spacer()
                            StatItem(title: "Paid", value: "\(debtStore.paidDebts.count)")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "$0.00"
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(formattedAmount)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct OverdueDebtRow: View {
    let debt: Debt
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(debt.isOwedToMe ? debt.debtor : debt.creditor)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(debt.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(debt.isOwedToMe ? .green : .red)
                
                if let days = debt.remainingDays {
                    Text("\(abs(days)) days overdue")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DebtStore())
}