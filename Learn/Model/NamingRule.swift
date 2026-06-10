//
//  NamingRule.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation
import SwiftUI

struct NamingRule: Identifiable {
    let id = UUID()
    let group: HydrocarbonGroup
    let title: String
    let subtitle: String
    let ruleStatement: String
    let explanation: String
    let exampleText: String
    let setup: (LearnMoleculeBuilder) -> Void
}
