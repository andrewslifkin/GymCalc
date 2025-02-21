import Foundation

enum CalculatorMode: String, CaseIterable {
    case plates = "Plates"
    case maxRep = "1RM"
}

struct Barbell: Identifiable, Codable, Equatable {
    var id: UUID
    let name: String
    let weight: Weight
    let isCustom: Bool
    var isVisible: Bool
    
    init(id: UUID = UUID(), name: String, weight: Weight, isCustom: Bool = false, isVisible: Bool = true) {
        self.id = id
        self.name = name
        self.weight = weight
        self.isCustom = isCustom
        self.isVisible = isVisible
    }
    
    static func == (lhs: Barbell, rhs: Barbell) -> Bool {
        lhs.id == rhs.id
    }
    
    static let standard = Barbell(
        name: "Olympic/Men's 20kg",
        weight: Weight(value: 20, unit: .kg) // 45 lbs
    )
    
    static let presets: [Barbell] = [
        // Olympic Bars
        Barbell(name: "Olympic Bar (Men's)", weight: Weight(value: 20, unit: .kg)),
        Barbell(name: "Olympic Bar (Women's)", weight: Weight(value: 15, unit: .kg)),
        
        // Specialty Bars
        Barbell(name: "EZ Curl Bar", weight: Weight(value: 10, unit: .kg)),
        Barbell(name: "Trap Bar", weight: Weight(value: 25, unit: .kg)),
        Barbell(name: "Safety Squat Bar", weight: Weight(value: 25, unit: .kg)),
        
        // Fixed Barbells
        Barbell(name: "Fixed Barbell (10kg)", weight: Weight(value: 10, unit: .kg)),
        Barbell(name: "Fixed Barbell (15kg)", weight: Weight(value: 15, unit: .kg)),
        Barbell(name: "Fixed Barbell (20kg)", weight: Weight(value: 20, unit: .kg)),
        
        // Specialty Equipment
        Barbell(name: "Swiss Bar", weight: Weight(value: 20, unit: .kg)),
        Barbell(name: "Cambered Bar", weight: Weight(value: 25, unit: .kg))
    ]
}

@MainActor
final class Calculator: ObservableObject {
    static let customBarbellsKey = "customBarbells"
    static let availablePlatesKey = "availablePlates"
    static let selectedPlatesKey = "selectedPlates"
    static let availableBarbellsKey = "availableBarbells"
    
    @Published private(set) var customBarbells: [Barbell] = [] {
        didSet {
            Task {
                if let encoded = try? JSONEncoder().encode(customBarbells) {
                    UserDefaults.standard.set(encoded, forKey: Self.customBarbellsKey)
                }
            }
        }
    }
    
    @Published var availablePlates: [Double] = [2.5, 5, 10, 15, 20, 25, 35, 45] {
        didSet {
            Task {
                if let encoded = try? JSONEncoder().encode(availablePlates) {
                    UserDefaults.standard.set(encoded, forKey: Self.availablePlatesKey)
                }
                // Sync with availablePlateWeights
                availablePlateWeights = availablePlates
            }
        }
    }
    
    private var _availableBarbells: [Barbell] = []
    
    var availableBarbells: [Barbell] {
        get {
            if _availableBarbells.isEmpty {
                return Barbell.presets
            }
            return _availableBarbells
        }
        set {
            _availableBarbells = newValue.isEmpty ? Barbell.presets : newValue
            
            Task {
                if let encoded = try? JSONEncoder().encode(_availableBarbells) {
                    UserDefaults.standard.set(encoded, forKey: Self.availableBarbellsKey)
                }
            }
        }
    }
    
    @Published var availablePlateWeights: [Double] = [2.5, 5, 10, 15, 20, 25, 35, 45]
    @Published var selectedPlateWeights: [Double] = [2.5, 5, 10, 15, 20, 25, 35, 45]
    
    // MARK: - Custom Barbell Management
    func addCustomBarbell(_ barbell: Barbell) {
        customBarbells.append(barbell)
    }
    
    func removeCustomBarbell(_ barbell: Barbell) {
        customBarbells.removeAll { $0.id == barbell.id }
        if selectedBarbell.id == barbell.id {
            selectedBarbell = .standard
        }
    }
    
