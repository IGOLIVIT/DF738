import SwiftUI

struct ContentView: View {
    @StateObject private var rewardSystem = RewardSystem()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(rewardSystem)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}
