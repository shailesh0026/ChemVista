//
//  ReactionStep.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import Foundation

struct ReactionStep: Identifiable {
    let id = UUID()
    let group: HydrocarbonGroup
    let title: String
    let reactionType: String
    let equation: String
    let explanation: String
    let keyPoint: String
}
