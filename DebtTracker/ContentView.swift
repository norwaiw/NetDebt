import SwiftUI

struct ContentView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    private func localizedString(_ key: String) -> String {
        return localizationHelper.localizedString(key, language: userSettings.selectedLanguage)
    }
    
    var body: some View {
        TabView {
            DebtListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text(localizedString("debts"))
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text(localizedString("statistics"))
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(localizedString("settings"))
                }
        }
        .accentColor(.blue)
    }
}

struct StatisticsView: View {
    @EnvironmentObject var debtStore: DebtStore
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    private func localizedString(_ key: String) -> String {
        return localizationHelper.localizedString(key, language: userSettings.selectedLanguage)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    VStack(spacing: 16) {
                        SummaryCard(
                            title: localizedString("owed_to_me"),
                            amount: debtStore.totalOwedToMe,
                            color: .green,
                            icon: "arrow.down.circle.fill"
                        )
                        
                        SummaryCard(
                            title: localizedString("i_owe"),
                            amount: debtStore.totalIOwe,
                            color: .red,
                            icon: "arrow.up.circle.fill"
                        )
                        
                        SummaryCard(
                            title: localizedString("net_balance"),
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
                                Text(localizedString("overdue_debts"))
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
                        Text(localizedString("quick_stats"))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            StatItem(title: localizedString("total_debts"), value: "\(debtStore.debts.count)")
                            Spacer()
                            StatItem(title: localizedString("unpaid"), value: "\(debtStore.unpaidDebts.count)")
                            Spacer()
                            StatItem(title: localizedString("paid"), value: "\(debtStore.paidDebts.count)")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(localizedString("statistics"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        userSettings.updateHideTotalAmount(!userSettings.hideTotalAmount)
                    }) {
                        Image(systemName: userSettings.hideTotalAmount ? "eye" : "eye.slash")
                    }
                }
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    @EnvironmentObject var userSettings: UserSettings
    
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
                Text(userSettings.hideTotalAmount ? "••••" : formattedAmount)
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
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    private func localizedString(_ key: String) -> String {
        return localizationHelper.localizedString(key, language: userSettings.selectedLanguage)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.personName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let description = debt.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(userSettings.hideTotalAmount ? "••••" : debt.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(debt.isOwedToMe ? .green : .red)
                
                if let days = debt.remainingDays {
                    Text("\(abs(days)) \(localizedString("days_overdue"))")
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
        .environmentObject(UserSettings())
}
