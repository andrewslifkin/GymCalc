import SwiftUI

@available(iOS 16.0, *)
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
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.automatic)
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
        Text(formattedValue)
            .font(.system(size: 48, weight: .medium))
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.smooth, value: value)
    }
    
    private var formattedValue: String {
        formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

extension StringProtocol {
    subscript(safe offset: Int) -> Character? {
        guard offset >= 0, offset < count else { return nil }
        return self[index(startIndex, offsetBy: offset)]
    }
}

// Calculator Input View
struct CalculatorInputView: View {
    @Binding var value: Double
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    init(value: Binding<Double>) {
        self._value = value
    }
    
    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }()
    
    @State private var displayValue: String = ""
    @State private var hasDecimalPoint = false
    
    // Standard calculator layout
    private let buttons: [[CalculatorButton]] = [
        [.seven, .eight, .nine],
        [.four, .five, .six],
        [.one, .two, .three],
        [.delete, .zero, .decimal]
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Keypad
            VStack(spacing: 12) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            CalculatorButtonView(button: button) {
                                buttonTapped(button)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                // Bottom row
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            buttonTapped(.clear)
                        }
                    } label: {
                        Text("C")
                            .font(.system(size: 24, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .foregroundColor(.white)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dismiss()
                        }
                    } label: {
                        Text("Done")
                            .font(.system(size: 20, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .onAppear {
            displayValue = formatter.string(from: NSNumber(value: value)) ?? "0"
        }
    }
    
    private func buttonTapped(_ button: CalculatorButton) {
        switch button {
        case .number(let num):
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                if displayValue == "0" {
                    displayValue = "\(num)"
                } else {
                    displayValue += "\(num)"
                }
                updateValue()
            }
            
        case .decimal:
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                if !hasDecimalPoint {
                    displayValue += "."
                    hasDecimalPoint = true
                }
            }
            
        case .clear:
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                displayValue = "0"
                hasDecimalPoint = false
                updateValue()
            }
            
        case .delete:
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                if displayValue.last == "." {
                    hasDecimalPoint = false
                }
                displayValue = String(displayValue.dropLast())
                if displayValue.isEmpty {
                    displayValue = "0"
                }
                updateValue()
            }
        }
    }
    
    private func updateValue() {
        if let number = formatter.number(from: displayValue) {
            value = number.doubleValue
        }
    }
}

private enum CalculatorButton: Hashable {
    case number(Int)
    case decimal
    case clear
    case delete
    
    static let zero = Self.number(0)
    static let one = Self.number(1)
    static let two = Self.number(2)
    static let three = Self.number(3)
    static let four = Self.number(4)
    static let five = Self.number(5)
    static let six = Self.number(6)
    static let seven = Self.number(7)
    static let eight = Self.number(8)
    static let nine = Self.number(9)
    
    var text: String {
        switch self {
        case .number(let num): return "\(num)"
        case .decimal: return "."
        case .clear: return "C"
        case .delete: return "⌫"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .number, .decimal, .delete:
            return Color(white: 0.22)
        case .clear:
            return .orange
        }
    }
    
    var foregroundColor: Color {
        return .white
    }
    
    var isSystemImage: Bool {
        if case .delete = self { return true }
        return false
    }
}

private struct CalculatorButtonView: View {
    let button: CalculatorButton
    let action: () -> Void
    @State private var isPressed = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            Group {
                if button.isSystemImage {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 20, weight: .medium))
                } else {
                    Text(button.text)
                        .font(.system(size: 28, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .foregroundColor(button.foregroundColor)
            .background(button.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black
        WeightInput(targetWeight: Binding.constant(213.25))
    }
} 