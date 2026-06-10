//
//  Styles.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct HapticManager {
    static let shared = HapticManager()
    
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        shared.play(style)
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        shared.notify(type)
    }
    
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// Interaction Constants
struct InteractionConstants {
    static let springResponse:  Double  = 0.35
    static let springDamping:   Double  = 0.7
    static let pressDuration:   Double  = 0.15
    static let minimumTapTarget: CGFloat = 44
}

// Bond Symbol View
// Used to represent Single, Double, and Triple bonds consistently across the app.
struct BondSymbolView: View {
    enum BondType { case single, double, triple }
    let type: BondType
    let color: Color
    
    var body: some View {
        VStack(spacing: 2.5) {
            switch type {
            case .single:
                Spacer()
                line
                Spacer()
            case .double:
                Spacer()
                line
                line
                Spacer()
            case .triple:
                line
                line
                line
            }
        }
        .frame(width: 20, height: 14)
    }
    
    private var line: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(height: 2)
    }
}

// Button Styles
struct AppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(
                configuration.isPressed
                    ? .easeInOut(duration: InteractionConstants.pressDuration)
                    : .spring(response: InteractionConstants.springResponse, dampingFraction: InteractionConstants.springDamping),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticManager.impact(.light) }
            }
    }
}

// Used on card shaped tappable areas  softer scale and soft haptic.
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(
                configuration.isPressed
                    ? .easeInOut(duration: InteractionConstants.pressDuration)
                    : .spring(response: InteractionConstants.springResponse, dampingFraction: InteractionConstants.springDamping),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticManager.impact(.soft) }
            }
    }
}

// Used on forward/back navigation arrows in Learn modules.
struct NavigationArrowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(
                configuration.isPressed
                    ? .easeInOut(duration: InteractionConstants.pressDuration)
                    : .spring(response: 0.4, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticManager.impact(.light) }
            }
    }
}

/// Used on icon buttons in the navigation toolbar (AR, Delete, etc.)
struct ToolbarIconStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(
                configuration.isPressed
                    ? .easeInOut(duration: InteractionConstants.pressDuration)
                    : .spring(response: InteractionConstants.springResponse, dampingFraction: InteractionConstants.springDamping),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticManager.impact(.light) }
            }
    }
}

// Used on multiple-choice quiz answer options.
struct QuizOptionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(
                configuration.isPressed
                    ? .easeInOut(duration: InteractionConstants.pressDuration)
                    : .spring(response: InteractionConstants.springResponse, dampingFraction: InteractionConstants.springDamping),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticManager.impact(.medium) }
            }
    }
}

// Used on the frosted glass circular action buttons in the AR view.
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(
                configuration.isPressed
                    ? .easeInOut(duration: InteractionConstants.pressDuration)
                    : .spring(response: InteractionConstants.springResponse, dampingFraction: InteractionConstants.springDamping),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticManager.impact(.light) }
            }
    }
}
