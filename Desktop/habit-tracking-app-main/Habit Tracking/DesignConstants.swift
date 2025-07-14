import SwiftUI

struct DesignConstants {
    // MARK: - Colors
    static let primaryColor = Color(red: 0.2, green: 0.3, blue: 0.5)
    static let secondaryColor = Color(red: 0.9, green: 0.8, blue: 0.7)
    static let backgroundColor = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let textColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let accentColor = Color(red: 0.8, green: 0.6, blue: 0.4)
    static let successColor = Color(red: 0.4, green: 0.7, blue: 0.4)
    static let errorColor = Color(red: 0.8, green: 0.3, blue: 0.3)
    
    // MARK: - Typography
    static let titleFont = Font.system(size: 32, weight: .bold, design: .rounded)
    static let subtitleFont = Font.system(size: 18, weight: .medium, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .light, design: .rounded)
    static let buttonFont = Font.system(size: 16, weight: .semibold, design: .rounded)
    
    // MARK: - Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // MARK: - Corner Radius
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 20
    
    // MARK: - Button Heights
    static let buttonHeight: CGFloat = 50
    static let smallButtonHeight: CGFloat = 40
    
    // MARK: - Animation Durations
    static let shortAnimation: Double = 0.3
    static let mediumAnimation: Double = 0.5
    static let longAnimation: Double = 0.8
    
    // MARK: - Flower Types
    static let flowerTypes = [
        "flower_1", "flower_2", "flower_3", "flower_4", "flower_5",
        "flower_6", "flower_7", "flower_8", "flower_9", "flower_10",
        "flower_11", "flower_12", "flower_13", "flower_14", "flower_15",
        "flower_16", "flower_17", "flower_18", "flower_19", "flower_20"
    ]
    
    static func randomFlowerType() -> String {
        return flowerTypes.randomElement() ?? "flower_1"
    }
    
    // MARK: - Day Names
    static let dayNames = ["M", "T", "W", "T", "F", "S", "S"]
    static let fullDayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
}

// MARK: - Custom Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignConstants.buttonFont)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignConstants.buttonHeight)
            .background(DesignConstants.primaryColor)
            .cornerRadius(DesignConstants.mediumCornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: DesignConstants.shortAnimation), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignConstants.buttonFont)
            .foregroundColor(DesignConstants.primaryColor)
            .frame(maxWidth: .infinity)
            .frame(height: DesignConstants.buttonHeight)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: DesignConstants.mediumCornerRadius)
                    .stroke(DesignConstants.primaryColor, lineWidth: 2)
            )
            .cornerRadius(DesignConstants.mediumCornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: DesignConstants.shortAnimation), value: configuration.isPressed)
    }
} 