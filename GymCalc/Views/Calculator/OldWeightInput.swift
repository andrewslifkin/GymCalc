import SwiftUI

struct OldWeightInput: View {
    @EnvironmentObject private var calculator: Calculator
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingCalculator = false
    
    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }()
    
    var body: some View {
        HStack(spacing: 24) {
            Button {
                withAnimation {
                    calculator.targetWeight = max(0, calculator.targetWeight - 1.25)
                }
            } label: {
                Image(systemName: "minus")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Button {
                showingCalculator = true
            } label: {
                Text(formatter.string(from: NSNumber(value: calculator.targetWeight)) ?? "0")
                    .frame(minWidth: 140)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .sheet(isPresented: $showingCalculator) {
                CalculatorInputView(value: $calculator.targetWeight)
                    .presentationDetents([.medium])
            }
            
            Button {
                withAnimation {
                    calculator.targetWeight = min(1000, calculator.targetWeight + 1.25)
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 12)
    }
} 