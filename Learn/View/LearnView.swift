//
//  LearnView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct LearnView: View {
    private let progressManager = LearnProgressManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) {
                    // Module 1: IUPAC Naming
                    ModuleCard(
                        tag: "MODULE 1",
                        color: .blue,
                        title: "IUPAC Naming",
                        description: "Learn how compounds are named step-by-step",
                        icon: AnyView(
                            Image(systemName: "flask.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .accessibilityHidden(true)
                        ),
                        actionText: moduleActionText(module: "naming"),
                        destination: AnyView(ModuleGroupSelectorView(module: .naming))
                    )
                    
                    // Module 2: Explore Structure
                    ModuleCard(
                        tag: "MODULE 2",
                        color: .purple,
                        title: "Explore Structure",
                        description: "See how carbon forms bonds and builds compounds",
                        icon: AnyView(
                            Image(systemName: "atom")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .accessibilityHidden(true)
                        ),
                        actionText: moduleActionText(module: "structure"),
                        destination: AnyView(ModuleGroupSelectorView(module: .structure))
                    )
                    
                    // Module 3: Reactions
                    ModuleCard(
                        tag: "MODULE 3",
                        color: .orange,
                        title: "Reactions",
                        description: "Understand key chemical reactions",
                        icon: AnyView(
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .accessibilityHidden(true)
                        ),
                        actionText: moduleActionText(module: "reactions"),
                        destination: AnyView(ModuleGroupSelectorView(module: .reactions))
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Progress Helpers
    
    /// Action text based on whether any group has been started for this module.
    private func moduleActionText(module: String) -> String {
        let groups = HydrocarbonGroup.allCases
        let allCompleted = groups.allSatisfy { progressManager.isCompleted(group: $0, module: module) }
        let anyStarted = groups.contains { progressManager.hasStarted(group: $0, module: module) }
        
        if allCompleted { return "Review" }
        if anyStarted { return "Continue" }
        return "Start"
    }
}

#Preview {
    LearnView()
        .preferredColorScheme(.dark)
}
