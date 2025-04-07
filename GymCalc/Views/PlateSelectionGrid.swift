import SwiftUI

struct PlateSelectionGrid: View {
    @EnvironmentObject private var calculator: Calculator
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Available Plates")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                }
                .padding()
                .background(Color.black)
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(calculator.availablePlateWeights.sorted(), id: \.self) { weight in
                            PlatePill(plateWeight: .constant(weight))
                                .environmentObject(calculator)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black)
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.black)
            .presentationCornerRadius(32)
        }
    }
}

#Preview {
    PlateSelectionGrid()
        .environmentObject(Calculator())
} 