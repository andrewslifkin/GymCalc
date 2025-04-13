import SwiftUI

struct PlateRow: View {
    let plate: PlateCount
    let unit: Unit
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            // Color indicator
            Circle()
                .fill(Color.green)
                .frame(width: 12, height: 12)
            
            // Weight text
            Text("\(plate.weight.value, specifier: "%.1f") \(unit.symbol)")
                .font(.headline)
                .foregroundColor(themeManager.textColor)
            
            Spacer()
            
            // Count
            Text("× \(plate.count)")
                .font(.headline)
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
} 