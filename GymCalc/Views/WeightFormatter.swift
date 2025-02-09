import Foundation

class WeightFormatter: NumberFormatter, @unchecked Sendable {
    override init() {
        super.init()
        self.numberStyle = .decimal
        self.maximumFractionDigits = 1
        self.minimumFractionDigits = 0
        self.alwaysShowsDecimalSeparator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
