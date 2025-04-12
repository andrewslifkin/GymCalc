import SwiftUI

struct PlateSelectionGrid: View {
    @EnvironmentObject private var calculator: Calculator
    @Environment(\.dismiss) private var dismiss
    @Binding var weightSuggestion: WeightSuggestion?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(calculator.availablePlates.sorted(), id: \.self) { weight in
                    Button {
                        togglePlate(weight)
                    } label: {
                        HStack {
                            // Left side - Weight info
                            HStack(spacing: 4) {
                                Text("\(weight, specifier: "%.1f")")
                                    .font(.headline)
                                Text("kg")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Right side - Actions
                            HStack(spacing: 16) {
                                if calculator.selectedPlateWeights.contains(weight) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
            .navigationTitle("Select Plates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        weightSuggestion = calculator.checkWeightAchievability(targetWeight: calculator.targetWeight)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(CGFloat(min(64 * calculator.availablePlates.count + 140, 600)))])
        .presentationDragIndicator(.visible)
    }
    
    private func togglePlate(_ weight: Double) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if calculator.selectedPlateWeights.contains(weight) {
                calculator.selectedPlateWeights.removeAll { $0 == weight }
            } else {
                calculator.selectedPlateWeights.append(weight)
            }
            HapticManager.shared.lightImpact()
        }
    }
}

#Preview {
    PlateSelectionGrid(weightSuggestion: .constant(nil))
        .environmentObject(Calculator())
} 