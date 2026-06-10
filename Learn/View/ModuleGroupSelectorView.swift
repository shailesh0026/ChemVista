//
//  ModuleGroupSelectorView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

// Identifies which module the user is entering.
enum LearnModule: String {
    case naming, structure, reactions

    var displayTitle: String {
        switch self {
        case .naming:    return "IUPAC Naming"
        case .structure: return "Explore Structure"
        case .reactions: return "Reactions"
        }
    }

    var icon: String {
        switch self {
        case .naming:    return "flask.fill"
        case .structure: return "atom"
        case .reactions: return "bolt.fill"
        }
    }

    var moduleKey: String { rawValue }
}

// Intermediate screen: user picks Alkane, Alkene, or Alkyne before
// entering the actual module content.
struct ModuleGroupSelectorView: View {
    let module: LearnModule
    private let progressManager = LearnProgressManager.shared

    var body: some View {
        ZStack {
            BackgroundColor()

            ScrollView {
                VStack(spacing: 12) {

                    // Group cards
                    ForEach(HydrocarbonGroup.allCases) { group in
                        NavigationLink(destination: destinationView(for: group)) {
                            GroupCard(
                                group: group,
                                module: module.moduleKey,
                                progressManager: progressManager
                            )
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle(module.displayTitle)
        .navigationBarTitleDisplayMode(.large)
    }

    // Returns the correct content view based on the module type.
    @ViewBuilder
    private func destinationView(for group: HydrocarbonGroup) -> some View {
        switch module {
        case .naming:
            NamingView(group: group)
        case .structure:
            StructureLearningView(group: group)
        case .reactions:
            ReactionsView(group: group)
        }
    }
}

// MARK: - Group Card

private struct GroupCard: View {
    let group: HydrocarbonGroup
    let module: String
    let progressManager: LearnProgressManager

    private var actionLabel: String {
        progressManager.actionText(group: group, module: module)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(group.displayName.uppercased())
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .accessibilityAddTraits(.isHeader)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(group.suffix)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Text(group.bondDescription)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding(.bottom, 10)
            
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    BondSymbolView(
                        type: group == .alkane ? .single : (group == .alkene ? .double : .triple),
                        color: .white
                    )
                    .scaleEffect(1.2)
                }
                .accessibilityHidden(true)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(actionLabel).fontWeight(.bold)
                    Image(systemName: "arrow.right").fontWeight(.bold)
                        .accessibilityHidden(true)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
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
        ModuleGroupSelectorView(module: .naming)
            .preferredColorScheme(.dark)
    }
}
