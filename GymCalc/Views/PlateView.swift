import SwiftUI

struct PlateView: View {
    let plateWeight: Double
    let unit: Unit
    
    private func plateColor(_ weight: Double) -> Color {
        switch weight {
        case 2.5: return .blue
        case 5: return .green
        case 10: return .yellow
        case 15: return .orange
        case 20: return .red
        case 25: return .purple
        case 35: return .gray
        case 45: return .black
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", plateWeight))
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(plateColor(plateWeight))
                .clipShape(Circle())
            
            Text("× 1")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    PlateView(plateWeight: 45, unit: .kg)
        .preferredColorScheme(.dark)
}
