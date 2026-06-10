//
//  PracticeView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct PracticeView: View {
    @State private var viewModel = PracticeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                    .edgesIgnoringSafeArea(.all)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.levels) { level in
                            PracticeCard(level: level)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    PracticeView()
        .preferredColorScheme(.dark)
}