    // MARK: - Available Barbell Management
    func addAvailableBarbell(_ barbell: Barbell) {
        // Prevent duplicate barbells
        guard !availableBarbells.contains(where: { $0.id == barbell.id }) else {
            print("❌ Barbell already exists")
            return
        }
        
        // Add the barbell
        availableBarbells.append(barbell)
        
        // Persist changes
        Task {
            do {
                let encoder = JSONEncoder()
                let encodedBarbells = try encoder.encode(availableBarbells)
                UserDefaults.standard.set(encodedBarbells, forKey: Self.availableBarbellsKey)
                
                // Ensure UI updates on main thread
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
                print("✅ Added barbell: \(barbell.name)")
            } catch {
                print("❌ Error encoding barbell: \(error)")
            }
        }
    }
    
    func updateAvailableBarbell(_ barbell: Barbell) {
        // Find and update the barbell
        if let index = availableBarbells.firstIndex(where: { $0.id == barbell.id }) {
            availableBarbells[index] = barbell
            
            // Persist changes
            Task {
                do {
                    let encoder = JSONEncoder()
                    let encodedBarbells = try encoder.encode(availableBarbells)
                    UserDefaults.standard.set(encodedBarbells, forKey: Self.availableBarbellsKey)
                    
                    // Ensure UI updates on main thread
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                    
                    print("✅ Updated barbell: \(barbell.name)")
                } catch {
                    print("❌ Error encoding barbell: \(error)")
                }
            }
        } else {
            // If not found, add as a new barbell
            addAvailableBarbell(barbell)
        }
    }
    
    func removeAvailableBarbell(_ barbell: Barbell) {
        // Prevent removing all barbells
        guard availableBarbells.count > 1 else {
            print("❌ Cannot remove the last barbell")
            return
        }
        
        // Prevent removing non-custom barbells from presets
        guard barbell.isCustom else {
            print("❌ Cannot remove preset barbell")
            return
        }
        
        // Remove the barbell
        availableBarbells.removeAll { $0.id == barbell.id }
        
        // If the current selected barbell is removed, select the first available
        if selectedBarbell.id == barbell.id {
            selectedBarbell = availableBarbells.first ?? .standard
        }
        
        // Persist changes
        Task {
            do {
                let encoder = JSONEncoder()
                let encodedBarbells = try encoder.encode(availableBarbells)
                UserDefaults.standard.set(encodedBarbells, forKey: Self.availableBarbellsKey)
                
                // Ensure UI updates on main thread
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
                print("✅ Removed barbell: \(barbell.name)")
            } catch {
                print("❌ Error encoding barbell removal: \(error)")
            }
        }
    }
    
