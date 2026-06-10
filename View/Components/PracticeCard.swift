//
//  PracticeCard.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI


// Card shown in PracticeView for each available quiz level.

struct PracticeCard: View {
    let level: PracticeLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("LEVEL \(level.id)")
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
                .padding(.top, 2)
                .padding(.bottom, -2)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 4) {
                Text(level.title)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Text(level.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 4)

            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: "atom")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .accessibilityHidden(true) // decorative

                Spacer()

                NavigationLink(destination: QuizView(type: level.type)) {
                    HStack(spacing: 4) {
                        Text("Start").font(.headline)
                        Image(systemName: "arrow.right").font(.system(size: 12, weight: .bold))
                            .accessibilityHidden(true)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial.opacity(0.5))
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(AppButtonStyle())
                .accessibilityLabel("Start \(level.title)")
                .accessibilityHint("Begins the \(level.subtitle) quiz")
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
    }
}
