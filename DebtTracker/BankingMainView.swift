import SwiftUI

struct BankingMainView: View {
    @StateObject private var debtStore = DebtStore()
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showAddDebt = false
    @State private var showSettings = false
    
    var totalDebt: Double {
        debtStore.debts.filter { !$0.isOwedToMe }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var totalOwed: Double {
        debtStore.debts.filter { $0.isOwedToMe }.reduce(0) { $0 + $1.remainingAmount }
    }
    
    var body: some View {
        ZStack {
            BankingColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Status Bar
                BankingStatusBar()
                
                // Content based on selected tab
                switch selectedTab {
                case 0:
                    mainTabContent
                case 1:
                    paymentsTabContent
                case 2:
                    benefitsTabContent
                case 3:
                    historyTabContent
                case 4:
                    chatsTabContent
                default:
                    mainTabContent
                }
                
                Spacer()
                
                // Tab Bar
                BankingTabBar(selectedTab: $selectedTab)
            }
        }
        .sheet(isPresented: $showAddDebt) {
            AddDebtView(debtStore: debtStore)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Main Tab
    var mainTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with user info
                headerSection
                
                // Account Cards
                accountCardsSection
                
                // Quick Actions
                quickActionsSection
                
                // Promo Cards
                promoCardsSection
                
                // Recent Transactions
                recentTransactionsSection
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    var headerSection: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(BankingColors.secondaryText)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Сергей")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(BankingColors.primaryText)
                
                Text("Alfa Only")
                    .font(.system(size: 14))
                    .foregroundColor(BankingColors.secondaryText)
            }
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(BankingColors.primaryText)
            }
        }
        .padding(.top, 16)
    }
    
    var accountCardsSection: some View {
        VStack(spacing: 16) {
            // Debt Summary Card
            if totalDebt > 0 || totalOwed > 0 {
                VStack(spacing: 12) {
                    if totalDebt > 0 {
                        AccountCard(
                            accountName: "Мои долги",
                            balance: totalDebt,
                            currency: "₽",
                            cardImage: "creditcard.fill"
                        )
                    }
                    
                    if totalOwed > 0 {
                        AccountCard(
                            accountName: "Мне должны",
                            balance: totalOwed,
                            currency: "₽",
                            cardImage: "banknote.fill"
                        )
                    }
                }
            }
            
            // Current Account
            AccountCard(
                accountName: "Текущий счет",
                balance: 1765,
                currency: "₽",
                cardImage: nil
            )
        }
    }
    
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Геленджик")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BankingColors.secondaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    QuickActionButton(
                        icon: "plus.circle.fill",
                        title: "Добавить долг",
                        subtitle: nil,
                        badge: nil,
                        action: { showAddDebt = true }
                    )
                    
                    QuickActionButton(
                        icon: "list.bullet",
                        title: "Все долги",
                        subtitle: "\(debtStore.debts.count)",
                        badge: nil,
                        action: { selectedTab = 3 }
                    )
                    
                    QuickActionButton(
                        icon: "bell.fill",
                        title: "Напоминания",
                        subtitle: nil,
                        badge: "3",
                        action: {}
                    )
                    
                    QuickActionButton(
                        icon: "chart.pie.fill",
                        title: "Статистика",
                        subtitle: nil,
                        badge: nil,
                        action: {}
                    )
                }
            }
        }
    }
    
    var promoCardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                PromoCard(
                    title: "Облигации",
                    subtitle: "без комиссии",
                    percentage: "0%",
                    backgroundColor: LinearGradient(
                        colors: [Color(hex: "E5E5EA"), Color(hex: "C7C7CC")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180)
                
                PromoCard(
                    title: "Получайте до",
                    subtitle: "16% годовых",
                    percentage: "%",
                    backgroundColor: LinearGradient(
                        colors: [Color(hex: "34C759"), Color(hex: "30A14E"), Color(hex: "007AFF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180)
            }
        }
    }
    
    var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            BankingSectionHeader(
                title: "Последние операции",
                actionTitle: "Все",
                action: { selectedTab = 3 }
            )
            
            VStack(spacing: 0) {
                ForEach(debtStore.debts.prefix(3)) { debt in
                    TransactionRow(
                        icon: debt.isOwedToMe ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                        title: debt.personName,
                        subtitle: debt.description ?? "Долг",
                        amount: "\(debt.isOwedToMe ? "+" : "-")\(Int(debt.remainingAmount)) ₽",
                        isPositive: debt.isOwedToMe
                    )
                    
                    if debt.id != debtStore.debts.prefix(3).last?.id {
                        Divider()
                            .background(BankingColors.tertiaryBackground)
                    }
                }
            }
            .padding()
            .bankingCard()
        }
    }
    
    // MARK: - Payments Tab
    var paymentsTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Search Bar
                BankingSearchBar(searchText: $searchText, placeholder: "Поиск по приложению")
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Payment Categories
                paymentCategoriesSection
                
                // Transfers Section
                transfersSection
                
                // Payment Options
                paymentOptionsSection
            }
            .padding(.bottom, 20)
        }
    }
    
    var paymentCategoriesSection: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    PaymentCategoryButton(
                        icon: "tram.fill",
                        title: "Мои платежи",
                        color: BankingColors.accent,
                        action: {}
                    )
                    
                    PaymentCategoryButton(
                        icon: "house.fill",
                        title: "Счета ЖКУ Дом",
                        color: BankingColors.warning,
                        action: {}
                    )
                    
                    PaymentCategoryButton(
                        icon: "car.fill",
                        title: "Штрафы ГАИ Авто",
                        color: BankingColors.success,
                        action: {}
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    var transfersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Переводы")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(BankingColors.primaryText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    TransferTypeButton(
                        icon: "arrow.left.arrow.right",
                        title: "Между счетами",
                        subtitle: "",
                        action: {}
                    )
                    
                    TransferTypeButton(
                        icon: "phone.fill",
                        title: "По номеру телефона",
                        subtitle: "",
                        action: {}
                    )
                    
                    TransferTypeButton(
                        icon: "creditcard.fill",
                        title: "По номеру карты",
                        subtitle: "",
                        action: {}
                    )
                    
                    TransferTypeButton(
                        icon: "doc.text.fill",
                        title: "По реквизитам",
                        subtitle: "",
                        action: {}
                    )
                    
                    TransferTypeButton(
                        icon: "globe",
                        title: "Перевод за рубеж",
                        subtitle: "",
                        action: {}
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    var paymentOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Платежи")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(BankingColors.primaryText)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                PaymentOptionRow(icon: "qrcode", title: "Оплата по QR")
                Divider().background(BankingColors.tertiaryBackground)
                PaymentOptionRow(icon: "antenna.radiowaves.left.and.right", title: "Мобильная связь")
                Divider().background(BankingColors.tertiaryBackground)
                PaymentOptionRow(icon: "wifi", title: "Интернет, телефон, ТВ")
                Divider().background(BankingColors.tertiaryBackground)
                PaymentOptionRow(icon: "house.fill", title: "Коммунальные услуги")
                Divider().background(BankingColors.tertiaryBackground)
                PaymentOptionRow(icon: "tram.fill", title: "Транспорт")
            }
            .padding()
            .bankingCard()
            .padding(.horizontal)
        }
    }
    
    // MARK: - Other Tabs
    var benefitsTabContent: some View {
        VStack {
            Text("Выгода")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BankingColors.primaryText)
            Spacer()
        }
        .padding()
    }
    
    var historyTabContent: some View {
        DebtListView(debtStore: debtStore)
    }
    
    var chatsTabContent: some View {
        VStack {
            Text("Чаты")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BankingColors.primaryText)
            Spacer()
        }
        .padding()
    }
}

// MARK: - Supporting Views
struct PaymentOptionRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(BankingColors.primaryText)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BankingColors.primaryText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(BankingColors.secondaryText)
        }
        .padding(.vertical, 12)
    }
}

struct BankingMainView_Previews: PreviewProvider {
    static var previews: some View {
        BankingMainView()
    }
}