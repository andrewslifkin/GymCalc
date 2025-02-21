import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        // Pre-initialize generators
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .soft, .rigid]
        styles.forEach { style in
            impactGenerators[style] = UIImpactFeedbackGenerator(style: style)
        }
        
        // Prepare generators
        impactGenerators.values.forEach { $0.prepare() }
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, intensity: CGFloat = 1.0) {
        guard let generator = impactGenerators[style] else { return }
        generator.impactOccurred(intensity: intensity)
        generator.prepare() // Prepare for next use
    }
    
    func lightImpact() {
        impact(style: .light)
    }
    
    func mediumImpact() {
        impact(style: .medium)
    }
    
    func heavyImpact() {
        impact(style: .heavy)
    }
    
    func sliderChanged() {
        impact(style: .light, intensity: 0.5)
    }
    
    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare() // Prepare for next use
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
        notificationGenerator.prepare() // Prepare for next use
    }
    
    func success() {
        notification(type: .success)
    }
    
    func warning() {
        notification(type: .warning)
    }
    
    func error() {
        notification(type: .error)
    }
}
