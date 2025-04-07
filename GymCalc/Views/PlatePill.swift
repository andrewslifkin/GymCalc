import SwiftUI

struct PlatePill: View {
    @EnvironmentObject private var calculator: Calculator
    @Binding var plateWeight: Double
    @State private var isPressed = false
    
    private var isSelected: Bool {
        calculator.selectedPlateWeights.contains(plateWeight)
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                if isSelected {
                    calculator.selectedPlateWeights.removeAll { $0 == plateWeight }
                } else {
                    calculator.selectedPlateWeights.append(plateWeight)
                }
                calculator.cachedPlates = nil
                HapticManager.shared.lightImpact()
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(plateWeight, specifier: "%.1f")")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                Text("kg")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .blue : .gray)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true }, onRelease: { isPressed = false })
    }
}

// Helper for press animation
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

#Preview {
    HStack {
        PlatePill(plateWeight: .constant(2.5))
        PlatePill(plateWeight: .constant(5.0))
    }
    .padding()
    .background(Color.black)
    .environmentObject(Calculator())
}
