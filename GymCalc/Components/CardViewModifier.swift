import SwiftUI
import GymCalc

struct CardViewModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(themeManager.cardColor)
            )
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(CardViewModifier(cornerRadius: cornerRadius))
    }
} 