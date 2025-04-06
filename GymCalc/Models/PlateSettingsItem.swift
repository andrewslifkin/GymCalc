import Foundation

struct PlateSettingsItem: Identifiable {
    let id: UUID
    let weight: Double
    var isEnabled: Bool
    let isCustom: Bool
    
    init(id: UUID = UUID(), weight: Double, isEnabled: Bool = true, isCustom: Bool = false) {
        self.id = id
        self.weight = weight
        self.isEnabled = isEnabled
        self.isCustom = isCustom
    }
}
