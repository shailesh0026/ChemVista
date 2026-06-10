//
//  PracticeViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation

@Observable
class PracticeViewModel {
    var levels: [PracticeLevel] = [
        PracticeLevel(
            id: 1,
            title: "Beginner Level",
            subtitle: "Name the displayed molecule",
            icon: "star.fill",
            color: Color(hue: 0.1, saturation: 0.8, brightness: 0.9),
            gradient: LinearGradient(colors: [Color(hue: 0.1, saturation: 0.8, brightness: 0.9), Color(hue: 0.05, saturation: 0.9, brightness: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            type: .beginner
        ),
        PracticeLevel(
            id: 2,
            title: "Intermediate Level",
            subtitle: "Construct a molecule from its name",
            icon: "star.leadinghalf.filled",
            color: Color(hue: 0.7, saturation: 0.8, brightness: 0.9),
            gradient: LinearGradient(colors: [Color(hue: 0.7, saturation: 0.8, brightness: 0.9), Color(hue: 0.65, saturation: 0.9, brightness: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            type: .intermediate
        ),
        PracticeLevel(
            id: 3,
            title: "Advanced Level",
            subtitle: "Identify errors in nomenclature",
            icon: "star",
            color: Color(hue: 0.8, saturation: 0.8, brightness: 0.9),
            gradient: LinearGradient(colors: [Color(hue: 0.8, saturation: 0.8, brightness: 0.9), Color(hue: 0.75, saturation: 0.9, brightness: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
            type: .advanced
        )
    ]
}
