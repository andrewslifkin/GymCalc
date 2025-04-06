import XCTest
@testable import GymCalc

final class WeightCalculatorTests: XCTestCase {
    var calculator: WeightCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = WeightCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - Weight Conversion Tests
    
    func testWeightConversion() throws {
        // Test kg to lbs
        let kgWeight = Weight(value: 100.0, unit: .kg)
        let lbsWeight = try kgWeight.converted(to: .lbs)
        XCTAssertEqual(lbsWeight.value.rounded(to: 2), 220.46)
        
        // Test lbs to kg
        let lbsWeight2 = Weight(value: 225.0, unit: .lbs)
        let kgWeight2 = try lbsWeight2.converted(to: .kg)
        XCTAssertEqual(kgWeight2.value.rounded(to: 2), 102.06)
    }
    
    func testInvalidWeightConversion() {
        let invalidWeight = Weight(value: -100.0, unit: .kg)
        XCTAssertThrowsError(try invalidWeight.converted(to: .lbs)) { error in
            XCTAssertTrue(error is WeightCalculationError)
        }
    }
    
    // MARK: - Plate Calculation Tests
    
    func testPlateCalculation() async {
        // Setup test barbell and weights
        let barbell = Barbell(id: UUID(), name: "Test Bar", weight: Weight(value: 45.0, unit: .lbs))
        calculator.barbells = [barbell]
        calculator.selectedBarbellId = barbell.id
        
        // Test 225 lbs (common bench press weight)
        calculator.currentWeight = Weight(value: 225.0, unit: .lbs)
        calculator.calculatePlates()
        
        // Wait for async calculation
        try? await Task.sleep(nanoseconds: UInt64(0.2 * Double(NSEC_PER_SEC)))
        
        // Should be 4x45lb plates (2 per side)
        XCTAssertEqual(calculator.plateBreakdown.count, 2)
        XCTAssertEqual(calculator.plateBreakdown.first?.weight, 45.0)
        XCTAssertEqual(calculator.plateBreakdown.first?.count, 2)
    }
    
    func testEdgeCasePlateCalculations() async {
        let barbell = Barbell(id: UUID(), name: "Test Bar", weight: Weight(value: 45.0, unit: .lbs))
        calculator.barbells = [barbell]
        calculator.selectedBarbellId = barbell.id
        
        // Test weight less than bar
        calculator.currentWeight = Weight(value: 40.0, unit: .lbs)
        calculator.calculatePlates()
        
        // Wait for async calculation
        try? await Task.sleep(nanoseconds: UInt64(0.2 * Double(NSEC_PER_SEC)))
        
        XCTAssertTrue(calculator.plateBreakdown.isEmpty)
        
        // Test exact bar weight
        calculator.currentWeight = Weight(value: 45.0, unit: .lbs)
        calculator.calculatePlates()
        
        try? await Task.sleep(nanoseconds: UInt64(0.2 * Double(NSEC_PER_SEC)))
        
        XCTAssertTrue(calculator.plateBreakdown.isEmpty)
    }
    
    // MARK: - Preset Management Tests
    
    func testPresetManagement() {
        let preset = WeightPreset(name: "Test Preset", weight: Weight(value: 225.0, unit: .lbs))
        
        // Add preset
        calculator.addPreset(preset)
        XCTAssertTrue(calculator.presets.contains(where: { $0.name == preset.name }))
        
        // Remove preset
        calculator.removePreset(at: IndexSet(integer: calculator.presets.count - 1))
        XCTAssertFalse(calculator.presets.contains(where: { $0.name == preset.name }))
    }
}

// MARK: - Helper Extensions

extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
