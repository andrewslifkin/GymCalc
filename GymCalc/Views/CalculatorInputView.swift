import SwiftUI

public struct CalculatorInputView: View {
    @Binding var value: Double
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    public init(value: Binding<Double>) {
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
    
    public var body: some View {
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