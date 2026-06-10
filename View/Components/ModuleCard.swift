//
//  ModuleCard.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

struct ModuleCard: View {
    let tag: String
    let color: Color
    let title: String
    let description: String
    let icon: AnyView
    let actionText: String?
    var destination: AnyView? = nil
    var isLocked: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(tag)
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .accessibilityAddTraits(.isHeader)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(isLocked ? .white.opacity(0.5) : .white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(isLocked ? .white.opacity(0.3) : .gray)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 10)
            
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                    icon.foregroundColor(isLocked ? .gray : .white)
                }
                .accessibilityHidden(true) // decorative icon
                
                Spacer()
                
                if let actionText {
                    if let destination {
                        NavigationLink(destination: destination) {
                            ActionButtonContent(text: actionText, color: color)
                        }
                        .buttonStyle(AppButtonStyle())
                        .accessibilityLabel("\(actionText) \(title)")
                        .accessibilityHint("Opens the \(title) learning module")
                    } else {
                        Button(action: {}) {
                            ActionButtonContent(text: actionText, color: color)
                        }
                        .buttonStyle(AppButtonStyle())
                        .disabled(true)
                        .accessibilityLabel("\(title), coming soon")
                        .accessibilityHint("This module is not yet available")
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// The liquid-glass "Start" pill button used inside ModuleCard.
struct ActionButtonContent: View {
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text).fontWeight(.bold)
            Image(systemName: "arrow.right").fontWeight(.bold)
                .accessibilityHidden(true)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}
