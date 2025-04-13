import SwiftUI

struct PlateSelectionGrid: View {
    @EnvironmentObject private var calculator: Calculator
    @Environment(\.dismiss) private var dismiss
    @Binding var weightSuggestion: WeightSuggestion?
    
    // Yellow accent color to match screenshot
    private let accentColor = Color(red: 235/255, green: 235/255, blue: 25/255)
    private let cardBackgroundColor = Color(white: 0.15)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
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
                                        .foregroundColor(.white)
                                    Text(calculator.selectedUnit.symbol)
                                        .font(.subheadline)
                                        .foregroundColor(Color(white: 0.7))
                                }
                                
                                Spacer()
                                
                                // Right side - Actions
                                HStack(spacing: 16) {
                                    if calculator.selectedPlateWeights.contains(weight) {
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
                .navigationTitle("Select Plates")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            weightSuggestion = calculator.checkWeightAchievability(targetWeight: calculator.targetWeight)
                            dismiss()
                        }
                        .foregroundColor(accentColor)
                    }
                }
            }
        }
        .presentationDetents([.height(CGFloat(min(64 * calculator.availablePlates.count + 140, 600)))])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
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