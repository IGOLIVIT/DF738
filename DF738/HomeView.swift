import SwiftUI

struct HomeView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        headerView
                        
                        // Rewards summary
                        rewardsSummary
                        
                        // Games grid
                        gamesGrid
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Neon Arcade")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("🎮")
                .font(.system(size: 60))
            
            Text("Choose Your Game")
                .font(.title.bold())
                .foregroundColor(.white)
        }
        .padding(.top, 20)
    }
    
    private var rewardsSummary: some View {
        HStack(spacing: 15) {
            RewardBadge(icon: "💎", value: "\(rewardSystem.gems)", label: "Gems")
            RewardBadge(icon: "⚡", value: "\(rewardSystem.powerLevel)", label: "Level")
            RewardBadge(icon: "🏆", value: "\(rewardSystem.achievements.count)", label: "Achievements")
        }
        .padding()
        .background(Color("BackgroundSecondary"))
        .cornerRadius(20)
    }
    
    private var gamesGrid: some View {
        VStack(spacing: 20) {
            GameCard(
                icon: "🌈",
                title: "Color Cascade",
                description: "Test your reflexes - tap matching colors!",
                gradient: [Color("ActionPrimary"), Color("ElementAccent")],
                destination: ColorCascadeView()
            )
            
            GameCard(
                icon: "🌀",
                title: "Orbit Master",
                description: "Control the orbit - collect stars!",
                gradient: [.purple, .pink],
                destination: OrbitMasterView()
            )
            
            GameCard(
                icon: "🏗️",
                title: "Stack Tower",
                description: "Perfect timing - build the highest tower!",
                gradient: [.orange, .red],
                destination: StackTowerView()
            )
            
            GameCard(
                icon: "🎵",
                title: "Pulse Rhythm",
                description: "Hit the beat - match the rhythm!",
                gradient: [.cyan, .blue],
                destination: PulseRhythmView()
            )
        }
    }
}

struct RewardBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color("BackgroundPrimary").opacity(0.5))
        .cornerRadius(12)
    }
}

struct GameCard<Destination: View>: View {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 20) {
                Text(icon)
                    .font(.system(size: 50))
                    .frame(width: 70, height: 70)
                    .background(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            .opacity(0.3)
                    )
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .opacity(0.2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
            )
            .cornerRadius(20)
        }
    }
}


