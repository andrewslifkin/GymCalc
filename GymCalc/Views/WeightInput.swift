import SwiftUI

@available(iOS 16.0, *)
struct WeightInput: View {
    @EnvironmentObject private var themeManager: ThemeManager
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
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .foregroundColor(themeManager.iconColor)
                    .background(
                        Circle()
                            .fill(themeManager.cardColor)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Decrease weight")
            
            // Weight display
            Button {
                showingCalculator = true
            } label: {
                HStack(spacing: 0) {
                    Spacer()
                    NumberView(value: targetWeight, previousValue: previousWeight, isAnimating: $isAnimating)
                        .foregroundStyle(themeManager.textColor)
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
            .accessibilityLabel("Current weight \(String(format: "%.1f", targetWeight))")
            .accessibilityHint("Double tap to open numeric keypad")
            .sheet(isPresented: $showingCalculator) {
                CalculatorInputView(value: $targetWeight)
                    .environmentObject(themeManager)
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
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .foregroundColor(themeManager.iconColor)
                    .background(
                        Circle()
                            .fill(themeManager.cardColor)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Increase weight")
        }
        .foregroundStyle(themeManager.textColor)
    }
}

struct NumberView: View {
    @EnvironmentObject private var themeManager: ThemeManager
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
            .font(.system(size: 48, weight: .semibold, design: .rounded))
            .foregroundColor(themeManager.textColor)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.smooth, value: value)
            .accessibilityHidden(true) // We provide this text via the parent's accessibilityLabel
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
    @EnvironmentObject private var themeManager: ThemeManager
    
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
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                // Display area
                HStack {
                    Spacer()
                    Text(displayValue)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(themeManager.textColor)
                        .monospacedDigit()
                        .padding()
                }
                
                // Keypad
                VStack(spacing: 12) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { button in
                                CalculatorButtonView(button: button, themeManager: themeManager) {
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
                                .background(themeManager.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
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
    let themeManager: ThemeManager
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // HapticManager.shared.lightImpact() 
            action()
        }) {
            buttonLabel
        }
        // .buttonStyle(ScaleButtonStyle())
    }
    
    // Button style based on type
    private var buttonLabel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(buttonColor)
                .shadow(color: isPressed ? Color.clear : Color.black.opacity(0.1),
                       radius: 4, x: 0, y: 4)
                .frame(height: 64)
            
            // Button label
            buttonContent
                .foregroundColor(contentColor)
                .font(.system(size: 24, weight: .medium))
        }
    }
    
    private var buttonColor: Color {
        switch button {
        case .clear:
            return .red
        case .delete:
            return themeManager.currentTheme == .light ? Color.gray.opacity(0.3) : Color.gray.opacity(0.5)
        default:
            return themeManager.currentTheme == .light ? themeManager.cardColor : Color.gray.opacity(0.2)
        }
    }
    
    private var contentColor: Color {
        switch button {
        case .clear:
            return .white
        default:
            return themeManager.textColor
        }
    }
    
    private var buttonContent: some View {
        switch button {
        case .number(let num):
            return AnyView(Text("\(num)"))
        case .decimal:
            return AnyView(Text("."))
        case .delete:
            return AnyView(Image(systemName: "delete.left"))
        case .clear:
            return AnyView(Text("C"))
        }
    }
}

#Preview {
    ZStack {
        Color.black
        WeightInput(targetWeight: Binding.constant(213.25))
    }
} 