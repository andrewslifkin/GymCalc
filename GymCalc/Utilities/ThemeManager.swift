import SwiftUI

enum AppTheme: String, CaseIterable {
    case light
    case dark
    
    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var label: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }
    
    // Colors for both themes
    let accentColor = Color(red: 243/255, green: 236/255, blue: 90/255) // Bright yellow accent
    
    // Light mode colors matching screenshot
    let lightBackgroundColor = Color(white: 0.97) // Very light gray background
    let lightCardColor = Color(white: 0.93) // Flat light gray for cards
    let lightTextColor = Color(red: 29/255, green: 29/255, blue: 29/255) // #1d1d1d
    let lightSecondaryTextColor = Color(red: 0.4, green: 0.4, blue: 0.4) // Medium gray for secondary text
    let lightSelectedItemColor = Color.gray // Gray for selected items
    
    let iconColor = Color(red: 29/255, green: 29/255, blue: 29/255) // #1d1d1d
    
    // Dark mode colors
    let darkBackgroundColor = Color.black
    let darkCardColor = Color(white: 0.15)
    let darkTextColor = Color.white
    let darkSecondaryTextColor = Color(white: 0.7)
    let darkSelectedItemColor = Color.gray // Gray for selected items
    
    // Dynamic colors based on current theme
    var backgroundColor: Color {
        currentTheme == .light ? lightBackgroundColor : darkBackgroundColor
    }
    
    var cardColor: Color {
        currentTheme == .light ? lightCardColor : darkCardColor
    }
    
    var textColor: Color {
        currentTheme == .light ? lightTextColor : darkTextColor
    }
    
    var secondaryTextColor: Color {
        currentTheme == .light ? lightSecondaryTextColor : darkSecondaryTextColor
    }
    
    var selectedItemColor: Color {
        currentTheme == .light ? lightSelectedItemColor : darkSelectedItemColor
    }
    
    var toggleBgColor: Color {
        currentTheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color.white.opacity(0.1) // Light gray for light mode
    }
    
    var toggleActiveColor: Color {
        currentTheme == .light ? accentColor.opacity(0.4) : Color.white.opacity(0.2) // Yellow for light mode
    }
    
    var toggleHandleColor: Color {
        currentTheme == .light ? accentColor : Color.white // Yellow handle for light mode
    }
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .light // Default to light
        }
    }
    
    func toggleTheme() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentTheme = currentTheme == .light ? .dark : .light
        }
    }
} 