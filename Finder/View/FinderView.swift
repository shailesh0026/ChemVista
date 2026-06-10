//
//  FinderView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct FinderView: View {
    @State private var viewModel = FinderViewModel()
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    // LazyVGrid acts like a highly efficient collection view, only rendering
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredCompounds) { compound in
                            NavigationLink(destination: CompoundDetailView(compound: compound)) {
                                CompoundCard(compound: compound)
                            }
                            .buttonStyle(CardButtonStyle())
                            .accessibilityLabel("\(compound.name), \(compound.formula), \(compound.type)")
                            .accessibilityHint("View details")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Search")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search compounds"
            )
        }
    }
}

#Preview {
    FinderView()
        .preferredColorScheme(.dark)
}
