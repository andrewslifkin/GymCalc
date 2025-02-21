import SwiftUI

@main
struct GymCalcApp: App {
    @StateObject private var calculator = Calculator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calculator)
                .preferredColorScheme(.dark)
        }
    }
}
