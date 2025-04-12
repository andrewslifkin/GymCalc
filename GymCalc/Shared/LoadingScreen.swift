import SwiftUI

struct LoadingScreen: View {
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 1, y: 1)
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let colors: [Color] = [
        Color(red: 0.4, green: 0.2, blue: 0.8),
        Color(red: 0.2, green: 0.5, blue: 0.9),
        Color(red: 0.3, green: 0.8, blue: 0.7)
    ]
    
    var body: some View {
        ZStack {
            // Animated mesh gradient background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: gradientStart,
                        endPoint: gradientEnd
                    )
                )
                .blur(radius: 30)
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut(duration: 2)) {
                        self.gradientStart = UnitPoint(
                            x: CGFloat.random(in: 0...1),
                            y: CGFloat.random(in: 0...1)
                        )
                        self.gradientEnd = UnitPoint(
                            x: CGFloat.random(in: 0...1),
                            y: CGFloat.random(in: 0...1)
                        )
                    }
                }
            
            // Loading indicator
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingScreen()
} 