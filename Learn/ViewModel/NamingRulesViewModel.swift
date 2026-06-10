//
//  NamingRulesViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation

@Observable
class NamingRulesViewModel {
    var rules: [NamingRule] = []
    var currentIndex: Int = 0
    var currentMolecule: LearnMolecule = LearnMolecule()
    
    // UI Helpers
    var currentTitle: String = ""
    var currentSubtitle: String = ""
    var currentStatement: String = ""
    var currentExplanation: String = ""
    var currentExample: String = ""
    
    let group: HydrocarbonGroup
    private let progressManager = LearnProgressManager.shared
    
    var progressText: String {
        "\(currentIndex + 1) of \(rules.count)"
    }
    
    private let builder = LearnMoleculeBuilder()
    
    init(group: HydrocarbonGroup = .alkane) {
        self.group = group
        setupRules()
        loadRule(at: 0)
    }
    
    func loadRule(at index: Int) {
        guard index >= 0 && index < rules.count else { return }
        currentIndex = index
        let rule = rules[index]
        
        currentTitle = rule.title
        currentSubtitle = rule.subtitle
        currentStatement = rule.ruleStatement
        currentExplanation = rule.explanation
        currentExample = rule.exampleText
        
        rule.setup(builder)
        currentMolecule = builder.molecule
        
        // Save progress.
        progressManager.saveStep(group: group, module: "naming", step: index, total: rules.count)
    }
    
    func completeModule() {
        HapticManager.shared.notify(.success)
        progressManager.markCompleted(group: group, module: "naming")
    }
    
    // MARK: - Rule Data
    
    private func setupRules() {
        switch group {
        case .alkane:
            setupAlkaneRules()
        case .alkene:
            setupAlkeneRules()
        case .alkyne:
            setupAlkyneRules()
        }
    }
    
    // MARK: - Alkane Rules
    
