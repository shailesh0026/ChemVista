//
//  FinderViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation

@Observable
class FinderViewModel {
    var searchText = ""
    
    var filteredCompounds: [CompoundPreset] {
        if searchText.isEmpty {
            return CompoundLibrary.all
        } else {
            return CompoundLibrary.all.filter { compound in
                compound.name.localizedCaseInsensitiveContains(searchText) ||
                compound.formula.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
