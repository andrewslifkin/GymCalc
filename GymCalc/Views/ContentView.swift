import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var calculator: Calculator
    @EnvironmentObject private var themeManager: ThemeManager
    @Namespace private var namespace
    @FocusState private var focusedField: Field?
    
    // Define accent color to match screenshot
    private let accentColor = Color(red: 235/255, green: 235/255, blue: 25/255)
    private let backgroundCardColor = Color(white: 0.15)
    
    private enum Field {
        case platesWeight, maxRepWeight, repCount
    }
    
    var body: some View {
        TabView {
            mainView
                .tabItem {
                    Label("Calculator", systemImage: "number")
                        .environment(\.symbolVariants, .none)
                }
            
            WeightConverterView()
                .tabItem {
                    Label("Convert", systemImage: "arrow.left.arrow.right")
                        .environment(\.symbolVariants, .none)
                }
                
            settingsView
                .tabItem {
                    Label("Settings", systemImage: "gear")
                        .environment(\.symbolVariants, .none)
                }
        }
        .tint(themeManager.accentColor)
    }
    
    var mainView: some View {
        ZStack {
            // Background
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Mode Toggle
                modeToggle
                    .padding(.vertical)
                
                ScrollView(showsIndicators: false) {
                    // Main Content
                    Group {
                        if calculator.mode == .plates {
                            PlatesView()
                                .padding(.top, 8)
                        } else {
                            MaxRepView()
                                .padding(.top, 8)
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
        HStack(spacing: 0) {
            ForEach(CalculatorMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        calculator.mode = mode
                        // HapticManager.shared.mediumImpact()
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(calculator.mode == mode ? 
                            (themeManager.currentTheme == .light ? themeManager.iconColor : .white) 
                            : themeManager.secondaryTextColor)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background {
                            if calculator.mode == mode {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(calculator.mode == mode ? themeManager.accentColor : Color.clear)
                                    .matchedGeometryEffect(id: "MODE", in: namespace)
                            }
                        }
                }
                .accessibilityLabel(mode == .plates ? "Plate calculator mode" : "One rep max calculator mode")
                .accessibilityAddTraits(calculator.mode == mode ? .isSelected : [])
                .accessibilityHint(calculator.mode == mode ? "Currently selected" : "Double tap to switch mode")
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(themeManager.cardColor)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Calculator mode selection")
    }
    
    var settingsView: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                List {
                    Section {
                        Toggle(isOn: Binding(
                            get: { themeManager.currentTheme == .light },
                            set: { newValue in
                                themeManager.currentTheme = newValue ? .light : .dark
                                // HapticManager.shared.mediumImpact()
                            }
                        )) {
                            Label {
                                Text("Light Mode")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                            } icon: {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(themeManager.accentColor)
                                    .frame(width: 26, height: 26)
                                    .accessibilityHidden(true)
                            }
                        }
                        .toggleStyle(ThemeToggleStyle())
                    } header: {
                        Text("Appearance")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .textCase(nil)
                            .padding(.top, 8)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.lightBackgroundColor)
                            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    )
                    
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Version")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(themeManager.secondaryTextColor)
                                    .font(.subheadline)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("App version 1.0.0")
                            .padding(.vertical, 6)
                            
                            Link(destination: URL(string: "https://example.com/privacy")!) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.headline)
                                        .foregroundColor(themeManager.textColor)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 16))
                                        .foregroundColor(themeManager.accentColor)
                                }
                                .padding(.vertical, 6)
                            }
                            .accessibilityHint("Opens privacy policy in external browser")
                            
                            Link(destination: URL(string: "https://example.com/terms")!) {
                                HStack {
                                    Text("Terms of Service")
                                        .font(.headline)
                                        .foregroundColor(themeManager.textColor)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 16))
                                        .foregroundColor(themeManager.accentColor)
                                }
                                .padding(.vertical, 6)
                            }
                            .accessibilityHint("Opens terms of service in external browser")
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("About")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .textCase(nil)
                            .padding(.top, 8)
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.lightBackgroundColor)
                            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    )
                }
                .scrollContentBackground(.hidden)
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Settings")
            }
        }
    }
}

struct PlatesView: View {
    @EnvironmentObject private var calculator: Calculator
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showAddBarbell = false
    @State private var showPlateSelection = false
    @State private var showEquipmentSelection = false
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
                
                Divider()
                    .padding(.horizontal)
                
                // Available Plates Button
                HStack(spacing: 20) {
                    Button {
                        showPlateSelection = true
                    } label: {
                        IconButtonLabel(icon: "square.grid.2x2", label: "Plates", accentColor: themeManager.accentColor)
                    }
                    
                    Button {
                        showEquipmentSelection = true
                    } label: {
                        IconButtonLabel(icon: "dumbbell", label: "Equipment", accentColor: themeManager.accentColor)
                    }
                }
                .padding(.horizontal)
                .sheet(isPresented: $showEquipmentSelection) {
                    EquipmentSelectionView(weightSuggestion: $weightSuggestion)
                }
                .sheet(isPresented: $showPlateSelection) {
                    PlateSelectionGrid(weightSuggestion: $weightSuggestion)
                }
                
                // Plates Display
                if !calculator.platesPerSide.isEmpty {
                    PlateVisualizer(plateCounts: calculator.platesPerSide, unit: calculator.selectedUnit)
                        .transition(.opacity)
                        .padding(.horizontal)
                }
            }
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

struct MaxRepView: View {
    @EnvironmentObject private var calculator: Calculator
    @EnvironmentObject private var themeManager: ThemeManager
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
                    .foregroundColor(themeManager.secondaryTextColor)
                
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
                            .foregroundStyle(themeManager.textColor)
                            .frame(width: 44, height: 44)
                            .background(themeManager.cardColor)
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
                            .foregroundStyle(themeManager.textColor)
                            .frame(width: 44, height: 44)
                            .background(themeManager.cardColor)
                            .clipShape(Circle())
                    }
                    .disabled(calculator.repCount >= 12)
                }
            }
            
            // Percentage Breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Training Percentages")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryTextColor)
                
                if calculator.percentageBreakdown.isEmpty {
                    Text("Enter weight and reps to see training percentages")
                        .font(.body)
                        .foregroundColor(themeManager.secondaryTextColor)
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
                        .fontWeight(.medium)
                        .foregroundStyle(themeManager.secondaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.currentTheme == .light ? Color(hex: "#F5F5F5") : Color.white.opacity(0.05))
                        
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
                                    .foregroundStyle(themeManager.secondaryTextColor)
                            }
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(themeManager.textColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(themeManager.currentTheme == .light ? Color(hex: "#FCFCFC") : Color.white.opacity(0.03))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(themeManager.currentTheme == .light ? Color(hex: "#E5E5E5") : Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(
                        color: themeManager.currentTheme == .light ? Color.black.opacity(0.03) : Color.clear,
                        radius: 4, x: 0, y: 2
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
        .environmentObject(ThemeManager())
        .preferredColorScheme(.dark)
} 