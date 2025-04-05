import SwiftUI

struct PlateVisualizer: View {
    let plateCounts: [PlateCount]
    let unit: Unit
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Equipment section (barbell)
            if let barbell = plateCounts.first {
                Text("Equipment:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Text("\(barbell.weight.value, specifier: "%.1f") \(unit.symbol)")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                // Add vertical spacing between sections
                Spacer()
                    .frame(height: 16)
            }
            
            Text("Plates per side:")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            if plateCounts.isEmpty {
                Text("Add weight to see plate breakdown")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(plateCounts.dropFirst(), id: \.self) { plateCount in
                    Text("\(plateCount.weight.value, specifier: "%.1f") \(unit.symbol) × \(plateCount.count)")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .padding(.horizontal)
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
            PlateCount(weight: Weight(value: 10, unit: .kg), count: 2),
            PlateCount(weight: Weight(value: 5, unit: .kg), count: 2)
        ],
        unit: .kg
    )
    .preferredColorScheme(.dark)
}
