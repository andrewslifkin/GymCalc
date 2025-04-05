import SwiftUI

struct WeightConverterView: View {
    @State private var inputWeight: Double = 100
    @State private var selectedUnit: Unit = .kg
    @Environment(\.colorScheme) private var colorScheme
    
    private let weights: [Double] = Array(stride(from: 0.5, through: 500, by: 0.5))
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Unit Toggle
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(Unit.allCases, id: \.self) { unit in
                        Text(unit.symbol)
                            .tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)
                
                // Weight Input
                HStack(spacing: 20) {
                    Button {
                        withAnimation {
                            inputWeight = max(0.5, inputWeight - 2.5)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    TextField("", value: $inputWeight, formatter: NumberFormatter())
                        .frame(minWidth: 100)
                        .font(.system(.title, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Button {
                        withAnimation {
                            inputWeight = min(500, inputWeight + 2.5)
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
                
                // Conversion Table
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 1) {
                            ForEach(weights, id: \.self) { weight in
                                WeightRow(
                                    weight: weight,
                                    unit: selectedUnit
                                )
                                .id(weight)
                                .background(weight == inputWeight ? Color.blue.opacity(0.2) : Color.clear)
                            }
                        }
                        .onChange(of: inputWeight) { oldValue, newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}

struct WeightRow: View {
    let weight: Double
    let unit: Unit
    
    private var convertedWeight: Weight {
        let originalWeight = Weight(value: weight, unit: unit)
        return originalWeight.convert(to: unit == .kg ? .lbs : .kg)
    }
    
    var body: some View {
        HStack {
            Text("\(weight, specifier: "%.1f") \(unit.symbol)")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(convertedWeight.value, specifier: "%.1f") \(convertedWeight.unit.symbol)")
                .foregroundStyle(.gray)
        }
        .font(.system(.body, design: .rounded))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// Required Types
enum Unit: String, CaseIterable, Codable, Hashable {
    case kg, lbs
    
    var symbol: String {
        rawValue.uppercased()
    }
    
    var conversionFactor: Double {
        switch self {
        case .kg: return 1.0
        case .lbs: return 2.20462
        }
    }
}

struct Weight: Codable, Hashable {
    var value: Double
    var unit: Unit
    
    func convert(to targetUnit: Unit) -> Weight {
        guard unit != targetUnit else { return self }
        
        let kgValue = unit == .kg ? value : value / Unit.lbs.conversionFactor
        let convertedValue = targetUnit == .kg ? kgValue : kgValue * Unit.lbs.conversionFactor
        
        return Weight(value: convertedValue.rounded(to: 2), unit: targetUnit)
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}

#Preview {
    WeightConverterView()
        .preferredColorScheme(.dark)
} 