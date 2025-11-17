//
//  ContentView.swift
//  DF738
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var isOnboardingComplete = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        ZStack {
            if isOnboardingComplete {
                HomeView()
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
    }
}

#Preview {
    ContentView()
}
