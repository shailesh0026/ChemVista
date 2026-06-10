//
//  VisualizeView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import ARKit

// see the molecule update live in 3D, and can launch an AR view.
struct VisualizeView: View {
    @State private var viewModel = VisualizeViewModel()
    @State private var showARView = false
    @State private var showARUnavailableAlert = false
    @State private var showNoCarbonPopup = false
    @State private var showCameraPermissionAlert = false
    private let permissionManager = PermissionManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        headerCard
                        moleculeView
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Visualize")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Trash Button
                    Button {
                        withAnimation { viewModel.clear() }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .disabled(viewModel.molecule.atoms.isEmpty)
                    .accessibilityLabel("Clear molecule")
                    
                    // AR Button
                    Button {
                        if ARWorldTrackingConfiguration.isSupported {
                            let status = permissionManager.cameraStatus
                            if status == .authorized {
                                showARView = true
                            } else if status == .notDetermined {
                                permissionManager.requestCameraPermission { granted in
                                    if granted { showARView = true }
                                }
                            } else {
                                showCameraPermissionAlert = true
                            }
                        } else {
                            showARUnavailableAlert = true
                        }
                    } label: {
                        Image(systemName: "arkit")
                    }
                    .accessibilityLabel("View in AR")
                }
            }
            .fullScreenCover(isPresented: $showARView) {
                VisualizeARVisualizerSheet(viewModel: viewModel)
            }
            .alert("AR Not Available", isPresented: $showARUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("AR requires a device with a supported chip.")
            }
            .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
                Button("Settings") {
                    permissionManager.openSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Camera access is needed to use AR. Please enable it in Settings.")
            }
            .safeAreaInset(edge: .bottom) {
                bottomControls
            }
        }
    }
}

private extension VisualizeView {

    // Header
    
    var headerCard: some View {
        let moleculeLabel = viewModel.moleculeName.isEmpty ? "Start Building" : viewModel.moleculeName
        let missingLabel = viewModel.missingHydrogensText.map { " \($0)" } ?? ""
        let formulaLabel = viewModel.chemicalFormula == "-" ? "" : ", formula \(viewModel.chemicalFormula)"
        let combinedLabel = "\(moleculeLabel)\(missingLabel)\(formulaLabel)"

        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                HStack(spacing: 8) {
                    Text(viewModel.moleculeName.isEmpty ? "Start Building" : viewModel.moleculeName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .accessibilityHidden(true)

                    if let missing = viewModel.missingHydrogensText {
                        Text(missing)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                    }
                }
                Spacer()
                Text(viewModel.chemicalFormula)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .accessibilityHidden(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1)))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(combinedLabel)
    }

    // 3D View
    var moleculeView: some View {
        ZStack {
            VisualizeMolecule3DView(molecule: $viewModel.molecule, cameraDistance: 22)
                .frame(height: 400)
                //.clipped()
                .accessibilityLabel("3D molecule view")
                .accessibilityHint("Pinch to zoom, drag to rotate")
                .accessibilityAddTraits(.isImage)

            // Empty state hint
            if viewModel.molecule.atoms.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "atom")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.2))
                    Text("Add Carbon before Hydrogen \nto build your molecule")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.35))
                        .multilineTextAlignment(.center)
                }
                .offset(y: -40) // Moved slightly upward
            }
        }
        .padding(.vertical, 0)
    }

    // Bottom Controls
    var bottomControls: some View {
        VStack(spacing: 12) {
            // Bond type selector
            bondSelector
            
            // Atom controls
            HStack(spacing: 100) {
                AtomStepper(
                    symbol: "H",
                    color: .white,
                    textColor: .black,
                    onAdd: {
                        if viewModel.molecule.atoms.isEmpty {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                showNoCarbonPopup = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation { showNoCarbonPopup = false }
                            }
                        } else {
                            withAnimation { viewModel.addHydrogen() }
                        }
                    },
                    onRemove: { withAnimation { viewModel.removeHydrogen() } }
                )

                AtomStepper(
                    symbol: "C",
                    color: .cyan,
                    textColor: .white,
                    onAdd:    { withAnimation { viewModel.addCarbon() } },
                    onRemove: { withAnimation { viewModel.removeCarbon() } }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
    
    var bondSelector: some View {
        VisualizeBondSelectorView(viewModel: viewModel)
    }
}
