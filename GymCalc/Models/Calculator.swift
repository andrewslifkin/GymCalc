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
        availableBarbells[index].isVisible = isVisible
        
        // If current selected barbell becomes invisible, select a visible one
        if !selectedBarbell.isVisible {
            selectedBarbell = availableBarbells.first(where: { $0.isVisible }) ?? .standard
        }
        
        // Persist changes
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                let encodedBarbells = try encoder.encode(availableBarbells)
                UserDefaults.standard.set(encodedBarbells, forKey: Self.availableBarbellsKey)
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
            self.selectedPlateWeights = decoded
        } else {
            // Use default plates if no saved data
            self.availablePlates = defaultPlates
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
        selectedPlateWeights = defaultPlates
        
        // Persist changes
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                let encodedPlates = try encoder.encode(availablePlates)
                UserDefaults.standard.set(encodedPlates, forKey: Self.availablePlatesKey)
                
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
    internal var cachedPlates: [PlateCount]? = nil {
        willSet {
            // Trigger any necessary updates when cache changes
            objectWillChange.send()
        }
    }
    
    private func invalidateCache() {
        cachedMax = nil
        cachedBreakdown = nil
        cachedPlates = nil
    }
    
    // MARK: - Published Properties
    @Published var mode: CalculatorMode = .plates {
        didSet { invalidateCache() }
    }
    
    @Published var targetWeight: Double = 100 {
        willSet {
            invalidateCache()
        }
        didSet {
            if abs(oldValue - targetWeight) > 0.01 {
                objectWillChange.send()
            }
        }
    }
    
    @Published private(set) var selectedUnit: Unit = .kg {
        didSet { invalidateCache() }
    }
    
    @Published var selectedBarbell: Barbell = .standard {
        didSet { invalidateCache() }
    }
    
    @Published var repCount: Int = 1 {
        didSet {
            if oldValue != repCount {
                invalidateCache()
                objectWillChange.send()
            }
        }
    }
    
    @Published var rpe: Double = 8.0 {
        didSet { invalidateCache() }
    }
    
    @Published var considerBarbellWeight: Bool = true {
        didSet {
            // Invalidate cache when changing barbell weight consideration
            invalidateCache()
        }
    }
    
    // MARK: - Computed Properties
    struct PlateCount: Identifiable, Hashable {
        let id = UUID()
        let weight: Double
        let count: Int
    }
    
    var platesPerSide: [PlateCount] {
        // Check cached plates first to avoid redundant calculations
        guard let cachedPlates = cachedPlates else {
            let barWeightInKg = considerBarbellWeight ? selectedBarbell.weight.convert(to: .kg).value : 0
            let targetInKg = Weight(value: targetWeight, unit: selectedUnit)
                .convert(to: .kg).value
            
            guard targetInKg >= barWeightInKg else { return [] }
            
            let netWeight = targetInKg - barWeightInKg
            let halfNetWeight = netWeight / 2
            
            // Use a more efficient plate calculation algorithm
            var remainingWeight = halfNetWeight
            var plateCounts: [PlateCount] = []
            
            // Sort selected plate weights in descending order for faster computation
            let availablePlates = selectedPlateWeights.isEmpty 
                ? [45.0, 35.0, 25.0, 20.0, 15.0, 10.0, 5.0, 2.5]  // Optimized default order
                : selectedPlateWeights.sorted(by: >)
            
            for plateWeight in availablePlates {
                // Compute plate count more efficiently
                let plateCount = min(floor(remainingWeight / plateWeight), 10)  // Limit to 10 plates per side
                
                if plateCount > 0 {
                    plateCounts.append(PlateCount(weight: plateWeight, count: Int(plateCount)))
                    remainingWeight -= plateWeight * plateCount
                }
                
                // Early exit if remaining weight is negligible
                if remainingWeight < 0.1 { break }
            }
            
            // Cache the result to improve subsequent calculations
            cachedPlates = plateCounts
            return plateCounts
        }
        
        return cachedPlates
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
        
        // Persist changes
        Task { @MainActor in
            do {
                let encoder = JSONEncoder()
                let encodedPlates = try encoder.encode(selectedPlateWeights)
                UserDefaults.standard.set(encodedPlates, forKey: Self.availablePlatesKey)
                
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
        guard !availablePlateWeights.contains(plateWeight) else {
            print("❌ Plate weight \(plateWeight) already exists")
            return
        }
        
        // Validate plate weight range
        guard plateWeight > 0 && plateWeight <= 100 else {
            print("❌ Invalid plate weight: \(plateWeight)")
            return
        }
        
        // Add plate weight and sort
        availablePlateWeights.append(plateWeight)
        availablePlateWeights.sort()
        
        // Automatically select the new plate
        selectedPlateWeights.append(plateWeight)
        selectedPlateWeights.sort()
        
        // Persist changes
        Task {
            if let encoded = try? JSONEncoder().encode(availablePlateWeights) {
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
        availablePlateWeights.removeAll { $0 == weight }
        selectedPlateWeights.removeAll { $0 == weight }
        
        // Ensure at least one plate remains
        if selectedPlateWeights.isEmpty {
            selectedPlateWeights = [45.0]
        }
        
        // Persist changes
        Task {
            do {
                let encoder = JSONEncoder()
                let encodedPlates = try encoder.encode(availablePlateWeights)
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
