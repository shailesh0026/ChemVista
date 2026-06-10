//
//  CompoundCard.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct CompoundCard: View {
    let compound: CompoundPreset

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(compound.name.prefix(1))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                    .accessibilityHidden(true)

                Spacer()

                Text(compound.type)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(compound.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .accessibilityHidden(true)

                Text(compound.formula)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.thinMaterial.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .accessibilityHidden(true) 
    }
}

#Preview {
    CompoundCard(compound: CompoundLibrary.all[0])
        .padding()
        .background(Color.black)
}
