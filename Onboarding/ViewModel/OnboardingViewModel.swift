//
//  OnboardingViewModel.swift
//  ChemVista
//
//  Created by Shailesh on 20/02/26.
//

import SwiftUI
import Observation

@Observable
class OnboardingViewModel {
    var currentPage = 0
    
    func nextPage() {
        withAnimation {
            currentPage += 1
        }
    }
    
    func finishOnboarding(hasSeenOnboarding: Binding<Bool>) {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasSeenOnboarding.wrappedValue = true
        }
    }
}
