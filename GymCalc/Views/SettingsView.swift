import SwiftUI
import Foundation

struct SettingsView: View {
    @EnvironmentObject private var calculator: Calculator
    @State private var showingAddPlateSheet = false
    @State private var newPlateWeight: String = ""
    @State private var availableBarbells: [Barbell] = []
    @State private var showingAddBarbellSheet = false
    @State private var selectedBarbellToEdit: Barbell?

    private func addCustomPlate() {
        guard 
            let weight = Double(newPlateWeight),
            weight > 45,  // Ensure it's a custom plate
            weight <= 100  // Reasonable plate weight limit
        else {
            return
        }
        
        withAnimation {
            calculator.addCustomPlateWeight(weight)
        }
        
        // Reset and dismiss sheet
        newPlateWeight = ""
        showingAddPlateSheet = false
    }
    
    private func deletePlates(at offsets: IndexSet) {
        // Filter and remove only custom plates (weight > 45)
        let platesToRemove = offsets.compactMap { index -> Double? in
            let plateWeight = calculator.availablePlateWeights[index]
            return plateWeight > 45 ? plateWeight : nil
        }
        
        withAnimation {
            for plateWeight in platesToRemove {
                calculator.removeCustomPlateWeight(plateWeight)
            }
        }
    }
    
    private func removeBarbell(_ barbell: Barbell) {
        calculator.removeAvailableBarbell(barbell)
    }
    
    private func saveBarbell(_ editedBarbell: Barbell) {
        // If barbell exists, update it
        if let index = calculator.availableBarbells.firstIndex(where: { $0.id == editedBarbell.id }) {
            calculator.availableBarbells[index] = editedBarbell
        } else {
            // Add new barbell
            calculator.availableBarbells.append(editedBarbell)
        }
        
        // Reset edit state
        selectedBarbellToEdit = nil
        showingAddBarbellSheet = false
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Available Plates") {
                    ForEach(calculator.availablePlateWeights, id: \.self) { plateWeight in
                        HStack(spacing: 12) {
                            Text("\(plateWeight, specifier: "%.1f")kg")
                                .font(.headline)
                                .foregroundColor(plateWeight > 45 ? .blue : .primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { calculator.selectedPlateWeights.contains(plateWeight) },
                                set: { newValue in
                                    withAnimation {
                                        calculator.updatePlateVisibility(for: plateWeight, isEnabled: newValue)
                                    }
                                }
                            ))
                            .labelsHidden()
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deletePlates)
                }
                
                Section("Barbells") {
                    ForEach(calculator.availableBarbells) { barbell in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(barbell.name)
                                    .font(.headline)
                                    .foregroundColor(barbell.isCustom ? .blue : .primary)
                                Text("\(barbell.weight.value, specifier: "%.1f") \(barbell.weight.unit.symbol)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { barbell.isVisible },
                                set: { newValue in
                                    withAnimation {
                                        calculator.updateBarbellVisibility(for: barbell.id, isVisible: newValue)
                                    }
                                }
                            ))
                            .labelsHidden()
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                removeBarbell(barbell)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                selectedBarbellToEdit = barbell
                                showingAddBarbellSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                
                Section {
                    Button(action: { 
                        showingAddPlateSheet = true 
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Custom Plate")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        calculator.resetPlates()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Plates to Default")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: { 
                        selectedBarbellToEdit = nil
                        showingAddBarbellSheet = true 
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Custom Equipment Weight")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: { 
                        selectedBarbellToEdit = nil
                        showingAddBarbellSheet = true 
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Custom Barbell")
                        }
                        .foregroundColor(.blue)
                    }
                } footer: {
                    Text("Customize your plates and equipment weights for precise calculations.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Equipment Settings")
            .sheet(isPresented: $showingAddPlateSheet) {
                NavigationView {
                    Form {
                        TextField("Plate Weight (kg)", text: $newPlateWeight)
                            .keyboardType(.decimalPad)
                        
                        Button("Add Plate") {
                            addCustomPlate()
                        }
                    }
                    .navigationTitle("Add Custom Plate")
                    .navigationBarItems(trailing: Button("Cancel") {
                        showingAddPlateSheet = false
                    })
                }
            }
            .sheet(isPresented: $showingAddBarbellSheet) {
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
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Calculator())
}
