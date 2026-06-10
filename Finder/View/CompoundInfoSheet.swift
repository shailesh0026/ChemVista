//
//  CompoundInfoSheet.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct CompoundInfoSheet: View {
    let details: CompoundDetails
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                ScrollView {
                    VStack(spacing: 24) {
                        InfoSection(title: "General Information") {
                            InfoRow(label: "IUPAC Name", value: details.iupacName)
                            if let common = details.commonName { InfoRow(label: "Common Name", value: common) }
                            InfoRow(label: "Formula", value: details.formula)
                            InfoRow(label: "Molar Mass", value: details.molarMass, showDivider: false)
                        }
                        InfoSection(title: "Structural Information") {
                            InfoRow(label: "Hybridization", value: details.hybridization)
                            InfoRow(label: "Geometry", value: details.geometry)
                            InfoRow(label: "Bond Angle", value: details.bondAngle, showDivider: false)
                        }
                        InfoSection(title: "Physical Properties") {
                            InfoRow(label: "State at STP", value: details.stateAtSTP)
                            InfoRow(label: "Melting Point", value: details.meltingPoint)
                            InfoRow(label: "Boiling Point", value: details.boilingPoint, showDivider: false)
                        }
                        InfoSection(title: "Short Description") {
                            Text(details.description)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding()
                    
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) { content }
                .background(.thinMaterial.opacity(0.5))
                .cornerRadius(12)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var showDivider: Bool = true
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label).font(.subheadline).foregroundColor(.gray).frame(width: 120, alignment: .leading)
            Text(value).font(.subheadline).foregroundColor(.white)
            Spacer()
        }
        .padding()
        .overlay(
            Group {
                if showDivider {
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 16)
                }
            },
            alignment: .bottom
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }
}
