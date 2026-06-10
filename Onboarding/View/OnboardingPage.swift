//
//  OnboardingPage.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

// A reusable layout for the 3 interactive onboarding slides (Pages 1-3).
struct OnboardingPage: View {
    let title: String
    let description: String
    let content: AnyView
    let buttonText: String
    var buttonHint: String = ""
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 100)
            
            // Text content at the top
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
                
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 40)
            }
            .padding(.top, 30)
            
            Spacer()
            
            // Symbol in the middle
            content
                .frame(height: 150)
                .padding(.bottom, 130)
            
            Spacer()
            
            // The "Call to Action" button at the bottom
            Button(action: action) {
                Text(buttonText)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(34)
            }
            .accessibilityLabel(buttonText)
            .accessibilityHint(buttonHint)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// This view references the logo file in your Assets catalog.
struct LogoView: View {
    var body: some View {
        Image("ChemVistaLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