    func updateBarbellVisibility(for barbellId: UUID, isVisible: Bool) {
        guard let index = availableBarbells.firstIndex(where: { $0.id == barbellId }) else {
            return
        }
        
        // Ensure at least one barbell remains visible
        let visibleBarbellsCount = availableBarbells.filter { $0.isVisible }.count
        if !isVisible && visibleBarbellsCount <= 1 {
            return
        }
        
        // Update barbell visibility
        var updatedBarbells = availableBarbells
        updatedBarbells[index].isVisible = isVisible
        availableBarbells = updatedBarbells
        
        // If current selected barbell becomes invisible, select a visible one
        if !selectedBarbell.isVisible {
            selectedBarbell = availableBarbells.first(where: { $0.isVisible }) ?? .standard
        }
        
        // Persist changes and notify observers
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                let encodedBarbells = try encoder.encode(availableBarbells)
                UserDefaults.standard.set(encodedBarbells, forKey: Self.availableBarbellsKey)
                
                // Ensure UI updates
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            } catch {
                print("Error encoding barbells: \(error)")
            }
        }
    }

    // Modify initialization to handle visibility more robustly
    init() {
        // Default plate weights
        let defaultPlates: [Double] = [2.5, 5, 10, 15, 20, 25, 35, 45]
        
        // Try to load barbells from UserDefaults first
        if let data = UserDefaults.standard.data(forKey: Self.availableBarbellsKey),
           let decoded = try? JSONDecoder().decode([Barbell].self, from: data) {
            _availableBarbells = decoded
        } else {
            // If no saved data, use presets with default visibility
            _availableBarbells = Barbell.presets.map { 
                var barbell = $0
                barbell.isVisible = true
                return barbell
            }
        }
        
        // Ensure at least one barbell is visible
        if !_availableBarbells.contains(where: { $0.isVisible }) {
            _availableBarbells[0].isVisible = true
        }
        
        // Load custom barbells
        if let data = UserDefaults.standard.data(forKey: Self.customBarbellsKey),
           let decoded = try? JSONDecoder().decode([Barbell].self, from: data) {
            self.customBarbells = decoded
        }
        
        // Load plate weights with fallback to default
        if let data = UserDefaults.standard.data(forKey: Self.availablePlatesKey),
           let decoded = try? JSONDecoder().decode([Double].self, from: data),
           !decoded.isEmpty {
            self.availablePlates = decoded
            self.availablePlateWeights = decoded
            
            // Load selected plates separately
            if let selectedData = UserDefaults.standard.data(forKey: Self.selectedPlatesKey),
               let selectedDecoded = try? JSONDecoder().decode([Double].self, from: selectedData),
               !selectedDecoded.isEmpty {
                self.selectedPlateWeights = selectedDecoded.filter { decoded.contains($0) }
            } else {
                self.selectedPlateWeights = decoded
            }
        } else {
            // Use default plates if no saved data
            self.availablePlates = defaultPlates
            self.availablePlateWeights = defaultPlates
            self.selectedPlateWeights = defaultPlates
        }
        
        // Ensure selected barbell is visible
        if !selectedBarbell.isVisible {
            selectedBarbell = _availableBarbells.first(where: { $0.isVisible }) ?? .standard
        }
        
        // Validate and correct state
        validateState()
    }
    
    private func validateState() {
        // Ensure at least one plate is selected
        if selectedPlateWeights.isEmpty {
            selectedPlateWeights = [45.0]  // Default to 45 lbs/kg
        }
        
        // Ensure all selected plates are in available plates
        selectedPlateWeights = selectedPlateWeights.filter { availablePlates.contains($0) }
    }
    
    func resetPlates() {
        let defaultPlates: [Double] = [2.5, 5, 10, 15, 20, 25, 35, 45]
        
        // Reset available and selected plate weights
        availablePlates = defaultPlates
        availablePlateWeights = defaultPlates
        selectedPlateWeights = defaultPlates
        
        // Persist changes
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                
                // Save both available and selected plates
                let encodedAvailable = try encoder.encode(availablePlates)
                let encodedSelected = try encoder.encode(selectedPlateWeights)
                UserDefaults.standard.set(encodedAvailable, forKey: Self.availablePlatesKey)
                UserDefaults.standard.set(encodedSelected, forKey: Self.selectedPlatesKey)
                
                // Trigger UI update
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            } catch {
                print("Error encoding plates: \(error)")
            }
        }
    }
    
    // MARK: - Private Cache Properties
    private var cachedMax: Double?
    private var cachedBreakdown: [RepPercentage]?
    internal var cachedPlates: [PlateCount]?
    private var lastTargetWeight: Double = 0
    private var lastSelectedPlates: Set<Double> = []
    private var lastBarbellId: UUID?
    private var lastConsiderBarbellWeight: Bool = true
    private var cachedAchievableWeights: Set<Double>?
    private var lastAchievabilityCheck: (weight: Double, result: WeightSuggestion)?
    
    private func shouldRecalculatePlates() -> Bool {
        let currentPlatesSet = Set(selectedPlateWeights)
        let shouldRecalc = lastTargetWeight != targetWeight ||
            lastSelectedPlates != currentPlatesSet ||
            lastBarbellId != selectedBarbell.id ||
            lastConsiderBarbellWeight != considerBarbellWeight
        
        if shouldRecalc {
            lastTargetWeight = targetWeight
            lastSelectedPlates = currentPlatesSet
            lastBarbellId = selectedBarbell.id
            lastConsiderBarbellWeight = considerBarbellWeight
        }
        
        return shouldRecalc
    }
    
    private func invalidateCache() {
        cachedMax = nil
        cachedBreakdown = nil
        if shouldRecalculatePlates() {
            cachedPlates = nil
        }
    }
    
    // MARK: - Published Properties
    @Published var mode: CalculatorMode = .plates {
        didSet { invalidateCache() }
    }
    
    @Published var targetWeight: Double = 100 {
        didSet {
            // Only invalidate and notify if significant change
            if abs(oldValue - targetWeight) > 0.01 {
                invalidateCache()
            }
        }
    }
    
    @Published private(set) var selectedUnit: Unit = .kg {
        didSet { 
            if oldValue != selectedUnit {
                invalidateCache() 
            }
        }
    }
    
    @Published var selectedBarbell: Barbell = .standard {
        didSet { 
            if oldValue.id != selectedBarbell.id {
                invalidateCache() 
            }
        }
    }
    
    @Published var repCount: Int = 1 {
        didSet {
            if oldValue != repCount {
                invalidateCache()
            }
        }
    }
    
    @Published var rpe: Double = 8.0 {
        didSet { 
            if oldValue != rpe {
                invalidateCache() 
            }
        }
    }
    
    @Published var considerBarbellWeight: Bool = true {
        didSet {
            if oldValue != considerBarbellWeight {
                invalidateCache()
            }
        }
    }
    
    // MARK: - Computed Properties
    struct PlateCount: Identifiable, Hashable {
        let id = UUID()
        let weight: Double
        let count: Int
        let label: String?  // Optional label for equipment
        let unit: Unit      // Add unit to support different weight units
        
        // Convenience initializer for plates
        init(weight: Double, count: Int, unit: Unit = .kg) {
            self.weight = weight
            self.count = count
            self.label = nil
            self.unit = unit
        }
        
        // Initializer for equipment with label
        init(weight: Double, count: Int, label: String, unit: Unit = .kg) {
            self.weight = weight
            self.count = count
            self.label = label
            self.unit = unit
        }
        
        // Formatted string representation
        var formattedString: String {
            if let label = label {
                return "\(label): \(String(format: "%.1f", weight)) \(unit.symbol)"
            } else {
                return "\(String(format: "%.1f", weight)) \(unit.symbol) x \(count)"
            }
        }
    }
    
    var platesPerSide: [PlateCount] {
        // Use cached result if available and inputs haven't changed
        if !shouldRecalculatePlates(), let cached = cachedPlates {
            return cached
        }
        
        // Convert all weights to kg for internal calculations
        let barWeightInKg = considerBarbellWeight ? selectedBarbell.weight.convert(to: .kg).value : 0
        let targetInKg = Weight(value: targetWeight, unit: selectedUnit).convert(to: .kg).value
        
        // Convert plate weights to kg if needed
        let sortedPlates = selectedPlateWeights
            .map { selectedUnit == .kg ? $0 : Weight(value: $0, unit: selectedUnit).convert(to: .kg).value }
            .sorted(by: >)
        
        guard !sortedPlates.isEmpty else { return [] }
        guard targetInKg >= barWeightInKg else { return [] }
        
        let netWeight = targetInKg - barWeightInKg
        let halfNetWeight = netWeight / 2
        
        // Try to build this weight with our plates
        var remainingWeight = halfNetWeight
        var plateCounts: [(weight: Double, count: Int)] = []
        
        for plateWeight in sortedPlates {
            let maxPlates = min(Int(floor(remainingWeight / plateWeight)), 10)
            if maxPlates > 0 {
                plateCounts.append((plateWeight, maxPlates))
                remainingWeight -= Double(maxPlates) * plateWeight
            }
        }
        
        // If we can't achieve this weight exactly, return empty
        if remainingWeight >= 0.1 {
            return []
        }
        
        // Convert PlateCount objects back to the selected unit
        var result = plateCounts.map { plateWeight, count in
            let weightInSelectedUnit = Weight(value: plateWeight, unit: .kg).convert(to: selectedUnit).value
            return PlateCount(weight: weightInSelectedUnit, count: count, unit: selectedUnit)
        }
        
        // Add barbell if needed
        if considerBarbellWeight {
            let barbellWeightInSelectedUnit = selectedBarbell.weight.convert(to: selectedUnit).value
            result.insert(
                PlateCount(
                    weight: barbellWeightInSelectedUnit,
                    count: 1,
                    label: selectedBarbell.name,
                    unit: selectedUnit
                ),
                at: 0
            )
        }
        
        // Cache the result
        cachedPlates = result
        return result
    }
    
    struct RepPercentage: Identifiable {
        let id = UUID()
        let percentage: Int
        let weight: Double
        let reps: Int
        
        var displayWeight: String {
            String(format: "%.1f", weight.rounded(to: 1))
        }
    }
    
    var estimatedMax: Double {
        if let cached = cachedMax { return cached }
        // Brzycki Formula: 1RM = weight × (36 / (37 - reps))
        let weight = Weight(value: targetWeight, unit: selectedUnit)
        
        // Ensure we don't get invalid results for high rep counts
        guard repCount < 37 else { return weight.value }
        
        let max = weight.value * (36.0 / (37.0 - Double(repCount))).rounded(to: 1)
        cachedMax = max
        return max
    }
    
    var percentageBreakdown: [RepPercentage] {
        if let cached = cachedBreakdown { return cached }
        
        // Only show percentages for valid rep ranges (1-12)
        guard repCount >= 1 && repCount <= 12 else { return [] }
        
        let percentages = [
            (percentage: 100, reps: 1),
            (percentage: 95, reps: 2),
            (percentage: 90, reps: 4),
            (percentage: 85, reps: 6),
            (percentage: 80, reps: 8),
            (percentage: 75, reps: 10),
            (percentage: 70, reps: 12),
            (percentage: 65, reps: 15),
            (percentage: 60, reps: 20)
        ]
        
        // Calculate 1RM using Brzycki formula
        let weight = Weight(value: targetWeight, unit: selectedUnit)
        let max = weight.value * (36.0 / (37.0 - Double(repCount))).rounded(to: 1)
        
        let breakdown = percentages.map { percentage, reps in
            let weight = (max * Double(percentage) / 100.0)
            return RepPercentage(
                percentage: percentage,
                weight: weight,
                reps: reps
            )
        }
        
        cachedBreakdown = breakdown
        return breakdown
    }
    
    // MARK: - Plate Weight Management
    func updateSelectedPlateWeights(_ weights: [Double]) {
        selectedPlateWeights = weights
        cachedPlates = nil
    }
    
    func addAvailablePlateWeight(_ weight: Double) {
        if !availablePlateWeights.contains(weight) {
            availablePlateWeights.append(weight)
        }
    }
    
    func removeAvailablePlateWeight(_ weight: Double) {
        availablePlateWeights.removeAll { $0 == weight }
        selectedPlateWeights.removeAll { $0 == weight }
    }
    
    func resetAvailablePlateWeights() {
        availablePlateWeights = [2.5, 5, 10, 15, 20, 25, 35, 45]
        selectedPlateWeights = availablePlateWeights
    }
    
    // MARK: - Plate Visibility Management
    func updatePlateVisibility(for plateWeight: Double, isEnabled: Bool) {
        guard availablePlateWeights.contains(plateWeight) else {
            return
        }
        
        if isEnabled {
            if !selectedPlateWeights.contains(plateWeight) {
                selectedPlateWeights.append(plateWeight)
            }
        } else if selectedPlateWeights.count > 1 {
            selectedPlateWeights.removeAll { $0 == plateWeight }
        }
        
        // Persist changes to selected plates key
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                let encodedPlates = try encoder.encode(selectedPlateWeights)
                UserDefaults.standard.set(encodedPlates, forKey: Self.selectedPlatesKey)
                
                // Ensure UI updates on main thread
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            } catch {
                print("Error encoding plate weights: \(error)")
            }
        }
    }
    
    func addCustomPlateWeight(_ plateWeight: Double) {
        // Prevent duplicates
        guard !availablePlates.contains(plateWeight) else {
            print("❌ Plate weight \(plateWeight) already exists")
            return
        }
        
        // Validate plate weight range
        guard plateWeight > 0 && plateWeight <= 100 else {
            print("❌ Invalid plate weight: \(plateWeight)")
            return
        }
        
        // Add plate weight and sort
        availablePlates.append(plateWeight)
        availablePlates.sort()
        
        // Automatically select the new plate
        selectedPlateWeights.append(plateWeight)
        selectedPlateWeights.sort()
        
        // Sync availablePlateWeights
        availablePlateWeights = availablePlates
        
        // Persist changes
        Task {
            if let encoded = try? JSONEncoder().encode(availablePlates) {
                UserDefaults.standard.set(encoded, forKey: Self.availablePlatesKey)
            }
        }
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    func removeCustomPlateWeight(_ weight: Double) {
        // Prevent removing standard plates
        guard weight > 45 else {
            print("❌ Cannot remove standard plate: \(weight)")
            return
        }
        
        // Remove from available and selected plates
        availablePlates.removeAll { $0 == weight }
        selectedPlateWeights.removeAll { $0 == weight }
        
        // Sync availablePlateWeights
        availablePlateWeights = availablePlates
        
        // Ensure at least one plate remains
        if selectedPlateWeights.isEmpty {
            selectedPlateWeights = [45.0]
        }
        
        // Persist changes
        Task {
            do {
                let encoder = JSONEncoder()
                let encodedPlates = try encoder.encode(availablePlates)
                UserDefaults.standard.set(encodedPlates, forKey: Self.availablePlatesKey)
                
                // Ensure UI updates on main thread
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
                print("✅ Removed plate weight: \(weight)")
            } catch {
                print("❌ Error encoding plate removal: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    func toggleMode() {
        mode = mode == .plates ? .maxRep : .plates
        HapticManager.shared.mediumImpact()
    }
    
    func setUnit(_ unit: Unit) {
        let currentWeight = Weight(value: targetWeight, unit: selectedUnit)
        let newWeight = currentWeight.convert(to: unit)
        selectedUnit = unit
        targetWeight = newWeight.value
        HapticManager.shared.lightImpact()
    }
}

struct WeightSuggestion {
    let targetWeight: Double
    let lowerWeight: Double
    let higherWeight: Double
    let unit: Unit
    let isAchievable: Bool
}

extension Calculator {
    func checkWeightAchievability(targetWeight: Double, startingWeight: Double = 53.0) -> WeightSuggestion {
        // Check if we have a cached result for this exact weight
        if let lastCheck = lastAchievabilityCheck,
           abs(lastCheck.weight - targetWeight) < 0.01 {
            return lastCheck.result
        }
        
        // Convert target weight to kg for internal calculations
        let targetInKg = Weight(value: targetWeight, unit: selectedUnit).convert(to: .kg).value
        
        // For barbell, we use its weight instead of startingWeight
        let baseWeight = considerBarbellWeight ? selectedBarbell.weight.convert(to: .kg).value : 0
        
        // Convert plate weights to kg if needed
        let availablePlates = selectedPlateWeights
            .map { selectedUnit == .kg ? $0 : Weight(value: $0, unit: selectedUnit).convert(to: .kg).value }
            .sorted(by: >)
        
        // If target is less than barbell weight, it's not achievable
        if targetInKg < baseWeight {
            return WeightSuggestion(
                targetWeight: targetWeight,
                lowerWeight: Weight(value: baseWeight, unit: .kg).convert(to: selectedUnit).value,
                higherWeight: Weight(value: baseWeight + (availablePlates.last ?? 0) * 2, unit: .kg).convert(to: selectedUnit).value,
                unit: selectedUnit,
                isAchievable: false
            )
        }
        
        // Calculate per-side weight needed
        let netWeight = targetInKg - baseWeight
        let perSideWeight = netWeight / 2
        
        // Try to build this weight with available plates
        var remainingWeight = perSideWeight
        var usedPlates: [(weight: Double, count: Int)] = []
        
        for plate in availablePlates {
            let plateCount = min(Int(floor(remainingWeight / plate)), 10)
            if plateCount > 0 {
                usedPlates.append((plate, plateCount))
                remainingWeight -= Double(plateCount) * plate
            }
        }
        
        // Check if we achieved the target weight exactly
        let isAchievable = remainingWeight < 0.1
        
        if isAchievable {
            return WeightSuggestion(
                targetWeight: targetWeight,
                lowerWeight: targetWeight,
                higherWeight: targetWeight,
                unit: selectedUnit,
                isAchievable: true
            )
        }
        
        // Find the closest achievable weights
        var lowerWeight = baseWeight
        var higherWeight = baseWeight
        
        // Calculate lower weight
        remainingWeight = perSideWeight
        for plate in availablePlates {
            let plateCount = Int(floor(remainingWeight / plate))
            if plateCount > 0 {
                lowerWeight += Double(plateCount) * plate * 2
                remainingWeight -= Double(plateCount) * plate
            }
        }
        
        // Calculate higher weight
        remainingWeight = perSideWeight
        for plate in availablePlates.reversed() {
            let plateCount = Int(ceil(remainingWeight / plate))
            if plateCount > 0 && plateCount <= 10 {
                higherWeight += Double(plateCount) * plate * 2
                break
            }
        }
        
        // Convert weights back to selected unit
        let convertedLower = Weight(value: lowerWeight, unit: .kg).convert(to: selectedUnit).value
        let convertedHigher = Weight(value: higherWeight, unit: .kg).convert(to: selectedUnit).value
        
        return WeightSuggestion(
            targetWeight: targetWeight,
            lowerWeight: convertedLower,
            higherWeight: convertedHigher,
            unit: selectedUnit,
            isAchievable: false
        )
    }
}
