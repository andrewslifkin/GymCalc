import SwiftUI

struct PlateVisualizer: View {
    let plateCounts: [Calculator.PlateCount]
    let unit: Unit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Per side:")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            if plateCounts.isEmpty {
                Text("Add weight to see plate breakdown")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(plateCounts) { plateCount in
                    HStack(spacing: 8) {
                        Text(String(format: "%.1f %@", 
                             plateCount.weight,
                             unit.symbol))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                        
                        Text("× \(plateCount.count)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Plate breakdown")
    }
}
