import SwiftUI

struct EquipmentSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var calculator: Calculator
    @Binding var weightSuggestion: WeightSuggestion?
    
    // Yellow accent color to match screenshot
    private let accentColor = Color(red: 235/255, green: 235/255, blue: 25/255)
    private let cardBackgroundColor = Color(white: 0.15)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    ForEach(calculator.availableBarbells.filter(\.isVisible)) { barbell in
                        Button {
                            selectEquipment(barbell)
                        } label: {
                            HStack {
                                // Left side - Equipment info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(barbell.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("\(barbell.weight.value, specifier: "%.1f") \(barbell.weight.unit.symbol)")
                                        .font(.subheadline)
                                        .foregroundColor(Color(white: 0.7))
                                }
                                
                                Spacer()
                                
                                // Right side - Actions
                                HStack(spacing: 16) {
                                    if calculator.selectedBarbell.id == barbell.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(accentColor)
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(cardBackgroundColor)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Select Equipment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(accentColor)
                    }
                }
            }
        }
        .presentationDetents([.height(CGFloat(min(72 * calculator.availableBarbells.filter(\.isVisible).count + 140, 600)))])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
    
    private func selectEquipment(_ barbell: Barbell) {
        calculator.selectedBarbell = barbell
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
        .preferredColorScheme(.dark)
} 