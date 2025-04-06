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
    
    func convert(to targetUnit: Unit) -> Weight {
        guard unit != targetUnit else { return self }
        
        let kgValue = unit == .kg ? value : value / Unit.lbs.conversionFactor
        let convertedValue = targetUnit == .kg ? kgValue : kgValue * Unit.lbs.conversionFactor
        
        return Weight(value: convertedValue.rounded(to: 2), unit: targetUnit)
    }
    
    var formatted: String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) \(unit.symbol)"
    }
    
    static func kg(_ value: Double) -> Weight {
        Weight(value: value, unit: .kg)
    }
    
    static func lbs(_ value: Double) -> Weight {
        Weight(value: value, unit: .lbs)
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
