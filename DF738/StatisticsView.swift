import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Overall stats
                        overallStats
                        
                        // Achievements section
                        achievementsSection
                        
                        // Progress section
                        progressSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Statistics")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var overallStats: some View {
        VStack(spacing: 20) {
            Text("Overall Progress")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 15) {
                StatRow(icon: "💎", label: "Total Gems", value: "\(rewardSystem.gems)")
                StatRow(icon: "⚡", label: "Power Level", value: "\(rewardSystem.powerLevel)")
                StatRow(icon: "🎮", label: "Games Played", value: "\(rewardSystem.totalGamesPlayed)")
                StatRow(icon: "⏱️", label: "Total Play Time", value: "\(rewardSystem.totalPlayTimeMinutes) min")
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(20)
        }
    }
    
    private var achievementsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Achievements")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(rewardSystem.achievements.count)")
                    .font(.title3.bold())
                    .foregroundColor(Color("ElementAccent"))
            }
            
            if rewardSystem.achievements.isEmpty {
                VStack(spacing: 15) {
                    Text("🏆")
                        .font(.system(size: 60))
                    Text("No achievements yet")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    Text("Play games to unlock achievements!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color("BackgroundSecondary"))
                .cornerRadius(20)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                    ForEach(rewardSystem.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 20) {
            Text("Next Level")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Level \(rewardSystem.powerLevel)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Level \(rewardSystem.powerLevel + 1)")
                        .font(.headline)
                        .foregroundColor(Color("ElementAccent"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("BackgroundSecondary"))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(colors: [Color("ActionPrimary"), Color("ElementAccent")],
                                             startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geometry.size.width * progressToNextLevel, height: 20)
                    }
                }
                .frame(height: 20)
                
                Text("\(gemsToNextLevel) gems to next level")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(20)
        }
    }
    
    private var progressToNextLevel: CGFloat {
        let gemsInCurrentLevel = rewardSystem.gems % 100
        return CGFloat(gemsInCurrentLevel) / 100.0
    }
    
    private var gemsToNextLevel: Int {
        return 100 - (rewardSystem.gems % 100)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            Text(label)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.icon)
                .font(.system(size: 40))
            
            Text(achievement.title)
                .font(.caption.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(colors: [Color("ActionPrimary").opacity(0.3), Color("ElementAccent").opacity(0.3)],
                         startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("ElementAccent").opacity(0.5), lineWidth: 2)
        )
        .cornerRadius(16)
    }
}



