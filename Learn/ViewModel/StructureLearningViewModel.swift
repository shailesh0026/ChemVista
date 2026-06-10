//
//  StructureLearningViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation

@Observable
class StructureLearningViewModel {
    var currentStepIndex: Int = 0
    var molecule: LearnMolecule = LearnMolecule()
    var instruction: String = ""
    var title: String = ""
    var tagText: String = "" 
    var formula: String = "" 
    var carbonCount: Int = 0
    var explanation: String = ""
    
    let group: HydrocarbonGroup
    private let progressManager = LearnProgressManager.shared
    
    var stepsCount: Int { steps.count }
    var progressText: String {
        "\(currentStepIndex + 1) of \(stepsCount)"
    }
    
    private var steps: [StructureStep] = []
    private let builder = LearnMoleculeBuilder()
    
    init(group: HydrocarbonGroup = .alkane) {
        self.group = group
        generateSteps()
        loadStep(index: 0)
    }
    
    private func generateSteps() {
        switch group {
        case .alkane:
            generateAlkaneSteps()
        case .alkene:
            generateAlkeneSteps()
        case .alkyne:
            generateAlkyneSteps()
        }
    }
    
    // 10 slides: Methane (1C) to Decane (10C)
    private func generateAlkaneSteps() {
        let alkanes = [
            ("Methane", 1,
             "The simplest alkane with one carbon atom.",
             "Methane (CH₄) has a tetrahedral shape. It's the main component of natural gas."),
            ("Ethane", 2,
             "Two carbon atoms connected by a single bond.",
             "Ethane is formed when two methyl groups join together."),
            ("Propane", 3,
             "Three carbon atoms in a chain.",
             "Propane is commonly used as fuel in heating and cooking."),
            ("Butane", 4,
             "Four carbon atoms. Isomers start here.",
             "Butane exists as n-butane (straight chain) and isobutane (branched)."),
            ("Pentane", 5,
             "A chain of five carbon atoms.",
             "Pentane has three possible structural isomers."),
            ("Hexane", 6,
             "A straight chain of six carbon atoms.",
             "Hexane is widely used as a laboratory solvent."),
            ("Heptane", 7,
             "Seven carbon atoms in its chain.",
             "Heptane is a reference fuel for octane rating systems."),
            ("Octane", 8,
             "Eight carbon atoms, key in fuel ratings.",
             "Octane rating measures a fuel's resistance to knocking."),
            ("Nonane", 9,
             "Nine carbon atoms connected in a row.",
             "Nonane is a component of gasoline."),
            ("Decane", 10,
             "Straight chain alkane with ten carbon atoms.",
             "Decane is used in studies of combustion chemistry.")
        ]
        
        self.steps = alkanes.map { (name, count, desc, expl) in
            StructureStep(
                group: .alkane,
                title: name,
                tag: "ALKANE",
                instruction: desc,
                explanation: expl,
                formula: "C\(count)H\(2*count + 2)",
                carbonCount: count,
                setup: { builder in
                    builder.buildAlkane(carbonCount: count)
                }
            )
        }
    }
    
    // 9 slides: Ethene (2C) to Decene (10C)
    private func generateAlkeneSteps() {
        let alkenes = [
            ("Ethene", 2,
             "The simplest alkene with one double bond.",
             "Ethene (ethylene) is used to ripen fruits and in making plastics."),
            ("Propene", 3,
             "Three carbons with a double bond.",
             "Propene (propylene) is a key material for making polypropylene."),
            ("But-1-ene", 4,
             "Four carbons with a double bond at position 1.",
             "Butene is used in the production of synthetic rubber."),
            ("Pent-1-ene", 5,
             "Five carbons with a double bond at position 1.",
             "Pentene is used as an intermediate in organic synthesis."),
            ("Hex-1-ene", 6,
             "Six carbons with a double bond at position 1.",
             "Hexene is a co-monomer used in polyethylene production."),
            ("Hept-1-ene", 7,
             "Seven carbons with a double bond at position 1.",
             "Heptene is used in organic chemistry as a building block."),
            ("Oct-1-ene", 8,
             "Eight carbons with a double bond at position 1.",
             "Octene is an important co-monomer in LLDPE production."),
            ("Non-1-ene", 9,
             "Nine carbons with a double bond at position 1.",
             "Nonene is used in surfactant and lubricant manufacturing."),
            ("Dec-1-ene", 10,
             "Ten carbons with a double bond at position 1.",
             "Decene is used to produce poly-alpha-olefins for lubricants.")
        ]
        
        self.steps = alkenes.map { (name, count, desc, expl) in
            StructureStep(
                group: .alkene,
                title: name,
                tag: "ALKENE",
                instruction: desc,
                explanation: expl,
                formula: "C\(count)H\(2*count)",
                carbonCount: count,
                setup: { builder in
                    builder.buildAlkene(carbonCount: count)
                }
            )
        }
    }
    
    // 9 slides: Ethyne (2C) to Decyne (10C)
    private func generateAlkyneSteps() {
        let alkynes = [
            ("Ethyne", 2,
             "The simplest alkyne — acetylene.",
             "Ethyne (acetylene) burns with a very hot flame, used in welding torches."),
            ("Propyne", 3,
             "Three carbons with a triple bond.",
             "Propyne is also called methylacetylene and is used as a fuel gas."),
            ("But-1-yne", 4,
             "Four carbons with a triple bond at position 1.",
             "Butyne has two isomers: but-1-yne and but-2-yne."),
            ("Pent-1-yne", 5,
             "Five carbons with a triple bond at position 1.",
             "Pentyne is used in organic synthesis reactions."),
            ("Hex-1-yne", 6,
             "Six carbons with a triple bond at position 1.",
             "Hexyne is a useful reagent in laboratory chemistry."),
            ("Hept-1-yne", 7,
             "Seven carbons with a triple bond at position 1.",
             "Heptyne is employed in pharmaceutical intermediates."),
            ("Oct-1-yne", 8,
             "Eight carbons with a triple bond at position 1.",
             "Octyne is used in specialty chemical synthesis."),
            ("Non-1-yne", 9,
             "Nine carbons with a triple bond at position 1.",
             "Nonyne serves as a building block in complex organic molecules."),
            ("Dec-1-yne", 10,
             "Ten carbons with a triple bond at position 1.",
             "Decyne is the largest simple straight-chain alkyne commonly studied.")
        ]
        
        self.steps = alkynes.map { (name, count, desc, expl) in
            StructureStep(
                group: .alkyne,
                title: name,
                tag: "ALKYNE",
                instruction: desc,
                explanation: expl,
                formula: "C\(count)H\(2*count - 2)",
                carbonCount: count,
                setup: { builder in
                    builder.buildAlkyne(carbonCount: count)
                }
            )
        }
    }
    
    func loadStep(index: Int) {
        guard index >= 0 && index < steps.count else { return }
        currentStepIndex = index
        let step = steps[index]
        title = step.title
        tagText = step.tag
        instruction = step.instruction
        explanation = step.explanation
        formula = step.formula
        carbonCount = step.carbonCount
        step.setup(builder)
        molecule = builder.molecule
        
        progressManager.saveStep(group: group, module: "structure", step: index, total: stepsCount)
    }
    
    func completeModule() {
        HapticManager.shared.notify(.success)
        progressManager.markCompleted(group: group, module: "structure")
    }
}
