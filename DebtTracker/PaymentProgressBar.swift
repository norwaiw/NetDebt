import SwiftUI

struct PaymentProgressBar: View {
    let progress: Double
    let height: CGFloat
    
    init(progress: Double, height: CGFloat = 8) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(BankingColors.tertiaryBackground)
                    .frame(height: height)
                
                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(progressGradient)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
    
    private var progressGradient: LinearGradient {
        let color = progressColor
        return LinearGradient(
            gradient: Gradient(colors: [color, color.opacity(0.8)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return BankingColors.success
        } else if progress >= 0.75 {
            return Color(hex: "007AFF") // iOS blue
        } else if progress >= 0.5 {
            return BankingColors.warning
        } else {
            return BankingColors.accent
        }
    }
}

struct PaymentProgressView: View {
    let debt: Debt
    @EnvironmentObject var userSettings: UserSettings
    
    private var totalPaidFormatted: String {
        let totalPaid = debt.partialPayments.reduce(0) { $0 + $1.amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = debt.currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalPaid)) ?? "\(Int(totalPaid)) \(debt.currencySymbol)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(Int(debt.paymentProgress * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(BankingColors.primaryText)
                
                Spacer()
                
                if !userSettings.hideTotalAmount {
                    Text("\(totalPaidFormatted) / \(debt.formattedAmount)")
                        .font(.system(size: 12))
                        .foregroundColor(BankingColors.secondaryText)
                }
            }
            
            PaymentProgressBar(progress: debt.paymentProgress)
        }
        .padding(12)
        .background(BankingColors.secondaryBackground)
        .cornerRadius(12)
    }
}

struct PaymentProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BankingColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                PaymentProgressBar(progress: 0.25)
                PaymentProgressBar(progress: 0.5)
                PaymentProgressBar(progress: 0.75)
                PaymentProgressBar(progress: 1.0)
            }
            .padding()
        }
    }
}