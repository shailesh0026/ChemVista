//
//  ReactionsView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct ReactionsView: View {
    let group: HydrocarbonGroup
    @State private var viewModel: ReactionsViewModel
    @Environment(\.dismiss) var dismiss

    init(group: HydrocarbonGroup = .alkane) {
        self.group = group
        _viewModel = State(wrappedValue: ReactionsViewModel(group: group))
    }

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundColor()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Progress
                    Text(viewModel.progressText)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 24)
                        .accessibilityLabel("Step \(viewModel.progressText)")

                    Text(viewModel.currentReaction.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                        .accessibilityAddTraits(.isHeader)

                    // Reaction content card
                    reactionCard
                        .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.bottom, 120) // Prevent card from overlapping buttons
            }

            // Navigation arrows layer
            VStack {
                Spacer()
                HStack {
                    Button {
                        withAnimation {
                            if viewModel.currentIndex > 0 {
                                viewModel.loadReaction(at: viewModel.currentIndex - 1)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.left.circle")
                            .font(.system(size: 56))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(NavigationArrowStyle())
                    .disabled(viewModel.currentIndex == 0)
                    .opacity(viewModel.currentIndex == 0 ? 0.3 : 1)
                    .accessibilityLabel("Previous reaction")

                    Spacer()

                    Button {
                        withAnimation {
                            if viewModel.currentIndex < viewModel.reactions.count - 1 {
                                viewModel.loadReaction(at: viewModel.currentIndex + 1)
                            } else {
                                viewModel.completeModule()
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.currentIndex == viewModel.reactions.count - 1 ? "checkmark.circle" : "arrow.right.circle")
                            .font(.system(size: 56))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(NavigationArrowStyle())
                    .accessibilityLabel(viewModel.currentIndex == viewModel.reactions.count - 1 ? "Complete module" : "Next reaction")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle("\(group.displayName) Reactions")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: viewModel.currentIndex)
    }

    // MARK: - Reaction Card

    private var reactionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Reaction type badge
            Text(viewModel.currentReaction.reactionType.uppercased())
                .font(.caption.weight(.bold))
                .foregroundColor(group.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(group.color.opacity(0.15))
                )

            // Equation
            VStack(alignment: .leading, spacing: 6) {
                Text("EQUATION")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                Text(viewModel.currentReaction.equation)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)

            // Explanation
            VStack(alignment: .leading, spacing: 6) {
                Text("HOW IT WORKS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                Text(viewModel.currentReaction.explanation)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(4)
                    .truncationMode(.tail)
                    .frame(minHeight: 90, alignment: .topLeading)
            }

            // Key point
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)

                Text(viewModel.currentReaction.keyPoint)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(minHeight: 48, alignment: .topLeading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.15), lineWidth: 0.5)
                    )
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        ReactionsView(group: .alkane)
            .preferredColorScheme(.dark)
    }
}
