import SwiftUI

struct PlateVisualizer: View {
    let plateCounts: [Calculator.PlateCount]
    let unit: Unit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Separate sections for Equipment and Plates per side
            if let equipmentPlate = plateCounts.first(where: { $0.label != nil }) {
                Text("Equipment:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Text(equipmentPlate.formattedString)
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
            
            if plateCounts.filter({ $0.label == nil }).isEmpty {
                Text("Add weight to see plate breakdown")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(plateCounts.filter { $0.label == nil }) { plateCount in
                    Text(plateCount.formattedString)
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
