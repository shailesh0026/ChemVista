//
//  StructureLearningView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//


import SwiftUI
import ARKit

struct StructureLearningView: View {
    let group: HydrocarbonGroup
    @State private var viewModel: StructureLearningViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showARView = false
    @State private var showARUnavailableAlert = false
    @State private var showCameraPermissionAlert = false
    private let permissionManager = PermissionManager.shared

    init(group: HydrocarbonGroup = .alkane) {
        self.group = group
        _viewModel = State(wrappedValue: StructureLearningViewModel(group: group))
    }

    var body: some View {
        ZStack {
            BackgroundColor()

            VStack(spacing: 0) {
                Text(viewModel.progressText)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 24)
                    .accessibilityLabel("Step \(viewModel.progressText)")

                Text(viewModel.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                ZStack {
                    LearnMolecule3DView(molecule: $viewModel.molecule, cameraDistance: 20)
                        .frame(height: 350)
                        .accessibilityLabel("3D model of \(viewModel.title)")
                        .accessibilityAddTraits(.isImage)
                }
                
                Spacer()

                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Formula")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)
                        Text(viewModel.formula)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .accessibilityLabel("Chemical formula: \(viewModel.formula)")
                    }
                    .padding(.top, 10)
                    
                    // Explanation text
                    if !viewModel.explanation.isEmpty {
                        Text(viewModel.explanation)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .frame(minHeight: 48, alignment: .top)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack {
                        // "Previous Slide" button
                        Button {
                            withAnimation {
                                if viewModel.currentStepIndex > 0 {
                                    viewModel.currentStepIndex -= 1
                                    viewModel.loadStep(index: viewModel.currentStepIndex)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.left.circle")
                                .font(.system(size: 56))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(NavigationArrowStyle())
                        .disabled(viewModel.currentStepIndex == 0)
                        .opacity(viewModel.currentStepIndex == 0 ? 0.3 : 1)
                        .accessibilityLabel("Previous step")
                        .accessibilityHint(viewModel.currentStepIndex > 0 ? "Go to step \(viewModel.currentStepIndex)" : "Already at first step")

                        Spacer()

                        // "Next Slide" or "Finish" button
                        Button {
                            withAnimation {
                                if viewModel.currentStepIndex < viewModel.stepsCount - 1 {
                                    viewModel.currentStepIndex += 1
                                    viewModel.loadStep(index: viewModel.currentStepIndex)
                                } else {
                                    viewModel.completeModule()
                                    dismiss()
                                }
                            }
                        } label: {
                            Image(systemName: viewModel.currentStepIndex == viewModel.stepsCount - 1 ? "checkmark.circle" : "arrow.right.circle")
                                .font(.system(size: 56))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(NavigationArrowStyle())
                        .accessibilityLabel(viewModel.currentStepIndex == viewModel.stepsCount - 1 ? "Complete module" : "Next step")
                        .accessibilityHint(viewModel.currentStepIndex == viewModel.stepsCount - 1 ? "Finishes the module and returns to Learn" : "Go to step \(viewModel.currentStepIndex + 2)")
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("\(group.displayName) Structures")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(ToolbarIconStyle())
                .accessibilityLabel("View in AR")
                .accessibilityHint("Opens augmented reality view of the current molecule")
            }
        }
        .fullScreenCover(isPresented: $showARView) {
            LearnARViewOnlySheet(
                molecule: $viewModel.molecule,
                title: viewModel.title
            )
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
    }
}

#Preview {
    NavigationStack {
        StructureLearningView(group: .alkane)
            .preferredColorScheme(.dark)
    }
}
