//
//  StructureStep.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

struct StructureStep {
    let group: HydrocarbonGroup
    let title: String
    let tag: String
    let instruction: String
    let explanation: String
    let formula: String
    let carbonCount: Int
    let setup: (LearnMoleculeBuilder) -> Void
}
