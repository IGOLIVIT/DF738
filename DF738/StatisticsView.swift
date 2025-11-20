//
//  StatisticsView.swift
//  DF738
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var rewardSystem = RewardSystem.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 12) {
                            Text("📊")
                                .font(.system(size: 50))
                            Text("Game Statistics")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("ElementAccent"))
                        }
                        .padding(.top, 20)
                        
                        // Overall Stats
                        VStack(spacing: 15) {
                            Text("Overall Progress")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("ElementAccent"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                OverallStatRow(icon: "🌟", label: "Total Stars", value: "\(rewardSystem.stars)")
                                OverallStatRow(icon: "🏆", label: "Total Trophies", value: "\(rewardSystem.trophies)")
                                OverallStatRow(icon: "💫", label: "Cosmos Points", value: "\(rewardSystem.cosmosPoints)")
                                OverallStatRow(icon: "🎮", label: "Total Sessions", value: "\(rewardSystem.totalSessions)")
                                OverallStatRow(icon: "⏱️", label: "Play Time", value: "\(rewardSystem.totalPlayTimeMinutes) min")
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Divider()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        
                        // Game-specific stats
                        VStack(spacing: 20) {
                            Text("Game Details")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("ElementAccent"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            GameStatCard(
                                icon: "☄️",
                                title: "Asteroid Dash",
                                stats: rewardSystem.asteroidDashStats
                            )
                            
                            GameStatCard(
                                icon: "💎",
                                title: "Cosmic Crystal Collector",
                                stats: rewardSystem.crystalCollectorStats
                            )
                            
                            GameStatCard(
                                icon: "🛸",
                                title: "Space Runner",
                                stats: rewardSystem.spaceRunnerStats
                            )
                            
                            GameStatCard(
                                icon: "🌟",
                                title: "Cosmic Pattern",
                                stats: rewardSystem.cosmicPatternStats
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
        }
    }
}

struct OverallStatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(Color("ElementAccent"))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("ActionPrimary"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(12)
    }
}

struct GameStatCard: View {
    let icon: String
    let title: String
    let stats: GameStats
    
    var body: some View {
        VStack(spacing: 15) {
            // Header
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 36))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("ElementAccent"))
                Spacer()
            }
            
            // Stats Grid
            VStack(spacing: 10) {
                GameStatDetailRow(label: "Games Played", value: "\(stats.gamesPlayed)")
                GameStatDetailRow(label: "High Score", value: "\(stats.highScore)")
                GameStatDetailRow(label: "Total Score", value: "\(stats.totalScore)")
                GameStatDetailRow(label: "Average Score", value: String(format: "%.1f", stats.averageScore))
                GameStatDetailRow(label: "Play Time", value: "\(stats.totalPlayTimeMinutes) min")
                
                if let lastPlayed = stats.lastPlayed {
                    GameStatDetailRow(label: "Last Played", value: formatDate(lastPlayed))
                }
            }
        }
        .padding(16)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
        .shadow(color: Color("ElementAccent").opacity(0.1), radius: 5, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct GameStatDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("ElementAccent").opacity(0.8))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("ActionPrimary"))
        }
    }
}

#Preview {
    StatisticsView()
}

