import SwiftUI
import GymCalc

struct PlateSelectionGrid: View {
    @EnvironmentObject private var calculator: Calculator
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @Binding var weightSuggestion: WeightSuggestion?
    @State private var showingAddPlateSheet = false
    @State private var newPlateWeight: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
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
                                        .fontWeight(.semibold)
                                        .foregroundColor(themeManager.textColor)
                                    Text(calculator.selectedUnit.symbol)
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                // Right side - Actions
                                HStack(spacing: 16) {
                                    if calculator.selectedPlateWeights.contains(weight) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 29/255, green: 29/255, blue: 29/255))
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(weight, specifier: "%.1f") \(calculator.selectedUnit.symbol) plate")
                        .accessibilityValue(calculator.selectedPlateWeights.contains(weight) ? "Selected" : "Not selected")
                        .accessibilityHint("Double tap to \(calculator.selectedPlateWeights.contains(weight) ? "unselect" : "select") this plate")
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if isCustomPlate(weight) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        calculator.removeCustomPlateWeight(weight)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(calculator.selectedPlateWeights.contains(weight) ? 
                                      themeManager.selectedItemColor : themeManager.cardColor)
                        )
                    }
                    
                    Button {
                        showingAddPlateSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                            Text("Add Custom Plate")
                                .font(.headline)
                                .foregroundColor(themeManager.textColor)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 12)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.cardColor)
                    )
                    .accessibilityHint("Double tap to add a new custom plate")
                    
                    Button {
                        calculator.resetPlates()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                            Text("Reset Plates to Default")
                                .font(.headline)
                                .foregroundColor(themeManager.textColor)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 12)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.cardColor)
                    )
                    .accessibilityHint("Double tap to reset all plates to default selection")
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Plate Management")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: 
                    Button("Done") {
                        weightSuggestion = calculator.checkWeightAchievability(targetWeight: calculator.targetWeight)
                        dismiss()
                    }
                    .foregroundColor(themeManager.accentColor)
                )
            }
        }
        .sheet(isPresented: $showingAddPlateSheet) {
            NavigationView {
                ZStack {
                    themeManager.backgroundColor.ignoresSafeArea()
                    
                    Form {
                        Section {
                            TextField("Weight Value", text: $newPlateWeight)
                                .keyboardType(.decimalPad)
                                .foregroundColor(themeManager.textColor)
                                .padding(.vertical, 10)
                                .font(.system(.body, design: .rounded))
                                .accessibilityHint("Enter the weight of your custom plate")
                            
                            Button {
                                addCustomPlate()
                            } label: {
                                Text("Add Plate")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 12)
                                    .background(themeManager.accentColor)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 6)
                            .accessibilityHint("Double tap to add the new custom plate")
                        } header: {
                            Text("Enter Plate Weight")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.secondaryTextColor)
                                .textCase(nil)
                                .padding(.top, 8)
                        }
                        .listRowBackground(themeManager.cardColor)
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Add Custom Plate")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddPlateSheet = false
                        }
                        .foregroundColor(themeManager.accentColor)
                        .accessibilityHint("Double tap to cancel adding a new plate")
                    )
                }
            }
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
        .presentationDetents([.height(CGFloat(min(64 * (calculator.availablePlates.count + 2) + 140, 600)))])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
    
    private func togglePlate(_ weight: Double) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if calculator.selectedPlateWeights.contains(weight) {
                calculator.selectedPlateWeights.removeAll { $0 == weight }
            } else {
                calculator.selectedPlateWeights.append(weight)
            }
            // HapticManager.shared.lightImpact()
        }
    }
    
    private func isCustomPlate(_ weight: Double) -> Bool {
        // Assuming plates > 45 are custom (based on SettingsView code)
        return weight > 45
    }
    
    private func addCustomPlate() {
        guard let weight = Double(newPlateWeight) else {
            print("❌ Invalid plate weight: \(newPlateWeight)")
            return
        }
        
        guard weight > 0 && weight <= 100 else {
            print("❌ Plate weight out of valid range: \(weight)")
            return
        }
        
        calculator.addCustomPlateWeight(weight)
        
        // Reset and dismiss sheet
        newPlateWeight = ""
        showingAddPlateSheet = false
    }
}

/*
#Preview {
    PlateSelectionGrid(weightSuggestion: .constant(nil))
        .environmentObject(Calculator())
        .environmentObject(ThemeManager())
} 
*/ 