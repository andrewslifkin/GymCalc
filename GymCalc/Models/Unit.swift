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
