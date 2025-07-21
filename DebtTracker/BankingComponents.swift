import SwiftUI

// MARK: - Account Card Component
struct AccountCard: View {
    let accountName: String
    let balance: Double
    let currency: String
    let cardImage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(accountName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BankingColors.secondaryText)
            
            HStack(alignment: .bottom, spacing: 8) {
                Text(String(format: "%.0f", balance))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(BankingColors.primaryText)
                
                Text(currency)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(BankingColors.secondaryText)
                    .padding(.bottom, 4)
                
                Spacer()
                
                if let cardImage = cardImage {
                    Image(systemName: cardImage)
                        .font(.system(size: 40))
                        .foregroundColor(BankingColors.secondaryText)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .bankingCard()
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(BankingColors.primaryText)
                        .frame(width: 60, height: 60)
                        .background(BankingColors.tertiaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(BankingColors.accent)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BankingColors.primaryText)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(BankingColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Promo Card
struct PromoCard: View {
    let title: String
    let subtitle: String
    let percentage: String
    let backgroundColor: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(percentage)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(BankingColors.accent)
            }
            .padding()
        }
        .frame(height: 120)
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

// MARK: - Search Bar
struct BankingSearchBar: View {
    @Binding var searchText: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(BankingColors.secondaryText)
            
            TextField(placeholder, text: $searchText)
                .foregroundColor(BankingColors.primaryText)
                .accentColor(BankingColors.accent)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(BankingColors.secondaryText)
                }
            }
        }
        .padding(12)
        .background(BankingColors.tertiaryBackground)
        .cornerRadius(12)
    }
}

// MARK: - Section Header
struct BankingSectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(BankingColors.primaryText)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BankingColors.accent)
                }
            }
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let amount: String
    let isPositive: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(BankingColors.primaryText)
                .frame(width: 48, height: 48)
                .background(BankingColors.tertiaryBackground)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BankingColors.primaryText)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(BankingColors.secondaryText)
            }
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isPositive ? BankingColors.success : BankingColors.primaryText)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Payment Category Button
struct PaymentCategoryButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BankingColors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 90)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Transfer Type Button
struct TransferTypeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(BankingColors.primaryText)
                    .frame(width: 56, height: 56)
                    .background(BankingColors.primaryText.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(BankingColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(BankingColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Bar
struct BankingStatusBar: View {
    var body: some View {
        HStack {
            Text("16:40")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(BankingColors.primaryText)
            
            Image(systemName: "speaker.slash.fill")
                .font(.system(size: 14))
                .foregroundColor(BankingColors.primaryText)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                Image(systemName: "wifi")
                
                HStack(spacing: 2) {
                    Text("68")
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "battery.100")
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(BankingColors.success)
                .cornerRadius(12)
            }
            .font(.system(size: 14))
            .foregroundColor(BankingColors.primaryText)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}