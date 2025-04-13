import SwiftUI
import Foundation

struct PlateVisualizer: View {
    let plateCounts: [PlateCount]
    let unit: Unit
    @EnvironmentObject private var calculator: Calculator
    @Environment(\.colorScheme) private var colorScheme
    
    // Yellow accent color to match screenshot
    private let accentColor = Color(red: 235/255, green: 235/255, blue: 25/255) // Vibrant yellow
    private let cardBackgroundColor = Color(white: 0.15) // Dark gray for cards
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Equipment section (barbell)
            if let barbell = plateCounts.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Equipment")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.7))
                    
                    HStack {
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(accentColor)
                        VStack(alignment: .leading) {
                            Text(calculator.selectedBarbell.name)
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Text("\(barbell.weight.value, specifier: "%.1f") \(unit.symbol)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color(white: 0.7))
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(cardBackgroundColor)
                    .cornerRadius(16)
                }
            }
            
            // Plates section
            VStack(alignment: .leading, spacing: 12) {
                Text("Plates per side")
                    .font(.subheadline)
                    .foregroundColor(Color(white: 0.7))
                
                if plateCounts.count <= 1 {
                    Text("Add weight to see plate breakdown")
                        .font(.body)
                        .foregroundColor(Color(white: 0.7))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cardBackgroundColor)
                        .cornerRadius(16)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(plateCounts.dropFirst(), id: \.self) { plateCount in
                            HStack {
                                Circle()
                                    .fill(accentColor.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                Text("\(plateCount.weight.value, specifier: "%.1f") \(unit.symbol)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Text("×")
                                    .foregroundColor(Color(white: 0.7))
                                Text("\(plateCount.count)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(accentColor)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(cardBackgroundColor)
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
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
    .environmentObject(Calculator())
    .preferredColorScheme(.dark)
    .background(Color.black)
    .padding()
}
