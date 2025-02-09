import SwiftUI
import Foundation

struct SettingsView: View {
    @EnvironmentObject private var calculator: Calculator
    @State private var availablePlates: [PlateSettingsItem]
    @State private var showingAddPlateSheet = false
    @State private var newPlateWeight: String = ""
    @State private var availableBarbells: [Barbell] = []
    @State private var showingAddBarbellSheet = false
    @State private var selectedBarbellToEdit: Barbell?
    
    init() {
        let calculator = Calculator()
        self._availablePlates = State(initialValue: 
            [2.5, 5, 10, 15, 20, 25, 35, 45].map { 
                PlateSettingsItem(weight: $0) 
            }
        )
        
        self._availableBarbells = State(initialValue: calculator.availableBarbells)
    }
    
    private func updateSelectedPlates() {
        let enabledPlateWeights = availablePlates
            .filter { $0.isEnabled }
            .map { $0.weight }
        
        calculator.updateSelectedPlateWeights(enabledPlateWeights)
    }
    
    private func addCustomPlate() {
        guard 
            let weight = Double(newPlateWeight),
            weight > 0,
            weight <= 100,  // Reasonable plate weight limit
            !availablePlates.contains(where: { $0.weight == weight })
        else {
            return
        }
        
        // Use a single mutation to update state
        withAnimation {
            let newPlate = PlateSettingsItem(weight: weight, isEnabled: true, isCustom: true)
            availablePlates.append(newPlate)
            calculator.addAvailablePlateWeight(weight)
            updateSelectedPlates()
        }
        
        // Reset and dismiss sheet
        newPlateWeight = ""
        showingAddPlateSheet = false
    }
    
    private func deletePlates(at offsets: IndexSet) {
        // Create a new IndexSet with only custom plate indices
        let customPlateIndices = IndexSet(offsets.compactMap { 
            availablePlates[$0].isCustom ? $0 : nil 
        })
        
        // Remove custom plates
        let platesToRemove = customPlateIndices.map { availablePlates[$0].weight }
        
        withAnimation {
            availablePlates.remove(atOffsets: customPlateIndices)
            
            for plateWeight in platesToRemove {
                calculator.removeAvailablePlateWeight(plateWeight)
            }
            
            updateSelectedPlates()
        }
    }
    
    // New barbell management methods
    private func removeBarbell(_ barbell: Barbell) {
        calculator.removeAvailableBarbell(barbell)
        availableBarbells.removeAll { $0.id == barbell.id }
        
        // Persist changes
        Task {
            if let encoded = try? JSONEncoder().encode(availableBarbells) {
                UserDefaults.standard.set(encoded, forKey: Calculator.availableBarbellsKey)
            }
        }
    }
    
    private func startEditingBarbell(_ barbell: Barbell) {
        selectedBarbellToEdit = barbell
        showingAddBarbellSheet = true
    }
    
    private func saveBarbell(_ editedBarbell: Barbell) {
        // Remove the old barbell if it exists
        if let index = availableBarbells.firstIndex(where: { $0.id == editedBarbell.id }) {
            availableBarbells.remove(at: index)
        }
        
        // Add the new or edited barbell
        availableBarbells.append(editedBarbell)
        
        // Update calculator's available barbells
        calculator.availableBarbells = availableBarbells
        
        // Persist changes
        Task {
            if let encoded = try? JSONEncoder().encode(availableBarbells) {
                UserDefaults.standard.set(encoded, forKey: Calculator.availableBarbellsKey)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Available Plates") {
                    ForEach($availablePlates) { $plateItem in
                        HStack(spacing: 12) {
                            Text("\(plateItem.weight, specifier: "%.1f")kg")
                                .font(.headline)
                                .foregroundColor(plateItem.isCustom ? .blue : .primary)
                            
                            Spacer()
                            
                            // Enable/disable toggle
                            Toggle("", isOn: Binding(
                                get: { plateItem.isEnabled },
                                set: { newValue in
                                    plateItem.isEnabled = newValue
                                    updateSelectedPlates()
                                }
                            ))
                            .labelsHidden()
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deletePlates)
                }
                
                Section("Equipment Weight") {
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
                                startEditingBarbell(barbell)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                
                Section {
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
                        showingAddPlateSheet = true 
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Custom Plate")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        calculator.resetAvailablePlateWeights()
                        availablePlates = [2.5, 5, 10, 15, 20, 25, 35, 45].map { 
                            PlateSettingsItem(weight: $0) 
                        }
                        updateSelectedPlates()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Plates to Default")
                        }
                        .foregroundColor(.red)
                    }
                } footer: {
                    Text("Customize your plates and equipment weights for precise calculations.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Equipment Settings")
            .sheet(isPresented: $showingAddBarbellSheet, onDismiss: {
                selectedBarbellToEdit = nil
            }) {
                AddBarbellView(
                    existingBarbell: selectedBarbellToEdit,
                    onSave: { newBarbell in
                        saveBarbell(newBarbell)
                        showingAddBarbellSheet = false
                    },
                    onCancel: {
                        showingAddBarbellSheet = false
                    }
                )
            }
            .sheet(isPresented: $showingAddPlateSheet) {
                NavigationView {
                    Form {
                        TextField("Plate Weight (kg)", text: $newPlateWeight)
                            .keyboardType(.decimalPad)
                    }
                    .navigationTitle("Add Custom Plate")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddPlateSheet = false
                            newPlateWeight = ""
                        },
                        trailing: Button("Add") {
                            addCustomPlate()
                        }
                        .disabled(newPlateWeight.isEmpty || Double(newPlateWeight) == nil)
                    )
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Calculator())
}
