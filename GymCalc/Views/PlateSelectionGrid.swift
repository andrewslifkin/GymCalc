import SwiftUI

struct PlateSelectionGrid: View {
    @EnvironmentObject private var calculator: Calculator
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Select Available Plates")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(calculator.availablePlates.sorted(), id: \.self) { weight in
                                PlatePill(plateWeight: .constant(weight))
                                    .environmentObject(calculator)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PlateSelectionGrid()
        .environmentObject(Calculator())
} 