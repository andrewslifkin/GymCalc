import Foundation
import SwiftUI
import Combine

@MainActor
final class EquipmentSettingsViewModel: ObservableObject {
    @Published var availableBarbells: [Barbell] = []
    @Published var availablePlates: [PlateSettingsItem] = []
    
    private let calculator: Calculator
    private var cancellables = Set<AnyCancellable>()
    
    init(calculator: Calculator) {
        self.calculator = calculator
        
        // Initial setup
        availableBarbells = calculator.availableBarbells
        availablePlates = calculator.availablePlateWeights.map { PlateSettingsItem(weight: $0) }
        
        // Reactive synchronization of barbells
        calculator.objectWillChange
            .sink { [weak self] _ in
                self?.availableBarbells = calculator.availableBarbells
            }
            .store(in: &cancellables)
        
        // Reactive synchronization of plates
        calculator.objectWillChange
            .sink { [weak self] _ in
                self?.availablePlates = calculator.availablePlateWeights.map { PlateSettingsItem(weight: $0) }
            }
            .store(in: &cancellables)
    }
    
    func updateSelectedPlates() {
        let enabledPlateWeights = availablePlates
            .filter { $0.isEnabled }
            .map { $0.weight }
        
        calculator.updateSelectedPlateWeights(enabledPlateWeights)
        synchronizePlates()
    }
    
    func addCustomPlate(weight: Double) -> Bool {
        guard 
            weight > 0,
            weight <= 100,  // Reasonable plate weight limit
            !availablePlates.contains(where: { $0.weight == weight })
        else {
            return false
        }
        
        let newPlate = PlateSettingsItem(weight: weight, isEnabled: true, isCustom: true)
        availablePlates.append(newPlate)
        
        // Add to calculator's available plate weights
        calculator.availablePlateWeights.append(weight)
        calculator.selectedPlateWeights.append(weight)
        
        updateSelectedPlates()
        synchronizePlates()
        
        return true
    }
    
    func deletePlates(at offsets: IndexSet) {
        let customPlateIndices = IndexSet(offsets.compactMap { 
            availablePlates[$0].isCustom ? $0 : nil 
        })
        
        let platesToRemove = customPlateIndices.map { availablePlates[$0].weight }
        
        availablePlates.remove(atOffsets: customPlateIndices)
        
        for plateWeight in platesToRemove {
            // Remove from calculator's available and selected plate weights
            calculator.availablePlateWeights.removeAll { $0 == plateWeight }
            calculator.selectedPlateWeights.removeAll { $0 == plateWeight }
        }
        
        updateSelectedPlates()
        synchronizePlates()
    }
    
    func saveBarbell(_ editedBarbell: Barbell) {
        // Directly update calculator's available barbells
        var updatedBarbells = calculator.availableBarbells
        updatedBarbells.append(editedBarbell)
        calculator.availableBarbells = updatedBarbells
        
        // Persist changes
        persistBarbells()
    }
    
    func removeBarbell(_ barbell: Barbell) {
        // Directly remove from calculator's available barbells
        calculator.availableBarbells = calculator.availableBarbells.filter { $0.id != barbell.id }
        
        // Persist changes
        persistBarbells()
    }
    
    func savePlate(_ plate: PlateSettingsItem) {
        // Directly update calculator's available plate weights
        var updatedPlates = calculator.availablePlateWeights
        if !updatedPlates.contains(plate.weight) {
            updatedPlates.append(plate.weight)
            calculator.availablePlateWeights = updatedPlates
            
            // Persist changes
            persistPlates()
        }
    }
    
    func removePlate(_ plate: PlateSettingsItem) {
        // Directly remove from calculator's available plate weights
        calculator.availablePlateWeights = calculator.availablePlateWeights.filter { $0 != plate.weight }
        
        // Persist changes
        persistPlates()
    }
    
    func synchronizePlates() {
        // Synchronize available plate weights with calculator
        calculator.availablePlateWeights = availablePlates.map { $0.weight }
    }
    
    func synchronizeSelectedBarbell() {
        // Ensure the selected barbell is valid or reset to default
        if !calculator.availableBarbells.contains(where: { $0.id == calculator.selectedBarbell.id }) {
            calculator.selectedBarbell = Barbell.standard
        }
    }
    
    func synchronizeCustomBarbells() {
        // Remove all existing custom barbells
        let currentCustomBarbells = calculator.customBarbells
        for barbell in currentCustomBarbells {
            calculator.removeCustomBarbell(barbell)
        }
        
        // Add new custom barbells from settings
        let newCustomBarbells = availableBarbells.filter { $0.isCustom }
        for barbell in newCustomBarbells {
            calculator.addCustomBarbell(barbell)
        }
        
        // If the current selected barbell was removed, reset to a default
        if !availableBarbells.contains(where: { $0.id == calculator.selectedBarbell.id }) {
            calculator.selectedBarbell = Barbell.standard
        }
        
        // Persist changes
        persistBarbells()
    }
    
    func persistBarbells() {
        // Persist barbells to UserDefaults
        Task {
            if let encoded = try? JSONEncoder().encode(availableBarbells) {
                UserDefaults.standard.set(encoded, forKey: Calculator.availableBarbellsKey)
            }
        }
    }
    
    func persistPlates() {
        // Persist plates to UserDefaults
        Task {
            if let encoded = try? JSONEncoder().encode(availablePlates.map { $0.weight }) {
                UserDefaults.standard.set(encoded, forKey: Calculator.availablePlatesKey)
            }
        }
    }
    
    func resetAvailablePlates() {
        availablePlates = [2.5, 5, 10, 15, 20, 25, 35, 45].map { 
            PlateSettingsItem(weight: $0) 
        }
        
        // Reset calculator's available and selected plate weights
        calculator.availablePlateWeights = [2.5, 5, 10, 15, 20, 25, 35, 45]
        calculator.selectedPlateWeights = [2.5, 5, 10, 15, 20, 25, 35, 45]
        
        updateSelectedPlates()
        synchronizePlates()
    }
}