    private func setupAlkaneRules() {
        rules = [
            NamingRule(
                group: .alkane,
                title: "What are Alkanes?",
                subtitle: "The Basics",
                ruleStatement: "Alkanes are hydrocarbons with only single bonds.",
                explanation: "They follow the general formula CₙH₂ₙ₊₂. They are also called saturated hydrocarbons.",
                exampleText: "CH₄ (Methane), C₂H₆ (Ethane)",
                setup: { builder in
                    builder.buildAlkane(carbonCount: 1)
                }
            ),
            NamingRule(
                group: .alkane,
                title: "1. Longest Chain",
                subtitle: "The Foundation",
                ruleStatement: "Choose the longest carbon chain.",
                explanation: "The parent chain determines the root name. It must contain the maximum number of carbon atoms.",
                exampleText: "4 Carbons = 'Butane'",
                setup: { builder in
                    builder.clear()
                    
                    let c1 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-4.5, 0, 0))
                    let c2 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 0, 0))
                    let c3 = builder.addAtom(element: .carbon, position: SIMD3<Float>(1.5, 0, 0))
                    let c4 = builder.addAtom(element: .carbon, position: SIMD3<Float>(4.5, 0, 0))
                    let cBranch = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 3.0, 0))
                    
                    _ = builder.addBond(from: c1, to: c2)
                    _ = builder.addBond(from: c2, to: c3)
                    _ = builder.addBond(from: c3, to: c4)
                    _ = builder.addBond(from: c2, to: cBranch)
                    
                    builder.fillHydrogens()
                    builder.molecule.highlightedAtoms = [c1.id, c2.id, c3.id, c4.id]
                }
            ),
            NamingRule(
                group: .alkane,
                title: "2. Numbering",
                subtitle: "Lowest Locants",
                ruleStatement: "Number for the lowest locants.",
                explanation: "We want the substituent branches to have the lowest possible numbers.",
                exampleText: "Start left: 2-methyl (Correct)\n Start right: 3-methyl (Wrong)",
                setup: { builder in
                    builder.clear()
                    let c1 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-4.5, 0, 0))
                    let c2 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 0, 0))
                    let c3 = builder.addAtom(element: .carbon, position: SIMD3<Float>(1.5, 0, 0))
                    let c4 = builder.addAtom(element: .carbon, position: SIMD3<Float>(4.5, 0, 0))
                    let cBranch = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 3.0, 0))
                    
                    _ = builder.addBond(from: c1, to: c2)
                    _ = builder.addBond(from: c2, to: c3)
                    _ = builder.addBond(from: c3, to: c4)
                    _ = builder.addBond(from: c2, to: cBranch)
                    
                    builder.fillHydrogens()
                    builder.molecule.highlightedAtoms = [c2.id]
                }
            ),
            NamingRule(
                group: .alkane,
                title: "3. Substituents",
                subtitle: "Identify Groups",
                ruleStatement: "Identify groups attached to the main chain.",
                explanation: "Common branches include Methyl (-CH₃) and Ethyl (-C₂H₅).",
                exampleText: "Found: Methyl Group",
                setup: { builder in
                    builder.clear()
                    let c1 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-4.5, 0, 0))
                    let c2 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 0, 0))
                    let c3 = builder.addAtom(element: .carbon, position: SIMD3<Float>(1.5, 0, 0))
                    let c4 = builder.addAtom(element: .carbon, position: SIMD3<Float>(4.5, 0, 0))
                    let cBranch = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 3.0, 0))
                    
                    _ = builder.addBond(from: c1, to: c2)
                    _ = builder.addBond(from: c2, to: c3)
                    _ = builder.addBond(from: c3, to: c4)
                    _ = builder.addBond(from: c2, to: cBranch)
                    
                    builder.fillHydrogens()
                    builder.molecule.highlightedAtoms = [cBranch.id]
                }
            ),
            NamingRule(
                group: .alkane,
                title: "4. Alphabetical Order",
                subtitle: "Sort Substituents",
                ruleStatement: "List substituents alphabetically.",
                explanation: "Ethyl comes before Methyl.",
                exampleText: "3-ethyl-2-methyl...",
                setup: { builder in
                    builder.clear()
                    
                    let c1 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-6.0, 0, 0))
                    let c2 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-3.0, 0, 0))
                    let c3 = builder.addAtom(element: .carbon, position: SIMD3<Float>(0.0, 0, 0))
                    let c4 = builder.addAtom(element: .carbon, position: SIMD3<Float>(3.0, 0, 0))
                    let c5 = builder.addAtom(element: .carbon, position: SIMD3<Float>(6.0, 0, 0))
                    
                    _ = builder.addBond(from: c1, to: c2)
                    _ = builder.addBond(from: c2, to: c3)
                    _ = builder.addBond(from: c3, to: c4)
                    _ = builder.addBond(from: c4, to: c5)
                    
                    let cMe = builder.addAtom(element: .carbon, position: SIMD3<Float>(-3.0, 3.0, 0))
                    _ = builder.addBond(from: c2, to: cMe)
                    
                    let cEt1 = builder.addAtom(element: .carbon, position: SIMD3<Float>(0.0, -3.0, 0))
                    let cEt2 = builder.addAtom(element: .carbon, position: SIMD3<Float>(0.0, -6.0, 0))
                    _ = builder.addBond(from: c3, to: cEt1)
                    _ = builder.addBond(from: cEt1, to: cEt2)
                    
                    builder.fillHydrogens()
                    builder.molecule.highlightedAtoms = [cEt1.id, cEt2.id]
                }
            ),
            NamingRule(
                group: .alkane,
                title: "5. Identical Groups",
                subtitle: "Use Prefixes",
                ruleStatement: "Use di-, tri-, tetra- for repeats.",
                explanation: "Don't repeat the name — group identical substituents together.",
                exampleText: "2,3-dimethylbutane",
                setup: { builder in
                    builder.clear()
                    let c1 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-4.5, 0, 0))
                    let c2 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 0, 0))
                    let c3 = builder.addAtom(element: .carbon, position: SIMD3<Float>(1.5, 0, 0))
                    let c4 = builder.addAtom(element: .carbon, position: SIMD3<Float>(4.5, 0, 0))
                    
                    let c2Me = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 3.0, 0))
                    let c3Me = builder.addAtom(element: .carbon, position: SIMD3<Float>(1.5, -3.0, 0))
                    
                    _ = builder.addBond(from: c1, to: c2)
                    _ = builder.addBond(from: c2, to: c3)
                    _ = builder.addBond(from: c3, to: c4)
                    _ = builder.addBond(from: c2, to: c2Me)
                    _ = builder.addBond(from: c3, to: c3Me)
                    
                    builder.fillHydrogens()
                    builder.molecule.highlightedAtoms = [c2Me.id, c3Me.id]
                }
            ),
            NamingRule(
                group: .alkane,
                title: "6. Assembly",
                subtitle: "Put it Together",
                ruleStatement: "Combine locant + prefix + root + suffix.",
                explanation: "Order: Substituents → Parent Chain Length → Bond Type",
                exampleText: "2-methyl + but + ane = 2-methylbutane",
                setup: { builder in
                    builder.clear()
                    let c1 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-4.5, 0, 0))
                    let c2 = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 0, 0))
                    let c3 = builder.addAtom(element: .carbon, position: SIMD3<Float>(1.5, 0, 0))
                    let c4 = builder.addAtom(element: .carbon, position: SIMD3<Float>(4.5, 0, 0))
                    let cBranch = builder.addAtom(element: .carbon, position: SIMD3<Float>(-1.5, 3.0, 0))
                    
                    _ = builder.addBond(from: c1, to: c2)
                    _ = builder.addBond(from: c2, to: c3)
                    _ = builder.addBond(from: c3, to: c4)
                    _ = builder.addBond(from: c2, to: cBranch)
                    
                    builder.fillHydrogens()
                    builder.molecule.highlightedAtoms = Set(builder.molecule.atoms.map { $0.id })
                }
            )
        ]
    }
    
    // MARK: - Alkene Rules
    
    private func setupAlkeneRules() {
        rules = [
            NamingRule(
                group: .alkene,
                title: "What are Alkenes?",
                subtitle: "The Basics",
                ruleStatement: "Alkenes contain at least one C=C double bond.",
                explanation: "They follow the general formula CₙH₂ₙ. They are unsaturated hydrocarbons — they can add more atoms.",
                exampleText: "C₂H₄ (Ethene), C₃H₆ (Propene)",
                setup: { builder in
                    builder.buildAlkene(carbonCount: 2)
                }
            ),
            NamingRule(
                group: .alkene,
                title: "1. Identify the Double Bond",
                subtitle: "Find C=C",
                ruleStatement: "Locate the carbon-carbon double bond.",
                explanation: "The double bond is where two carbon atoms share two pairs of electrons. It's shorter and stronger than a single bond.",
                exampleText: "C=C in Ethene",
                setup: { builder in
                    builder.buildAlkene(carbonCount: 2)
                    let carbons = builder.molecule.atoms.filter { $0.element == .carbon }
                    builder.molecule.highlightedAtoms = Set(carbons.map { $0.id })
                }
            ),
            NamingRule(
                group: .alkene,
                title: "2. Longest Chain with C=C",
                subtitle: "Parent Chain",
                ruleStatement: "The parent chain must include the double bond.",
                explanation: "Even if a longer chain exists, the parent chain is chosen to include the C=C double bond.",
                exampleText: "Propene: 3-carbon chain with C=C",
                setup: { builder in
                    builder.buildAlkene(carbonCount: 3)
                    let carbons = builder.molecule.atoms.filter { $0.element == .carbon }
                    builder.molecule.highlightedAtoms = Set(carbons.map { $0.id })
                }
            ),
            NamingRule(
                group: .alkene,
                title: "3. Number from C=C End",
                subtitle: "Lowest Locant for C=C",
                ruleStatement: "Number so the double bond gets the lowest number.",
                explanation: "Start numbering from the end closest to the double bond. The position of C=C is given before the suffix.",
                exampleText: "But-1-ene (not But-3-ene)",
                setup: { builder in
                    builder.buildAlkene(carbonCount: 4)
                    let carbons = builder.molecule.atoms.filter { $0.element == .carbon }
                    if carbons.count >= 2 {
                        builder.molecule.highlightedAtoms = [carbons[0].id, carbons[1].id]
                    }
                }
            ),
            NamingRule(
                group: .alkene,
                title: "4. Suffix: -ene",
                subtitle: "Naming Suffix",
                ruleStatement: "Replace -ane with -ene.",
                explanation: "The suffix '-ene' tells us there is a double bond. The position number goes before it.",
                exampleText: "Butane → But-1-ene",
                setup: { builder in
                    builder.buildAlkene(carbonCount: 4)
                }
            ),
            NamingRule(
                group: .alkene,
                title: "5. Example: Pent-1-ene",
                subtitle: "Putting It Together",
                ruleStatement: "5 carbons + double bond at position 1.",
                explanation: "Pent- (5 carbons) + 1 (double bond position) + -ene (double bond) = Pent-1-ene.",
                exampleText: "Pent-1-ene (C₅H₁₀)",
                setup: { builder in
                    builder.buildAlkene(carbonCount: 5)
                }
            ),
            NamingRule(
                group: .alkene,
                title: "6. Example: Hex-1-ene",
                subtitle: "Larger Alkene",
                ruleStatement: "6 carbons + double bond at position 1.",
                explanation: "As the chain grows, the naming pattern stays the same. Just change the root name.",
                exampleText: "Hex-1-ene (C₆H₁₂)",
                setup: { builder in
                    builder.buildAlkene(carbonCount: 6)
                }
            )
        ]
    }
    
    // MARK: - Alkyne Rules
    
    private func setupAlkyneRules() {
        rules = [
            NamingRule(
                group: .alkyne,
                title: "What are Alkynes?",
                subtitle: "The Basics",
                ruleStatement: "Alkynes contain at least one C≡C triple bond.",
                explanation: "They follow the general formula CₙH₂ₙ₋₂. The triple bond makes them even more unsaturated than alkenes.",
                exampleText: "C₂H₂ (Ethyne), C₃H₄ (Propyne)",
                setup: { builder in
                    builder.buildAlkyne(carbonCount: 2)
                }
            ),
            NamingRule(
                group: .alkyne,
                title: "1. Identify the Triple Bond",
                subtitle: "Find C≡C",
                ruleStatement: "Locate the carbon-carbon triple bond.",
                explanation: "Three pairs of electrons are shared. The bond is very strong and linear (180° angle).",
                exampleText: "C≡C in Ethyne (Acetylene)",
                setup: { builder in
                    builder.buildAlkyne(carbonCount: 2)
                    let carbons = builder.molecule.atoms.filter { $0.element == .carbon }
                    builder.molecule.highlightedAtoms = Set(carbons.map { $0.id })
                }
            ),
            NamingRule(
                group: .alkyne,
                title: "2. Longest Chain with C≡C",
                subtitle: "Parent Chain",
                ruleStatement: "The parent chain must include the triple bond.",
                explanation: "Choose the longest carbon chain that contains the C≡C triple bond.",
                exampleText: "Propyne: 3-carbon chain with C≡C",
                setup: { builder in
                    builder.buildAlkyne(carbonCount: 3)
                    let carbons = builder.molecule.atoms.filter { $0.element == .carbon }
                    builder.molecule.highlightedAtoms = Set(carbons.map { $0.id })
                }
            ),
            NamingRule(
                group: .alkyne,
                title: "3. Number from C≡C End",
                subtitle: "Lowest Locant for C≡C",
                ruleStatement: "Number so the triple bond gets the lowest number.",
                explanation: "Start numbering from the end closest to the triple bond.",
                exampleText: "But-1-yne (not But-3-yne)",
                setup: { builder in
                    builder.buildAlkyne(carbonCount: 4)
                    let carbons = builder.molecule.atoms.filter { $0.element == .carbon }
                    if carbons.count >= 2 {
                        builder.molecule.highlightedAtoms = [carbons[0].id, carbons[1].id]
                    }
                }
            ),
            NamingRule(
                group: .alkyne,
                title: "4. Suffix: -yne",
                subtitle: "Naming Suffix",
                ruleStatement: "Replace -ane with -yne.",
                explanation: "The suffix '-yne' indicates a triple bond. The position number goes before it.",
                exampleText: "Butane → But-1-yne",
                setup: { builder in
                    builder.buildAlkyne(carbonCount: 4)
                }
            ),
            NamingRule(
                group: .alkyne,
                title: "5. Example: Pent-1-yne",
                subtitle: "Putting It Together",
                ruleStatement: "5 carbons + triple bond at position 1.",
                explanation: "Pent- (5 carbons) + 1 (triple bond position) + -yne (triple bond) = Pent-1-yne.",
                exampleText: "Pent-1-yne (C₅H₈)",
                setup: { builder in
                    builder.buildAlkyne(carbonCount: 5)
                }
            ),
            NamingRule(
                group: .alkyne,
                title: "6. Example: Hex-1-yne",
                subtitle: "Larger Alkyne",
                ruleStatement: "6 carbons + triple bond at position 1.",
                explanation: "As the chain grows, the naming pattern stays the same. Just change the root name.",
                exampleText: "Hex-1-yne (C₆H₁₀)",
                setup: { builder in
                    builder.buildAlkyne(carbonCount: 6)
                }
            )
        ]
    }
}
