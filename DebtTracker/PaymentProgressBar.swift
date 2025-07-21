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
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: height)
                
                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.75 {
            return .blue
        } else if progress >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

struct PaymentProgressView: View {
    let debt: Debt
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(Int(debt.paymentProgress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                if !userSettings.hideTotalAmount {
                    let totalPaid = debt.partialPayments.reduce(0) { $0 + $1.amount }
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.currencyCode = debt.currency
                    formatter.maximumFractionDigits = 0
                    let totalPaidFormatted = formatter.string(from: NSNumber(value: totalPaid)) ?? "\(Int(totalPaid)) \(debt.currencySymbol)"
                    Text("\(totalPaidFormatted) / \(debt.formattedAmount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            PaymentProgressBar(progress: debt.paymentProgress)
        }
    }
}

struct PaymentProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PaymentProgressBar(progress: 0.25)
            PaymentProgressBar(progress: 0.5)
            PaymentProgressBar(progress: 0.75)
            PaymentProgressBar(progress: 1.0)
        }
        .padding()
    }
}