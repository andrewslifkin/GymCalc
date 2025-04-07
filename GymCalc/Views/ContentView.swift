import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var calculator: Calculator
    @Namespace private var namespace
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case platesWeight, maxRepWeight, repCount
    }
    
    var body: some View {
        TabView {
            mainView
                .tabItem {
                    Label("Calculator", systemImage: "number")
                }
            
            WeightConverterView()
                .tabItem {
                    Label("Convert", systemImage: "arrow.left.arrow.right")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
    
    var mainView: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Mode Toggle
                modeToggle
                    .padding(.vertical)
                
                ScrollView(showsIndicators: false) {
                    // Main Content
                    Group {
                        if calculator.mode == .plates {
                            PlatesView()
                        } else {
                            MaxRepView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                        removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                    ))
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("GymCalc")
    }
    
    var modeToggle: some View {
        HStack(spacing: 20) {
            ForEach(CalculatorMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        calculator.mode = mode
                        HapticManager.shared.mediumImpact()
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(calculator.mode == mode ? .white : .gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background {
                            if calculator.mode == mode {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.1))
                                    .matchedGeometryEffect(id: "MODE", in: namespace)
                            }
                        }
                }
                .accessibilityLabel(mode == .plates ? "Plate calculator mode" : "One rep max calculator mode")
                .accessibilityAddTraits(calculator.mode == mode ? .isSelected : [])
                .accessibilityHint(calculator.mode == mode ? "Currently selected" : "Double tap to switch mode")
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Calculator mode selection")
    }
}

struct PlatesView: View {
    @EnvironmentObject private var calculator: Calculator
    @State private var showAddBarbell = false
    @State private var showPlateSelection = false
    @FocusState private var focusedField: Field?
    @State private var weightSuggestion: WeightSuggestion?
    
    private enum Field: Int {
        case weight
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                // Weight Input
                WeightInput(targetWeight: $calculator.targetWeight)
                    .onChange(of: calculator.targetWeight) { _, newValue in
                        weightSuggestion = calculator.checkWeightAchievability(targetWeight: newValue)
                    }
                
                // Weight Suggestion (if not achievable)
                if let suggestion = weightSuggestion, !suggestion.isAchievable {
                    WeightSuggestionView(suggestion: suggestion, targetWeight: $calculator.targetWeight)
                        .padding(.horizontal)
                        .transition(.opacity)
                }
                
                // Barbell Preset Carousel
                BarbellPresetCarousel()
                
                Divider()
                    .padding(.horizontal)
                
                // Available Plates Button
                Button {
                    showPlateSelection = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Available Plates")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(calculator.selectedPlateWeights.sorted()
                                .map { String(format: "%.1f", $0) }
                                .joined(separator: ", ") + "kg")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.up")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Plates Display
                if !calculator.platesPerSide.isEmpty {
                    PlateVisualizer(plateCounts: calculator.platesPerSide, unit: calculator.selectedUnit)
                        .transition(.opacity)
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $showPlateSelection) {
            PlateSelectionGrid()
        }
    }
}

struct WhiteTintToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .animation(.spring(), value: configuration.isOn)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

struct BarbellPresetCarousel: View {
    @EnvironmentObject private var calculator: Calculator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Equipment")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(calculator.availableBarbells.filter(\.isVisible)) { barbell in
                        Button {
                            withAnimation {
                                calculator.selectedBarbell = barbell
                                HapticManager.shared.lightImpact()
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(barbell.name)
                                    .font(.headline)
                                    .foregroundColor(calculator.selectedBarbell.id == barbell.id ? .blue : .gray)
                                    .lineLimit(1)
                                
                                Text("\(barbell.weight.value, specifier: "%.1f") \(barbell.weight.unit.symbol)")
                                    .font(.subheadline)
                                    .foregroundColor(calculator.selectedBarbell.id == barbell.id ? .blue.opacity(0.8) : .gray)
                            }
                            .frame(width: 160)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(calculator.selectedBarbell.id == barbell.id ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(calculator.selectedBarbell.id == barbell.id ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MaxRepView: View {
    @EnvironmentObject private var calculator: Calculator
    @FocusState private var focusedField: Field?
    
    private enum Field: Int {
        case weight, reps
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 20)
            // Weight Input
            WeightInput(targetWeight: $calculator.targetWeight)
            
            // Rep Count
            VStack(spacing: 16) {
                Text("Reps")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    Button {
                        if calculator.repCount > 1 {
                            withAnimation {
                                calculator.repCount -= 1
                            }
                            HapticManager.shared.lightImpact()
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(calculator.repCount <= 1)
                    
                    TextField("", value: $calculator.repCount, format: .number)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .reps)
                    
                    Button {
                        if calculator.repCount < 12 {
                            withAnimation {
                                calculator.repCount += 1
                            }
                            HapticManager.shared.lightImpact()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(calculator.repCount >= 12)
                }
            }
            
            // Percentage Breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Training Percentages")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if calculator.percentageBreakdown.isEmpty {
                    Text("Enter weight and reps to see training percentages")
                        .font(.body)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 1) {
                        // Header
                        HStack {
                            Text("Percentage")
                                .frame(width: 100, alignment: .leading)
                            Text("Weight")
                                .frame(width: 100, alignment: .leading)
                            Text("Reps")
                                .frame(width: 80, alignment: .trailing)
                        }
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.05))
                        
                        // Rows
                        ForEach(calculator.percentageBreakdown) { breakdown in
                            HStack {
                                Text("\(breakdown.percentage)%")
                                    .frame(width: 100, alignment: .leading)
                                    .fontWeight(.medium)
                                
                                Text("\(breakdown.displayWeight) \(calculator.selectedUnit.symbol)")
                                    .frame(width: 100, alignment: .leading)
                                    .fontWeight(.medium)
                                
                                Text("\(breakdown.reps)")
                                    .frame(width: 80, alignment: .trailing)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.03))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
            }
            Spacer()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Calculator())
        .preferredColorScheme(.dark)
} 