//
//  ReactionsViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation

@Observable
class ReactionsViewModel {
    var reactions: [ReactionStep] = []
    var currentIndex: Int = 0
    
    let group: HydrocarbonGroup
    private let progressManager = LearnProgressManager.shared
    
    var currentReaction: ReactionStep {
        reactions[currentIndex]
    }
    
    var progressText: String {
        "\(currentIndex + 1) of \(reactions.count)"
    }
    
    init(group: HydrocarbonGroup = .alkane) {
        self.group = group
        setupReactions()
        currentIndex = 0
    }
    
    func loadReaction(at index: Int) {
        guard index >= 0 && index < reactions.count else { return }
        currentIndex = index
        progressManager.saveStep(group: group, module: "reactions", step: index, total: reactions.count)
    }
    
    func completeModule() {
        HapticManager.shared.notify(.success)
        progressManager.markCompleted(group: group, module: "reactions")
    }
    
    // MARK: - Reaction Data
    
    private func setupReactions() {
        switch group {
        case .alkane:
            setupAlkaneReactions()
        case .alkene:
            setupAlkeneReactions()
        case .alkyne:
            setupAlkyneReactions()
        }
    }
    
    private func setupAlkaneReactions() {
        reactions = [
            ReactionStep(
                group: .alkane,
                title: "Combustion",
                reactionType: "Oxidation",
                equation: "CH₄ + 2O₂ → CO₂ + 2H₂O",
                explanation: "Alkanes burn in oxygen to produce carbon dioxide and water. This highly exothermic reaction releases significant energy, making them excellent fuels.",
                keyPoint: "Complete combustion needs plenty of oxygen."
            ),
            ReactionStep(
                group: .alkane,
                title: "Incomplete Combustion",
                reactionType: "Oxidation",
                equation: "2CH₄ + 3O₂ → 2CO + 4H₂O",
                explanation: "Restricted oxygen produces poisonous carbon monoxide or solid soot instead of CO₂. This creates a smoky, yellow flame and releases much less energy.",
                keyPoint: "Limited oxygen = dangerous carbon monoxide."
            ),
            ReactionStep(
                group: .alkane,
                title: "Halogenation",
                reactionType: "Substitution",
                equation: "CH₄ + Cl₂ → CH₃Cl + HCl",
                explanation: "UV light triggers the replacement of a hydrogen atom with a halogen like chlorine. This free radical substitution creates a reactive haloalkane product.",
                keyPoint: "Requires UV light to start the reaction."
            ),
            ReactionStep(
                group: .alkane,
                title: "Further Halogenation",
                reactionType: "Substitution",
                equation: "CH₃Cl + Cl₂ → CH₂Cl₂ + HCl",
                explanation: "This substitution chain reaction can continue repeatedly. It progressively replaces remaining hydrogen atoms with additional chlorine atoms step by step.",
                keyPoint: "Each step replaces one more H with Cl."
            ),
            ReactionStep(
                group: .alkane,
                title: "Cracking",
                reactionType: "Decomposition",
                equation: "C₁₀H₂₂ → C₅H₁₂ + C₅H₁₀",
                explanation: "Heavy alkane molecules are thermally broken down into smaller, useful fragments. This crucial industrial process yields shorter alkanes and reactive alkenes.",
                keyPoint: "Makes large molecules into useful smaller ones."
            )
        ]
    }
    
