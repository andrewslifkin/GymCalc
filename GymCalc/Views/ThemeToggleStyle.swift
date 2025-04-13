import SwiftUI

struct ThemeToggleStyle: ToggleStyle {
    @EnvironmentObject var themeManager: ThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            // Toggle background
            Capsule()
                .fill(configuration.isOn ? themeManager.toggleActiveColor : themeManager.toggleBgColor)
                .frame(width: 51, height: 31)
                .overlay(
                    // Toggle handle
                    Circle()
                        .fill(.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                        .frame(width: 27, height: 27)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                .accessibilityElement()
                .accessibilityLabel(configuration.isOn ? "Light mode enabled" : "Dark mode enabled")
                .accessibilityHint("Double tap to toggle")
                .accessibilityAddTraits(.isButton)
                .accessibilityValue(configuration.isOn ? "On" : "Off")
        }
    }
}

// Updated toggle style with color support for light/dark mode
struct AppToggleStyle: ButtonStyle {
    let accentColor: Color
    let backgroundColor: Color
    let handleColor: Color
    
    init(accentColor: Color, backgroundColor: Color = Color.gray.opacity(0.2), handleColor: Color? = nil) {
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.handleColor = handleColor ?? accentColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10) // Increase touch target size
            .contentShape(Rectangle())
    }
} 