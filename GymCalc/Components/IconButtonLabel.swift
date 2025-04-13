import SwiftUI
import GymCalc

struct IconButtonLabel: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let icon: String
    let label: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(themeManager.iconColor)
                .accessibility(hidden: true)
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(themeManager.iconColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(themeManager.cardColor)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) button")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    IconButtonLabel(icon: "square.grid.2x2", label: "Plates", accentColor: Color.yellow)
        .environmentObject(ThemeManager())
        .padding()
        .background(Color.black)
} 