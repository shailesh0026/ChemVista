//
//  CompoundDetailView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//


import SwiftUI
import ARKit

struct CompoundDetailView: View {
    let compound: CompoundPreset
    @State private var molecule: FinderMolecule
    @State private var showDetails = false
    @State private var showARView = false
    @State private var showARUnavailableAlert = false

    init(compound: CompoundPreset) {
        self.compound = compound
        _molecule = State(initialValue: compound.molecule)
    }

    var body: some View {
        ZStack {
            BackgroundColor()

            VStack {
                VStack(spacing: 8) {
                    Text(compound.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)

                    Text(compound.formula)
                        .font(.title3.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .accessibilityLabel("Formula: \(compound.formula)")

                    Text(compound.type)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Type: \(compound.type)")
                }
                .padding(.top, 20)

                FinderMolecule3DView(molecule: $molecule, cameraDistance: 20)
                    .frame(height: 350)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.thinMaterial.opacity(0.5))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    )
                    .padding()
                    .accessibilityLabel("3D model of \(compound.name)")
                    .accessibilityAddTraits(.isImage)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Overview")
                            .font(.headline)
                            .foregroundColor(.white)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        if compound.details != nil {
                            Button { showDetails = true } label: {
                                Text("Details")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(24)
                            }
                            .buttonStyle(AppButtonStyle())
                            .accessibilityLabel("View detailed information about \(compound.name)")
                        }
                    }

                    Text(compound.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial.opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if ARWorldTrackingConfiguration.isSupported {
                        showARView = true
                    } else {
                        showARUnavailableAlert = true
                    }
                } label: {
                    Image(systemName: "arkit")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(ToolbarIconStyle())
                .accessibilityLabel("View in AR")
                .accessibilityHint("Opens augmented reality view of \(compound.name)")
            }
        }
        .fullScreenCover(isPresented: $showARView) {
            FinderARViewOnlySheet(molecule: $molecule, title: compound.name)
        }
        .alert("AR Not Available", isPresented: $showARUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("AR requires a device with a supported chip.")
        }
        .sheet(isPresented: $showDetails) {
            if let details = compound.details {
                CompoundInfoSheet(details: details)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CompoundDetailView(compound: CompoundLibrary.all[0])
    }
    .preferredColorScheme(.dark)
}
