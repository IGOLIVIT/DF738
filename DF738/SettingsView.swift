import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // App info
                        appInfoSection
                        
                        // Stats summary
                        statsSummary
                        
                        // Actions
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    rewardSystem.resetProgress()
                }
            } message: {
                Text("Are you sure you want to reset all your progress? This action cannot be undone.")
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 15) {
            Text("🎮")
                .font(.system(size: 70))
            
            Text("Neon Arcade")
                .font(.title.bold())
                .foregroundColor(.white)
            
            Text("Version 1.0")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            LinearGradient(colors: [Color("ActionPrimary").opacity(0.2), Color("ElementAccent").opacity(0.2)],
                         startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
    }
    
    private var statsSummary: some View {
        VStack(spacing: 20) {
            Text("Your Progress")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 15) {
                ProgressRow(
                    icon: "💎",
                    label: "Total Gems Collected",
                    value: "\(rewardSystem.gems)"
                )
                
                ProgressRow(
                    icon: "⚡",
                    label: "Current Power Level",
                    value: "\(rewardSystem.powerLevel)"
                )
                
                ProgressRow(
                    icon: "🏆",
                    label: "Achievements Unlocked",
                    value: "\(rewardSystem.achievements.count)"
                )
                
                ProgressRow(
                    icon: "🎮",
                    label: "Total Games Played",
                    value: "\(rewardSystem.totalGamesPlayed)"
                )
                
                ProgressRow(
                    icon: "⏱️",
                    label: "Total Play Time",
                    value: "\(rewardSystem.totalPlayTimeMinutes) min"
                )
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(20)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 15) {
            Button(action: {
                showResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                    Text("Reset All Progress")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color.red.opacity(0.8))
                .cornerRadius(16)
            }
            
            Text("Warning: This will delete all your gems, achievements, and statistics permanently.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
}

struct ProgressRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.title2)
                
                Text(label)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(Color("ElementAccent"))
        }
    }
}



