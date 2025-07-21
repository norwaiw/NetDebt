import SwiftUI

// MARK: - Banking Theme Colors
struct BankingColors {
    static let background = Color(hex: "1C1C1E")
    static let secondaryBackground = Color(hex: "2C2C2E")
    static let tertiaryBackground = Color(hex: "3A3A3C")
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "8E8E93")
    static let accent = Color(hex: "FF3B30")
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let cardBackground = Color(hex: "2C2C2E")
    static let buttonBackground = Color(hex: "3A3A3C")
}

// MARK: - Custom Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct BankingCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(BankingColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct BankingButtonStyle: ButtonStyle {
    let isProminent: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isProminent ? BankingColors.accent : BankingColors.buttonBackground)
            )
            .foregroundColor(BankingColors.primaryText)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Custom Components
struct BankingNavigationBar: View {
    let title: String
    let showBackButton: Bool
    let backAction: (() -> Void)?
    let rightButton: AnyView?
    
    init(title: String, showBackButton: Bool = false, backAction: (() -> Void)? = nil, rightButton: AnyView? = nil) {
        self.title = title
        self.showBackButton = showBackButton
        self.backAction = backAction
        self.rightButton = rightButton
    }
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: { backAction?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(BankingColors.primaryText)
                }
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(BankingColors.primaryText)
            
            Spacer()
            
            if let rightButton = rightButton {
                rightButton
            } else if showBackButton {
                // Placeholder to center the title
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .opacity(0)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(BankingColors.background)
    }
}

struct BankingTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs: [(icon: String, title: String, badge: Int?)] = [
        ("house.fill", "Главный", nil),
        ("creditcard.fill", "Платежи", nil),
        ("arrow.left.arrow.right", "Выгода", 1),
        ("clock.fill", "История", nil),
        ("message.fill", "Чаты", 33)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarItem(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    badge: tabs[index].badge,
                    isSelected: selectedTab == index
                )
                .onTapGesture {
                    selectedTab = index
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(BankingColors.background)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let badge: Int?
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? BankingColors.primaryText : BankingColors.secondaryText)
                
                if let badge = badge {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(BankingColors.accent)
                        .clipShape(Capsule())
                        .offset(x: 12, y: -8)
                }
            }
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isSelected ? BankingColors.primaryText : BankingColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Extensions
extension View {
    func bankingCard() -> some View {
        modifier(BankingCardStyle())
    }
    
    func bankingNavigationBar(title: String, showBackButton: Bool = false, backAction: (() -> Void)? = nil, rightButton: AnyView? = nil) -> some View {
        VStack(spacing: 0) {
            BankingNavigationBar(title: title, showBackButton: showBackButton, backAction: backAction, rightButton: rightButton)
            self
        }
    }
}