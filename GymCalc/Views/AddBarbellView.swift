import SwiftUI

struct AddBarbellView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    
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
        let initialBarbell = existingBarbell ?? Barbell(name: "", weight: Weight.kg(20), isCustom: true)
        
        // Debug info
        if let barbell = existingBarbell {
            print("Debug: AddBarbellView received barbell with name: \(barbell.name), isCustom: \(barbell.isCustom)")
        } else {
            print("Debug: AddBarbellView received nil barbell")
        }
        
        // Use underscore to initialize the @State properties directly
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
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                Form {
                    Section("Barbell Details") {
                        TextField("Barbell Name", text: $name)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .foregroundColor(themeManager.textColor)
                        
                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .foregroundColor(themeManager.textColor)
                            
                            Picker("Unit", selection: $weightUnit) {
                                ForEach(Unit.allCases, id: \.self) { unit in
                                    Text(unit.symbol).tag(unit)
                                }
                            }
                            .foregroundColor(themeManager.textColor)
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .listRowBackground(themeManager.cardColor)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(existingBarbell == nil ? "Add Barbell" : "Edit Barbell")
                .navigationBarItems(
                    leading: Button("Cancel", action: onCancel)
                        .foregroundColor(themeManager.accentColor),
                    trailing: Button("Save") {
                        guard isValidInput else { return }
                        
                        let newBarbell = Barbell(
                            id: existingBarbell?.id ?? UUID(),
                            name: name,
                            weight: weightUnit == .kg ? Weight.kg(Double(weight) ?? 0) : Weight.lbs(Double(weight) ?? 0),
                            isCustom: existingBarbell?.isCustom ?? true,
                            isVisible: true
                        )
                        
                        print("Debug: Saving barbell from form with name: \(name), isCustom: \(existingBarbell?.isCustom ?? true)")
                        
                        onSave(newBarbell)
                    }
                    .foregroundColor(themeManager.accentColor)
                )
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

#Preview {
    AddBarbellView(
        existingBarbell: Barbell(name: "Barbell", weight: Weight.kg(20), isCustom: true),
        onSave: { _ in },
        onCancel: {}
    )
}

#Preview("Editing Equipment Weight") {
    let sampleBarbell = Barbell(name: "Olympic Bar", weight: Weight.kg(20), isCustom: true)
    
    return AddBarbellView(
        existingBarbell: sampleBarbell,
        onSave: { _ in },
        onCancel: {}
    )
}
