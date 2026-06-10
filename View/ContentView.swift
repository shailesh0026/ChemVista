//
//  ContentView.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI

// Root view. Manages the app launch flow: Splash -> Onboarding (if first time) -> Home
struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showSplash: Bool = true
    @State private var selectedTab: Int = 1

    init() {
        // Style the tab bar to match the app's dark background.
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 3/255, green: 2/255, blue: 8/255, alpha: 1)
        appearance.shadowColor = nil

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .trailing)))
            } else {
                TabView(selection: $selectedTab) {
                    LearnView()
                        .tabItem { Label("Learn", systemImage: "book.fill") }
                        .tag(1)

                    VisualizeView()
                        .tabItem { Label("Visualize", systemImage: "eye.fill") }
                        .tag(2)

                    PracticeView()
                        .tabItem { Label("Practice", systemImage: "flask.fill") }
                        .tag(3)

                    FinderView()
                        .tabItem { Label("Search", systemImage: "magnifyingglass") }
                        .tag(4)
                }
                .accentColor(.white)
                .preferredColorScheme(.dark)
                .transition(.opacity)
            }
        }
        .onAppear {
            // Splash screen timing: Short and well-balanced (1.5 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
