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
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                focusedField = nil
                            }
                        }
                    }
                
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
    @FocusState private var focusedField: Field?
    @State private var weightSuggestion: WeightSuggestion?
    
    private enum Field: Int {
        case weight
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 20)
            
            // Weight Input
            WeightInput()
                .onChange(of: calculator.targetWeight) { oldValue, newValue in
                    weightSuggestion = calculator.checkWeightAchievability(targetWeight: newValue)
                }
            
            // Barbell Preset Carousel
            BarbellPresetCarousel()
            
            Spacer()
                .frame(height: 16)
            
            // Plates Display
            PlateVisualizer(plateCounts: calculator.platesPerSide, unit: calculator.selectedUnit)
                .transition(.opacity)
            
            if let suggestion = weightSuggestion, !suggestion.isAchievable {
                VStack(alignment: .leading, spacing: 8) {
                    Text("❌ The requested weight (\(suggestion.targetWeight, specifier: "%.1f")\(suggestion.unit.symbol)) is not achievable with standard plates.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                    
                    HStack(spacing: 16) {
                        Button {
                            calculator.targetWeight = suggestion.lowerWeight
                        } label: {
                            Text("🔽 \(suggestion.lowerWeight, specifier: "%.1f")\(suggestion.unit.symbol)")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            calculator.targetWeight = suggestion.higherWeight
                        } label: {
                            Text("🔼 \(suggestion.higherWeight, specifier: "%.1f")\(suggestion.unit.symbol)")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
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
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Barbell Weight Toggle
                Toggle("", isOn: $calculator.considerBarbellWeight)
                    .labelsHidden()
                    .toggleStyle(WhiteTintToggleStyle())
                    .padding(.leading, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(calculator.availableBarbells.filter { $0.isVisible }) { barbell in
                            Button {
                                withAnimation {
                                    calculator.selectedBarbell = barbell
                                }
                            } label: {
                                Text(barbell.name)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(
                                        calculator.selectedBarbell.id == barbell.id && calculator.considerBarbellWeight 
                                        ? .white 
                                        : .gray
                                    )
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(
                                        calculator.selectedBarbell.id == barbell.id && calculator.considerBarbellWeight
                                        ? Color.white.opacity(0.1) 
                                        : Color.clear
                                    )
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .opacity(calculator.considerBarbellWeight ? 1.0 : 0.5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Plate Weight Carousel
            PlateWeightCarousel()
        }
    }
}

struct PlateWeightCarousel: View {
    @EnvironmentObject private var calculator: Calculator
    
    private func isPlateSelected(_ plateWeight: Double) -> Bool {
        calculator.selectedPlateWeights.contains(plateWeight)
    }
    
    private func plateTextColor(_ plateWeight: Double) -> Color {
        isPlateSelected(plateWeight) ? .white : .gray
    }
    
    private func plateBackground(_ plateWeight: Double) -> Color {
        isPlateSelected(plateWeight) ? Color.white.opacity(0.1) : .clear
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(calculator.availablePlateWeights, id: \.self) { plateWeight in
                    Button {
                        withAnimation {
                            // Toggle plate selection and invalidate cache
                            if calculator.selectedPlateWeights.contains(plateWeight) {
                                calculator.selectedPlateWeights.removeAll { $0 == plateWeight }
                            } else {
                                calculator.selectedPlateWeights.append(plateWeight)
                            }
                            
                            // Invalidate cache to force recalculation
                            calculator.cachedPlates = nil
                            
                            HapticManager.shared.lightImpact()
                        }
                    } label: {
                        Text("\(plateWeight, specifier: "%.1f")")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(plateTextColor(plateWeight))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(plateBackground(plateWeight))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct WeightInput: View {
    @EnvironmentObject private var calculator: Calculator
    @FocusState private var focusedField: Field?
    @State private var weightSuggestion: WeightSuggestion?
    
    private enum Field: Int {
        case weight
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Weight Input with Plus/Minus Buttons
            HStack(spacing: 20) {
                Button {
                    withAnimation {
                        calculator.targetWeight = max(20, calculator.targetWeight - 2.5)
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
                
                NumberField(
                    value: $calculator.targetWeight, 
                    formatter: WeightFormatter()
                )
                .frame(minWidth: 100)
                .onChange(of: calculator.targetWeight) { oldValue, newValue in
                    weightSuggestion = calculator.checkWeightAchievability(targetWeight: newValue)
                    HapticManager.shared.lightImpact()
                }
                
                Button {
                    withAnimation {
                        calculator.targetWeight = min(300, calculator.targetWeight + 2.5)
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
            }
            .padding(.vertical, 8)
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
            // Weight Input (reused from PlatesView)
            WeightInput()
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            
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
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .reps)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            if let textField = obj.object as? UITextField {
                                textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                            }
                        }
                    
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
