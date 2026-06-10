//
//  NamingView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import ARKit

struct NamingView: View {
    let group: HydrocarbonGroup
    @State private var viewModel: NamingRulesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showARView = false
    @State private var showARUnavailableAlert = false
    @State private var showCameraPermissionAlert = false
    private let permissionManager = PermissionManager.shared

    init(group: HydrocarbonGroup = .alkane) {
        self.group = group
        _viewModel = State(wrappedValue: NamingRulesViewModel(group: group))
    }

    var body: some View {
        ZStack {
            BackgroundColor()
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(viewModel.progressText)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 24)
                        .accessibilityLabel("Step \(viewModel.progressText)")

                    Text(viewModel.currentSubtitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.top, 10)
                .animation(.easeInOut, value: viewModel.currentIndex)

                // This TabView is the core "Slideshow" element.
                // It swipes through 3D molecule views based on the current step
                TabView(selection: $viewModel.currentIndex) {
                    ForEach(viewModel.rules.indices, id: \.self) { index in
                        LearnMolecule3DView(molecule: $viewModel.currentMolecule)
                            .frame(height: 300)
                            .tag(index)
                            .accessibilityLabel("3D model of \(viewModel.currentSubtitle)")
                            .accessibilityAddTraits(.isImage)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 280)
                .onChange(of: viewModel.currentIndex) { _, newValue in
                    viewModel.loadRule(at: newValue)
                }

                VStack(spacing: 16) {
                    Text(viewModel.currentTitle)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentStatement)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .frame(minHeight: 48, alignment: .top)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("EXAMPLE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)

                        Text(viewModel.currentExample)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .accessibilityLabel("Example: \(viewModel.currentExample)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.bottom, 20)
                .padding(.bottom, 20)
                .padding(16)
                .animation(.easeInOut, value: viewModel.currentIndex)

                // Left & Right navigation arrows to move through the slideshow
                HStack {
                    Button {
                        withAnimation {
                            if viewModel.currentIndex > 0 {
                                viewModel.currentIndex -= 1
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.left.circle")
                            .font(.system(size: 56))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(NavigationArrowStyle())
                    .disabled(viewModel.currentIndex == 0)
                    .opacity(viewModel.currentIndex == 0 ? 0.3 : 1)
                    .accessibilityLabel("Previous step")
                    .accessibilityHint(viewModel.currentIndex > 0 ? "Go to step \(viewModel.currentIndex)" : "Already at first step")

                    Spacer()

                    Button {
                        withAnimation {
                            if viewModel.currentIndex < viewModel.rules.count - 1 {
                                viewModel.currentIndex += 1
                            } else {
                                viewModel.completeModule()
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.currentIndex == viewModel.rules.count - 1 ? "checkmark.circle" : "arrow.right.circle")
                            .font(.system(size: 56))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(NavigationArrowStyle())
                    .accessibilityLabel(viewModel.currentIndex == viewModel.rules.count - 1 ? "Complete module" : "Next step")
                    .accessibilityHint(viewModel.currentIndex == viewModel.rules.count - 1 ? "Finishes the module and returns to Learn" : "Go to step \(viewModel.currentIndex + 2)")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 90)
            }
        }
        .navigationTitle("\(group.displayName) Naming")
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
                molecule: $viewModel.currentMolecule,
                title: viewModel.currentSubtitle
            )
        }
        .alert("AR Not Available", isPresented: $showARUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("AR requires a device with an A12 chip or later.")
        }
        .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
            Button("Settings") {
                permissionManager.openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Camera access is needed to view molecules in AR. Please enable it in Settings.")
        }
    }
}

#Preview {
    NavigationStack {
        NamingView(group: .alkane)
    }
}
