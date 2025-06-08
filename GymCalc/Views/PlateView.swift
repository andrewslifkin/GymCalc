import SwiftUI

struct PlateView: View {
    let plateWeight: Double
    let unit: Unit
    
    private func plateColor(_ weight: Double, unit: Unit) -> Color {
        switch unit {
        case Unit.kg:
            switch weight {
            case 1.25: return .blue
            case 2.5: return .green
            case 5.0: return .yellow
            case 10.0: return .orange
            case 15.0: return .red
            case 20.0: return .purple
            case 25.0: return .gray
            default: return .gray
            }
        case Unit.lbs:
            switch weight {
            case 2.5: return .blue
            case 5.0: return .green
            case 10.0: return .yellow
            case 25.0: return .orange
            case 35.0: return .red
            case 45.0: return .purple
            default: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", plateWeight))
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(plateColor(plateWeight, unit: unit))
                .clipShape(Circle())
            
            Text("× 1")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PlateView(plateWeight: 45, unit: Unit.lbs)
        PlateView(plateWeight: 20, unit: Unit.kg)
    }
    .preferredColorScheme(.dark)
}
