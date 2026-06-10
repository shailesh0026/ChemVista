//
//  AtomStepper.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct AtomStepper: View {
    let symbol: String
    let color: Color
    let textColor: Color
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color)
                    .frame(width: 50, height: 50)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
                Text(symbol)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
            }
            .accessibilityHidden(true) // decorative; stepper label carries the info
            Stepper("Add or remove \(symbol == "H" ? "Hydrogen" : "Carbon") atoms", onIncrement: {
                HapticManager.shared.play(.light)
                onAdd()
            }, onDecrement: {
                HapticManager.shared.play(.light)
                onRemove()
            })
                .labelsHidden()
                .accessibilityLabel("Add or remove \(symbol == "H" ? "Hydrogen" : "Carbon") atoms")
                .accessibilityHint("\(symbol == "H" ? "Hydrogen" : "Carbon") stepper")
        }
    }
}
