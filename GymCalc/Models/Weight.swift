import Foundation

enum Unit: String, CaseIterable, Codable, Hashable {
    case kg, lbs
    
    var symbol: String {
        rawValue.uppercased()
    }
    
    var conversionFactor: Double {
        switch self {
        case .kg: return 1.0
        case .lbs: return 2.20462
        }
    }
}

struct Weight: Codable, Hashable {
    var value: Double
    var unit: Unit
    
    // Gym-specific plate weight conversions
    // KG to LBS conversions (rounded gym equivalents)
    private static let kgToLbsGymConversions: [Double: Double] = [
        1.25: 2.5,   // 1.25kg = 2.5lbs (instead of 2.76lbs)
        2.5: 5.0,    // 2.5kg = 5lbs (instead of 5.51lbs)
        5.0: 10.0,   // 5kg = 10lbs (instead of 11.02lbs)
        10.0: 25.0,  // 10kg = 25lbs (instead of 22.05lbs)
        15.0: 35.0,  // 15kg = 35lbs (instead of 33.07lbs)
        20.0: 45.0,  // 20kg = 45lbs (instead of 44.09lbs)
        25.0: 55.0   // 25kg = 55lbs (instead of 55.12lbs)
    ]
    
    // LBS to KG conversions (rounded gym equivalents)
    private static let lbsToKgGymConversions: [Double: Double] = [
        2.5: 1.25,   // 2.5lbs = 1.25kg (instead of 1.13kg)
        5.0: 2.5,    // 5lbs = 2.5kg (instead of 2.27kg)
        10.0: 5.0,   // 10lbs = 5kg (instead of 4.54kg)
        25.0: 10.0,  // 25lbs = 10kg (instead of 11.34kg)
        35.0: 15.0,  // 35lbs = 15kg (instead of 15.88kg)
        45.0: 20.0,  // 45lbs = 20kg (instead of 20.41kg)
        55.0: 25.0   // 55lbs = 25kg (instead of 24.95kg)
    ]
    
    // Standard plate weights for each unit
    static let standardPlateWeights: [Unit: [Double]] = [
        .kg: [1.25, 2.5, 5.0, 10.0, 15.0, 20.0, 25.0],
        .lbs: [2.5, 5.0, 10.0, 25.0, 35.0, 45.0]
    ]
    
    func convert(to targetUnit: Unit) -> Weight {
        guard unit != targetUnit else { return self }
        
        // Check for gym-specific plate conversions first
        if unit == .kg && targetUnit == .lbs {
            if let gymConversion = Self.kgToLbsGymConversions[value] {
                return Weight(value: gymConversion, unit: targetUnit)
            }
        } else if unit == .lbs && targetUnit == .kg {
            if let gymConversion = Self.lbsToKgGymConversions[value] {
                return Weight(value: gymConversion, unit: targetUnit)
            }
        }
        
        // Fall back to standard conversion for non-gym plates
        let kgValue = unit == .kg ? value : value / Unit.lbs.conversionFactor
        let convertedValue = targetUnit == .kg ? kgValue : kgValue * Unit.lbs.conversionFactor
        
        return Weight(value: convertedValue.rounded(to: 2), unit: targetUnit)
    }
    
    var formatted: String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) \(unit.symbol)"
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