    private func setupAlkeneReactions() {
        reactions = [
            ReactionStep(
                group: .alkene,
                title: "Hydrogenation",
                reactionType: "Addition",
                equation: "C₂H₄ + H₂ → C₂H₆",
                explanation: "Hydrogen gas adds across the double bond using a nickel catalyst. The double bond opens to accept hydrogen atoms, converting the alkene to an alkane.",
                keyPoint: "Alkene + H₂ → Alkane (needs Ni catalyst)"
            ),
            ReactionStep(
                group: .alkene,
                title: "Halogenation",
                reactionType: "Addition",
                equation: "C₂H₄ + Br₂ → C₂H₄Br₂",
                explanation: "Bromine rapidly adds across the carbon double bond. The brown bromine water is quickly decolourised, serving as the classic visual test for unsaturation.",
                keyPoint: "Bromine water turns colourless = alkene present."
            ),
            ReactionStep(
                group: .alkene,
                title: "Hydration",
                reactionType: "Addition",
                equation: "C₂H₄ + H₂O → C₂H₅OH",
                explanation: "Water adds across the double bond in the presence of a strong acid catalyst like H₃PO₄. This vital industrial process successfully produces a liquid alcohol.",
                keyPoint: "Alkene + Water → Alcohol"
            ),
            ReactionStep(
                group: .alkene,
                title: "Hydrohalogenation",
                reactionType: "Addition",
                equation: "C₂H₄ + HBr → C₂H₅Br",
                explanation: "A hydrogen halide like HBr adds across the double bond. Hydrogen attaches to one carbon, while the halogen attaches to the adjacent carbon.",
                keyPoint: "Follows Markovnikov's rule in unsymmetrical alkenes."
            ),
            ReactionStep(
                group: .alkene,
                title: "Polymerization",
                reactionType: "Addition",
                equation: "nC₂H₄ → (C₂H₄)ₙ",
                explanation: "Thousands of small alkene molecules (monomers) link to form giant chain polymers. Common plastics like polyethene are made this way.",
                keyPoint: "Small molecules join to form plastics."
            ),
            ReactionStep(
                group: .alkene,
                title: "Combustion",
                reactionType: "Oxidation",
                equation: "C₂H₄ + 3O₂ → 2CO₂ + 2H₂O",
                explanation: "Like alkanes, alkenes burn in oxygen. Their higher carbon-to-hydrogen ratio means they often burn incompletely, producing a smoky yellow flame.",
                keyPoint: "Alkenes burn with a smokier flame than alkanes."
            )
        ]
    }
    
    private func setupAlkyneReactions() {
        reactions = [
            ReactionStep(
                group: .alkyne,
                title: "Hydrogenation (Partial)",
                reactionType: "Addition",
                equation: "C₂H₂ + H₂ → C₂H₄",
                explanation: "Using a specialized Lindlar's catalyst, only one equivalent of hydrogen adds to the triple bond. This controlled reaction cleanly stops at the alkene stage.",
                keyPoint: "Lindlar's catalyst stops at the alkene stage."
            ),
            ReactionStep(
                group: .alkyne,
                title: "Full Hydrogenation",
                reactionType: "Addition",
                equation: "C₂H₂ + 2H₂ → C₂H₆",
                explanation: "With excess hydrogen and a metal catalyst like Ni or Pt, both pi bonds break. This reduces the alkyne directly into an alkane.",
                keyPoint: "Alkyne + 2H₂ → Alkane"
            ),
            ReactionStep(
                group: .alkyne,
                title: "Halogenation",
                reactionType: "Addition",
                equation: "C₂H₂ + 2Br₂ → C₂H₂Br₄",
                explanation: "Bromine effectively adds across the triple bond in two distinct stages. The highly reactive triple bond can readily accept two full equivalents of halogens.",
                keyPoint: "Triple bond can add two molecules of Br₂."
            ),
            ReactionStep(
                group: .alkyne,
                title: "Hydration",
                reactionType: "Addition",
                equation: "C₂H₂ + H₂O → CH₃CHO",
                explanation: "Water adds across the triple bond using an acid catalyst. The unstable intermediate quickly rearranges to form a stable ketone or aldehyde.",
                keyPoint: "Alkyne + Water → Aldehyde (Markovnikov addition)"
            ),
            ReactionStep(
                group: .alkyne,
                title: "Combustion",
                reactionType: "Oxidation",
                equation: "2C₂H₂ + 5O₂ → 4CO₂ + 2H₂O",
                explanation: "Acetylene burns in oxygen to produce an intensely hot flame exceeding 3,000°C. This heat output is used in metal welding torches.",
                keyPoint: "Acetylene flame reaches over 3,000°C!"
            )
        ]
    }
}
