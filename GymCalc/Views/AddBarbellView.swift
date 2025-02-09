import SwiftUI

struct AddBarbellView: View {
    @Environment(\.dismiss) private var dismiss
    
    let existingBarbell: Barbell?
    let onSave: (Barbell) -> Void
    let onCancel: () -> Void
    
    @State private var name: String
    @State private var weight: String
    @State private var weightUnit: Unit
    @State private var errorMessage: String?
    
    init(
        existingBarbell: Barbell? = nil,
        onSave: @escaping (Barbell) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.existingBarbell = existingBarbell
        self.onSave = onSave
        self.onCancel = onCancel
        
        // Initialize state from existing barbell or with default values
        let initialBarbell = existingBarbell ?? Barbell(name: "", weight: Weight(value: 20, unit: .kg), isCustom: true)
        
        _name = State(initialValue: initialBarbell.name)
        _weight = State(initialValue: String(format: "%.1f", initialBarbell.weight.value))
        _weightUnit = State(initialValue: initialBarbell.weight.unit)
    }
    
    private var isValidInput: Bool {
        guard let weightValue = Double(weight) else { 
            errorMessage = "Invalid weight"
            return false 
        }
        
        guard !name.isEmpty else {
            errorMessage = "Name cannot be empty"
            return false
        }
        
        guard weightValue > 0 && weightValue <= 200 else {
            errorMessage = "Weight must be between 0 and 200"
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Barbell Details") {
                    TextField("Barbell Name", text: $name)
                    
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $weightUnit) {
                            ForEach(Unit.allCases, id: \.self) { unit in
                                Text(unit.symbol).tag(unit)
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(existingBarbell == nil ? "Add Barbell" : "Edit Barbell")
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                },
                trailing: Button("Save") {
                    guard isValidInput else { return }
                    
                    let newBarbell = Barbell(
                        id: existingBarbell?.id ?? UUID(),
                        name: name,
                        weight: Weight(value: Double(weight) ?? 0, unit: weightUnit),
                        isCustom: true
                    )
                    
                    onSave(newBarbell)
                }
            )
        }
    }
}

#Preview {
    AddBarbellView(
        existingBarbell: Barbell(name: "Barbell", weight: Weight(value: 20, unit: .kg), isCustom: true),
        onSave: { _ in },
        onCancel: {}
    )
}

#Preview("Editing Equipment Weight") {
    let sampleBarbell = Barbell(name: "Olympic Bar", weight: Weight(value: 20, unit: .kg), isCustom: true)
    
    return AddBarbellView(
        existingBarbell: sampleBarbell,
        onSave: { _ in },
        onCancel: {}
    )
}
