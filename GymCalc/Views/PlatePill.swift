import SwiftUI

struct PlatePill: View {
    @EnvironmentObject private var calculator: Calculator
    @Binding var plateWeight: Double
    
    private var isSelected: Bool {
        calculator.selectedPlateWeights.contains(plateWeight)
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if isSelected {
                    calculator.selectedPlateWeights.removeAll { $0 == plateWeight }
                } else {
                    calculator.selectedPlateWeights.append(plateWeight)
                }
                HapticManager.shared.lightImpact()
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Text(String(format: "%.1f", plateWeight))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text("kg")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

#Preview {
    PlatePill(plateWeight: .constant(20.0))
        .environmentObject(Calculator())
}
