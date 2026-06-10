//
//  PracticeLevel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct PracticeLevel: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let gradient: LinearGradient
    let type: QuizType
}
