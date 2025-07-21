import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    @State private var showingCurrencyPicker = false
    
    private func localizedString(_ key: String) -> String {
        return localizationHelper.localizedString(key, language: userSettings.selectedLanguage)
    }
    
    var body: some View {
        ZStack {
            BankingColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text(localizedString("settings"))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(BankingColors.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Language Section
                    VStack(spacing: 0) {
                        SectionHeader(title: localizedString("language"))
                        
                        VStack(spacing: 0) {
                            ForEach(UserSettings.Language.allCases, id: \.self) { language in
                                LanguageRow(
                                    language: language,
                                    isSelected: userSettings.selectedLanguage == language,
                                    action: { userSettings.selectedLanguage = language }
                                )
                                
                                if language != UserSettings.Language.allCases.last {
                                    Divider()
                                        .background(BankingColors.tertiaryBackground)
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .bankingCard()
                    }
                    
                    // Currency Section
                    VStack(spacing: 0) {
                        SectionHeader(title: localizedString("default_currency"))
                        
                        Button(action: { showingCurrencyPicker = true }) {
                            HStack {
                                Text(userSettings.defaultCurrency)
                                    .font(.system(size: 16))
                                    .foregroundColor(BankingColors.primaryText)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(BankingColors.secondaryText)
                            }
                            .padding()
                        }
                        .bankingCard()
                    }
                    
                    // Privacy Section
                    VStack(spacing: 0) {
                        SectionHeader(title: localizedString("privacy"))
                        
                        BankingToggleRow(
                            title: localizedString("hide_amounts"),
                            isOn: $userSettings.hideTotalAmount
                        )
                        .bankingCard()
                    }
                    
                    // Notifications Section
                    VStack(spacing: 0) {
                        SectionHeader(title: localizedString("notifications"))
                        
                        BankingToggleRow(
                            title: localizedString("enable_notifications"),
                            isOn: $userSettings.notificationsEnabled
                        )
                        .bankingCard()
                    }
                    
                    // About Section
                    VStack(spacing: 0) {
                        SectionHeader(title: localizedString("about"))
                        
                        VStack(spacing: 0) {
                            InfoRow(title: localizedString("version"), value: "1.0.0")
                            
                            Divider()
                                .background(BankingColors.tertiaryBackground)
                                .padding(.leading, 16)
                            
                            InfoRow(title: localizedString("developer"), value: "DebtTracker Team")
                        }
                        .bankingCard()
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showingCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $userSettings.defaultCurrency)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 14))
            .foregroundColor(BankingColors.secondaryText)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
}

struct LanguageRow: View {
    let language: UserSettings.Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(language.displayName)
                    .font(.system(size: 16))
                    .foregroundColor(BankingColors.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BankingColors.accent)
                }
            }
            .padding()
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(BankingColors.primaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(BankingColors.secondaryText)
        }
        .padding()
    }
}

struct CurrencyPickerView: View {
    @Binding var selectedCurrency: String
    @Environment(\.dismiss) var dismiss
    
    let currencies = ["RUB", "USD", "EUR", "GBP", "CNY", "JPY", "KRW", "INR", "BRL", "CAD", "AUD", "CHF"]
    
    var body: some View {
        NavigationView {
            ZStack {
                BankingColors.background
                    .ignoresSafeArea()
                
                List(currencies, id: \.self) { currency in
                    Button(action: {
                        selectedCurrency = currency
                        dismiss()
                    }) {
                        HStack {
                            Text(currency)
                                .font(.system(size: 16))
                                .foregroundColor(BankingColors.primaryText)
                            
                            Spacer()
                            
                            if selectedCurrency == currency {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(BankingColors.accent)
                            }
                        }
                    }
                    .listRowBackground(BankingColors.secondaryBackground)
                }
                .listStyle(PlainListStyle())
                .background(BankingColors.background)
            }
            .navigationTitle("Выберите валюту")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(BankingColors.accent)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSettings())
    }
}