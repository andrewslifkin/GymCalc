import SwiftUI

struct WeightSuggestionView: View {
    let suggestion: WeightSuggestion
    @Binding var targetWeight: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("Weight Not Achievable")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Message
            Text("The target weight of \(suggestion.targetWeight, specifier: "%.1f")\(suggestion.unit.symbol) cannot be achieved with your current plates.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Suggestions
            HStack(spacing: 16) {
                // Lower suggestion
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        targetWeight = suggestion.lowerWeight
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lower")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(suggestion.lowerWeight, specifier: "%.1f")\(suggestion.unit.symbol)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(12)
                }
                
                // Higher suggestion
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        targetWeight = suggestion.higherWeight
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Higher")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(suggestion.higherWeight, specifier: "%.1f")\(suggestion.unit.symbol)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.black
        WeightSuggestionView(
            suggestion: WeightSuggestion(
                targetWeight: 223.0,
                lowerWeight: 220.0,
                higherWeight: 225.0,
                unit: .kg,
                isAchievable: false
            ),
            targetWeight: .constant(223.0)
        )
        .padding()
    }
} 