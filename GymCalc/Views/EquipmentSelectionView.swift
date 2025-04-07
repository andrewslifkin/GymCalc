import SwiftUI

struct EquipmentSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var calculator: Calculator
    @Binding var weightSuggestion: WeightSuggestion?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(calculator.availableBarbells.filter(\.isVisible)) { barbell in
                    Button {
                        selectEquipment(barbell)
                    } label: {
                        HStack {
                            Image(systemName: getEquipmentIcon(for: barbell.name))
                                .font(.title2)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(barbell.name)
                                    .font(.body)
                                
                                Text("\(barbell.weight.value, specifier: "%.1f") \(barbell.weight.unit.symbol)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if calculator.selectedBarbell.id == barbell.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func selectEquipment(_ barbell: Barbell) {
        calculator.selectedBarbell = barbell
        // Recalculate weight suggestion with new equipment
        weightSuggestion = calculator.checkWeightAchievability(targetWeight: calculator.targetWeight)
        dismiss()
    }
    
    private func getEquipmentIcon(for name: String) -> String {
        switch name.lowercased() {
        case let name where name.contains("olympic"):
            return "figure.strengthtraining.traditional"
        case let name where name.contains("ez curl"):
            return "figure.arm.curl"
        case let name where name.contains("trap"):
            return "figure.strengthtraining.traditional"
        case let name where name.contains("safety squat"):
            return "figure.strengthtraining.traditional"
        case let name where name.contains("swiss"):
            return "figure.strengthtraining.traditional"
        case let name where name.contains("leg press"):
            return "figure.leg.press"
        case let name where name.contains("smith"):
            return "figure.strengthtraining.traditional"
        case let name where name.contains("cable"):
            return "figure.strengthtraining.cables"
        default:
            return "dumbbell"
        }
    }
}

#Preview {
    EquipmentSelectionView(weightSuggestion: .constant(nil))
        .environmentObject(Calculator())
} 