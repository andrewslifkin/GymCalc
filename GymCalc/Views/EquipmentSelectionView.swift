import SwiftUI

struct EquipmentSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var calculator: Calculator
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var weightSuggestion: WeightSuggestion?
    @State private var showingAddBarbellSheet = false
    @State private var selectedBarbellToEdit: Barbell?
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                List {
                    ForEach(calculator.availableBarbells) { barbell in
                        Button {
                            selectEquipment(barbell)
                        } label: {
                            HStack {
                                // Left side - Equipment info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(barbell.name)
                                        .font(.headline)
                                        .foregroundColor(themeManager.textColor)
                                    Text("\(barbell.weight.value, specifier: "%.1f") \(barbell.weight.unit.symbol)")
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                // Right side - Actions
                                if calculator.selectedBarbell.id == barbell.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(themeManager.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            if barbell.isCustom {
                                Button(role: .destructive) {
                                    removeBarbell(barbell)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            
                            Button {
                                editEquipment(barbell)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(themeManager.cardColor)
                    }
                    
                    Button {
                        selectedBarbellToEdit = nil
                        showingAddBarbellSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.accentColor)
                            Text("Add Equipment")
                                .foregroundColor(themeManager.textColor)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(themeManager.cardColor)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Equipment Management")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: 
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor)
                )
            }
        }
        .sheet(isPresented: $showingAddBarbellSheet, onDismiss: {
            // Only reset selectedBarbellToEdit here if needed
            print("Debug: Sheet dismissed")
        }) {
            AddBarbellView(
                existingBarbell: selectedBarbellToEdit,
                onSave: { newBarbell in
                    saveBarbell(newBarbell)
                },
                onCancel: {
                    showingAddBarbellSheet = false
                    selectedBarbellToEdit = nil
                }
            )
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .presentationDetents([.height(CGFloat(min(72 * calculator.availableBarbells.count + 140, 600)))])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
    
    private func selectEquipment(_ barbell: Barbell) {
        calculator.selectedBarbell = barbell
        weightSuggestion = calculator.checkWeightAchievability(targetWeight: calculator.targetWeight)
        dismiss()
    }
    
    private func removeBarbell(_ barbell: Barbell) {
        calculator.removeAvailableBarbell(barbell)
    }
    
    private func saveBarbell(_ editedBarbell: Barbell) {
        // Validate barbell before saving
        guard editedBarbell.weight.value > 0 else {
            print("❌ Invalid barbell weight")
            return
        }
        
        print("Debug: Saving barbell with name: \(editedBarbell.name), isCustom: \(editedBarbell.isCustom)")
        
        // Update or add barbell
        if calculator.availableBarbells.contains(where: { $0.id == editedBarbell.id }) {
            calculator.updateAvailableBarbell(editedBarbell)
        } else {
            calculator.addAvailableBarbell(editedBarbell)
        }
        
        // Reset edit state
        selectedBarbellToEdit = nil
        showingAddBarbellSheet = false
    }
    
    private func editEquipment(_ barbell: Barbell) {
        selectedBarbellToEdit = barbell
        print("Debug: Selected barbell to edit - \(barbell.name), isCustom: \(barbell.isCustom)")
        showingAddBarbellSheet = true
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
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
} 