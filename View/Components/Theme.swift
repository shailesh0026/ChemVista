//
//  Theme.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

// App Colors

extension Color {
    static let appBackground = Color(red: 0.05, green: 0.07, blue: 0.12)
    static let appAccent = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let appTextSecondary = Color.gray
    static let appTagBackground = Color(red: 0.08, green: 0.15, blue: 0.25)
}

// Background View
struct BackgroundColor: View {
    var body: some View {
        ZStack {
            Color(red: 3/255, green: 2/255, blue: 8/255)
                .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [Color(red: 60/255, green: 10/255, blue: 120/255).opacity(0.3), .clear]),
                center: UnitPoint(x: 0.1, y: 0.1),
                startRadius: 0,
                endRadius: 400
            )
            .blur(radius: 40)
            .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [Color(red: 60/255, green: 10/255, blue: 120/255).opacity(0.3), .clear]),
                center: UnitPoint(x: 0.9, y: 0.8),
                startRadius: 0,
                endRadius: 350
            )
            .blur(radius: 45)
            .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [Color(red: 100/255, green: 20/255, blue: 80/255).opacity(0.3), .clear]),
                center: UnitPoint(x: 0.5, y: 0.5),
                startRadius: 0,
                endRadius: 300
            )
            .blur(radius: 50)
            .ignoresSafeArea()
        }
    }
}

// Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    BackgroundColor()
}

