import SwiftUI

struct PlatePill: View {
    @EnvironmentObject private var calculator: Calculator
    @Binding var plateWeight: Double
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation {
                // Toggle plate selection
                if calculator.selectedPlateWeights.contains(plateWeight) {
                    calculator.selectedPlateWeights.removeAll { $0 == plateWeight }
                } else {
                    calculator.selectedPlateWeights.append(plateWeight)
                }
                
                // Invalidate cache to force recalculation
                calculator.cachedPlates = nil
                
                HapticManager.shared.lightImpact()
            }
        } label: {
            Text("\(plateWeight, specifier: "%.1f")kg")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(minWidth: 80)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    calculator.selectedPlateWeights.contains(plateWeight) 
                    ? Color.blue.opacity(0.1) 
                    : Color.gray.opacity(0.1)
                )
                .foregroundColor(
                    calculator.selectedPlateWeights.contains(plateWeight) 
                    ? .blue 
                    : .gray
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            calculator.selectedPlateWeights.contains(plateWeight) 
                            ? Color.blue.opacity(0.3) 
                            : Color.gray.opacity(0.2), 
                            lineWidth: 1
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressAction {
            isPressed = $0
        }
    }
}

// Custom extension to add press state to buttons
extension View {
    func pressAction(onPress: @escaping (Bool) -> Void) -> some View {
        self.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress(true) }
                .onEnded { _ in onPress(false) }
        )
    }
}
