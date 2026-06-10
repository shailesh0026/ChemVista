//
//  OnboardingView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            BackgroundColor()
                .ignoresSafeArea()
            
            TabView(selection: $viewModel.currentPage) {
                // Page 0: Master the Logic
                OnboardingPage(
                    title: "Master the Logic",
                    description: "Learn IUPAC nomenclature step-by-step using logic instead of memorization.",
                    content: AnyView(Image(systemName: "book.fill").font(.system(size: 150)).foregroundColor(.white).offset(y: 10)
                        .accessibilityHidden(true)),
                    buttonText: "Next",
                    buttonHint: "Advances to the next page",
                    action: { viewModel.nextPage() }
                )
                .tag(0)
                
                // Page 1: Experience in 3D
                OnboardingPage(
                    title: "Experience in 3D",
                    description: "Create molecules in SceneKit and explore them in real world AR.",
                    content: AnyView(Image(systemName: "eye.fill").font(.system(size: 150)).foregroundColor(.white).offset(y: 10)
                        .accessibilityHidden(true)),
                    buttonText: "Next",
                    buttonHint: "Advances to the next page",
                    action: { viewModel.nextPage() }
                )
                .tag(1)
                
                // Page 2: Refine Your Skills
                OnboardingPage(
                    title: "Refine Your Skills",
                    description: "Practice with interactive exercises that check your accuracy.",
                    content: AnyView(Image(systemName: "flask.fill").font(.system(size: 150)).foregroundColor(.white).offset(y: 10)
                        .accessibilityHidden(true)),
                    buttonText: "Continue",
                    buttonHint: "Opens the app",
                    action: { viewModel.finishOnboarding(hasSeenOnboarding: $hasSeenOnboarding) }
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom "Expanding Pill" carousel indicator
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        let isActive = (viewModel.currentPage == index)
                        Capsule()
                            .fill(isActive ? Color.white : Color.white.opacity(0.3))
                            .frame(width: isActive ? 24 : 8, height: 8)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.currentPage)
                .padding(.bottom, 120)
                .accessibilityHidden(true)
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
