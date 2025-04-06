import SwiftUI

struct WeightInput: View {
    @Binding var targetWeight: Double
    @State private var showingCalculator = false
    @State private var previousWeight: Double = 0
    @State private var isAnimating = false
    
    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }()
    
    var body: some View {
        HStack(spacing: 0) {
            // Minus button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    targetWeight = max(0, targetWeight - 1.25)
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 24, weight: .medium))
                    .frame(width: 56, height: 56)
                    .background(Color(white: 0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            // Weight display
            Button {
                showingCalculator = true
            } label: {
                HStack(spacing: 0) {
                    Spacer()
                    NumberView(value: targetWeight, previousValue: previousWeight, isAnimating: $isAnimating)
                        .frame(minWidth: 140)
                        .onChange(of: targetWeight) { oldValue, newValue in
                            previousWeight = oldValue
                            isAnimating = true
                            // Reset animation flag after animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isAnimating = false
                            }
                        }
                    Spacer()
                }
                .frame(height: 56)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showingCalculator) {
                CalculatorInputView(value: $targetWeight)
            }
            
            // Plus button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    targetWeight += 1.25
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .frame(width: 56, height: 56)
                    .background(Color(white: 0.15))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)
    }
}

struct NumberView: View {
    let value: Double
    let previousValue: Double
    @Binding var isAnimating: Bool
    
    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }()
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ForEach(Array(formattedValue.enumerated()), id: \.offset) { index, char in
                if char == "." {
                    Text(String(char))
                        .font(.system(size: 48, weight: .medium))
                        .opacity(0.5)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    DigitView(
                        current: String(char),
                        previous: String(formattedPreviousValue[safe: index] ?? " "),
                        isAnimating: isAnimating,
                        trend: value > previousValue ? 1 : -1
                    )
                }
            }
        }
        .monospacedDigit()
    }
    
    private var formattedValue: String {
        formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private var formattedPreviousValue: String {
        formatter.string(from: NSNumber(value: previousValue)) ?? "0"
    }
}

struct DigitView: View {
    let current: String
    let previous: String
    let isAnimating: Bool
    let trend: Int
    
    var body: some View {
        ZStack {
            Text(current)
                .font(.system(size: 48, weight: .medium))
                .opacity(isAnimating ? 0 : 1)
                .offset(y: isAnimating ? CGFloat(trend) * 20 : 0)
            
            Text(previous)
                .font(.system(size: 48, weight: .medium))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : CGFloat(-trend) * 20)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isAnimating)
    }
}

extension StringProtocol {
    subscript(safe offset: Int) -> Character? {
        guard offset >= 0, let i = index(startIndex, offsetBy: offset, limitedBy: endIndex) else { return nil }
        return self[i]
    }
}

#Preview {
    ZStack {
        Color.black
        WeightInput(targetWeight: .constant(213.25))
    }
} 