import SwiftUI

struct PlatePill: View {
    @EnvironmentObject private var calculator: Calculator
    @Binding var plateWeight: Double
    
    private var isSelected: Bool {
        calculator.selectedPlateWeights.contains(plateWeight)
    }
    
    private func plateColor(_ weight: Double) -> Color {
        switch weight {
        case 2.5: return .blue
        case 5: return .green
        case 10: return .yellow
        case 15: return .orange
        case 20: return .red
        case 25: return .purple
        case 35: return .indigo
        case 45: return .pink
        default: return .blue
        }
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
                        .fill(plateColor(plateWeight).opacity(isSelected ? 0.3 : 0.1))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .strokeBorder(plateColor(plateWeight).opacity(isSelected ? 0.8 : 0.3), lineWidth: 2)
                        .frame(width: 70, height: 70)
                    
                    VStack(spacing: 2) {
                        Text(String(format: "%.1f", plateWeight))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                        
                        Text("kg")
                            .font(.caption2)
                            .foregroundColor(isSelected ? plateColor(plateWeight) : .gray)
                    }
                }
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

#Preview {
    HStack {
        PlatePill(plateWeight: .constant(20.0))
        PlatePill(plateWeight: .constant(10.0))
        PlatePill(plateWeight: .constant(5.0))
    }
    .padding()
    .background(Color.black)
    .environmentObject(Calculator())
}
