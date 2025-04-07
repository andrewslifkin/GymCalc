import SwiftUI

struct PlateVisualizer: View {
    let plateCounts: [PlateCount]
    let unit: Unit
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Equipment section (barbell)
            if let barbell = plateCounts.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(.blue)
                        Text("\(barbell.weight.value, specifier: "%.1f") \(unit.symbol)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Plates section
            VStack(alignment: .leading, spacing: 8) {
                Text("Plates per side")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if plateCounts.count <= 1 {
                    Text("Add weight to see plate breakdown")
                        .font(.body)
                        .foregroundColor(.gray)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(plateCounts.dropFirst(), id: \.self) { plateCount in
                            HStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 8, height: 8)
                                Text("\(plateCount.weight.value, specifier: "%.1f") \(unit.symbol)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                Text("×")
                                    .foregroundColor(.gray)
                                Text("\(plateCount.count)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Plate breakdown")
    }
}

#Preview {
    PlateVisualizer(
        plateCounts: [
            PlateCount(weight: Weight(value: 20, unit: .kg), count: 1),
            PlateCount(weight: Weight(value: 20, unit: .kg), count: 2),
            PlateCount(weight: Weight(value: 10, unit: .kg), count: 2)
        ],
        unit: .kg
    )
    .preferredColorScheme(.dark)
}
