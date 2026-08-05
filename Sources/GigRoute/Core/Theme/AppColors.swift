import UIKit

/// Minimal color tokens to unblock M0/M1 screens. This will move into a
/// full design-system module (M5) once more screens exist and patterns
/// stabilize — deliberately not over-built here.
enum AppColors {
    static let background = UIColor.black
    static let cardBackground = UIColor(white: 0.11, alpha: 1)
    static let accent = UIColor.systemOrange
    static let primaryText = UIColor.white
    static let secondaryText = UIColor(white: 0.65, alpha: 1)
}
