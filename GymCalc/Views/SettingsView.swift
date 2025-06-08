import SwiftUI
import Foundation

struct SettingsView: View {
    @EnvironmentObject private var calculator: Calculator
    @State private var showingAddPlateSheet = false
    @State private var showingAddBarbellSheet = false
    @State private var newPlateWeight: String = ""
    @State private var selectedBarbellToEdit: Barbell?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Unit switcher at the top, styled as a pill segmented control
                    unitPillSegmentedControl
                    
                    // Plates management card
                    platesManagementCard
                    
                    // Equipment management card
                    equipmentManagementCard
                    
                    // Quick actions card
                    quickActionsCard
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddPlateSheet) {
                addPlateSheet
            }
            .sheet(isPresented: $showingAddBarbellSheet) {
                AddBarbellView(
                    existingBarbell: selectedBarbellToEdit,
                    onSave: { newBarbell in
                        calculator.addAvailableBarbell(newBarbell)
                        showingAddBarbellSheet = false
                        selectedBarbellToEdit = nil
                    },
                    onCancel: {
                        showingAddBarbellSheet = false
                        selectedBarbellToEdit = nil
                    }
                )
            }
        }
    }
    
    // Pill-style segmented control for KG/LB (dark, floating, pill style)
    private var unitPillSegmentedControl: some View {
        HStack(spacing: 0) {
            ForEach([Unit.kg, Unit.lbs], id: \.self) { unit in
                Button(action: {
                    if calculator.selectedUnit != unit {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            calculator.toggleUnit()
                            HapticManager.shared.mediumImpact()
                        }
                    }
                }) {
                    Text(unit == .kg ? "KG" : "LB")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Group {
                                if calculator.selectedUnit == unit {
                                    Color(.systemGray3).opacity(0.7)
                                        .clipShape(Capsule())
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .opacity(calculator.selectedUnit == unit ? 1.0 : 0.7)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color(.systemGray5).opacity(0.85))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    // MARK: - Plates Management Card
    private var platesManagementCard: some View {
        SettingsCard {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "scalemass.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight Plates")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("\(enabledPlatesCount) of \(totalPlatesCount) plates enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingAddPlateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                
                // Plates list (changed from grid to list)
                VStack(spacing: 12) {
                    ForEach(calculator.availablePlateWeights, id: \.self) { plateWeight in
                        PlateRow(
                            weight: plateWeight,
                            unit: calculator.selectedUnit,
                            isEnabled: calculator.selectedPlateWeights.contains(plateWeight),
                            isCustom: isCustomPlate(plateWeight)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                calculator.updatePlateVisibility(for: plateWeight, isEnabled: !calculator.selectedPlateWeights.contains(plateWeight))
                                HapticManager.shared.lightImpact()
                            }
                        } onDelete: {
                            if isCustomPlate(plateWeight) {
                                withAnimation {
                                    calculator.removeCustomPlateWeight(plateWeight)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Equipment Management Card
    private var equipmentManagementCard: some View {
        SettingsCard {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Equipment")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Barbells and equipment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedBarbellToEdit = nil
                        showingAddBarbellSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                
                // Equipment list
                VStack(spacing: 12) {
                    ForEach(calculator.availableBarbells) { barbell in
                        EquipmentRow(barbell: barbell) {
                            withAnimation {
                                calculator.updateBarbellVisibility(for: barbell.id, isVisible: !barbell.isVisible)
                            }
                        } onEdit: {
                            if barbell.isCustom {
                                selectedBarbellToEdit = barbell
                                showingAddBarbellSheet = true
                            }
                        } onDelete: {
                            if barbell.isCustom {
                                calculator.removeAvailableBarbell(barbell)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions Card
    private var quickActionsCard: some View {
        SettingsCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Reset and restore defaults")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    ActionButton(
                        title: "Reset Plates",
                        subtitle: "Restore standard plates for \(calculator.selectedUnit.symbol)",
                        icon: "arrow.counterclockwise.circle.fill",
                        color: .orange
                    ) {
                        withAnimation {
                            calculator.resetPlates()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Add Plate Sheet
    private var addPlateSheet: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 16) {
                        Text("Add Custom Plate")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Enter the weight of your custom plate in \(calculator.selectedUnit == .kg ? "kilograms" : "pounds")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Input field
                    VStack(spacing: 12) {
                        TextField("Weight", text: $newPlateWeight)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                        
                        Text(calculator.selectedUnit.symbol)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            addCustomPlate()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Plate")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(newPlateWeight.isEmpty)
                        
                        Button {
                            showingAddPlateSheet = false
                            newPlateWeight = ""
                        } label: {
                            Text("Cancel")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Helper Methods
    private func addCustomPlate() {
        guard let weight = Double(newPlateWeight), weight > 0 else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            calculator.addCustomPlateWeight(weight)
            HapticManager.shared.successImpact()
        }
        
        showingAddPlateSheet = false
        newPlateWeight = ""
    }
    
    private func isCustomPlate(_ weight: Double) -> Bool {
        let standardPlates = Weight.standardPlateWeights[calculator.selectedUnit] ?? []
        return !standardPlates.contains(weight)
    }
    
    private var totalPlatesCount: Int {
        calculator.availablePlateWeights.count
    }
    
    private var enabledPlatesCount: Int {
        calculator.selectedPlateWeights.count
    }
}

// MARK: - Supporting Views

struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct PlateRow: View {
    let weight: Double
    let unit: Unit
    let isEnabled: Bool
    let isCustom: Bool
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Removed plate icon
            
            // Plate details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(weight, specifier: "%.1f") \(unit.symbol)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if isCustom {
                        Text("CUSTOM")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
            }
            
            // Toggle
            Toggle("", isOn: .constant(isEnabled))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .onTapGesture {
                    onToggle()
                }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            if isCustom {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct EquipmentRow: View {
    let barbell: Barbell
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Removed equipment icon
            
            // Equipment details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(barbell.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if barbell.isCustom {
                        Text("CUSTOM")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                
                Text("\(barbell.weight.value, specifier: "%.1f") \(barbell.weight.unit.symbol)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Toggle
            Toggle("", isOn: .constant(barbell.isVisible))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .orange))
                .onTapGesture {
                    onToggle()
                }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            if barbell.isCustom {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
            HapticManager.shared.mediumImpact()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension HapticManager {
    func successImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    SettingsView()
        .environmentObject(Calculator())
}

