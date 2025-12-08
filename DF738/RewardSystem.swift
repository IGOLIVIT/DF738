import SwiftUI
import Combine

class RewardSystem: ObservableObject {
    @Published var gems: Int = 0
    @Published var powerLevel: Int = 1
    @Published var achievements: [Achievement] = []
    @Published var totalGamesPlayed: Int = 0
    @Published var totalPlayTimeMinutes: Int = 0
    
    private let gemsKey = "neonArcade_gems"
    private let powerLevelKey = "neonArcade_powerLevel"
    private let achievementsKey = "neonArcade_achievements"
    private let gamesPlayedKey = "neonArcade_gamesPlayed"
    private let playTimeKey = "neonArcade_playTime"
    
    init() {
        loadProgress()
    }
    
    func addGems(_ amount: Int) {
        gems += amount
        updatePowerLevel()
        saveProgress()
    }
    
    func recordGameSession(gameName: String, score: Int, duration: Int) {
        totalGamesPlayed += 1
        totalPlayTimeMinutes += duration
        checkAchievements(gameName: gameName, score: score)
        saveProgress()
    }
    
    private func updatePowerLevel() {
        let newLevel = 1 + (gems / 100)
        if newLevel > powerLevel {
            powerLevel = newLevel
            unlockAchievement(.levelUp(powerLevel))
        }
    }
    
    private func checkAchievements(gameName: String, score: Int) {
        if totalGamesPlayed == 1 {
            unlockAchievement(.firstGame)
        }
        if totalGamesPlayed == 10 {
            unlockAchievement(.tenGames)
        }
        if totalGamesPlayed == 50 {
            unlockAchievement(.fiftyGames)
        }
        if score >= 100 {
            unlockAchievement(.score100)
        }
        if score >= 500 {
            unlockAchievement(.score500)
        }
        if gems >= 1000 {
            unlockAchievement(.gemCollector)
        }
    }
    
    private func unlockAchievement(_ type: AchievementType) {
        guard !achievements.contains(where: { $0.type == type }) else { return }
        let achievement = Achievement(type: type)
        achievements.append(achievement)
    }
    
    func resetProgress() {
        gems = 0
        powerLevel = 1
        achievements = []
        totalGamesPlayed = 0
        totalPlayTimeMinutes = 0
        saveProgress()
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(gems, forKey: gemsKey)
        UserDefaults.standard.set(powerLevel, forKey: powerLevelKey)
        UserDefaults.standard.set(totalGamesPlayed, forKey: gamesPlayedKey)
        UserDefaults.standard.set(totalPlayTimeMinutes, forKey: playTimeKey)
        
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadProgress() {
        gems = UserDefaults.standard.integer(forKey: gemsKey)
        powerLevel = max(1, UserDefaults.standard.integer(forKey: powerLevelKey))
        totalGamesPlayed = UserDefaults.standard.integer(forKey: gamesPlayedKey)
        totalPlayTimeMinutes = UserDefaults.standard.integer(forKey: playTimeKey)
        
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
    }
}

struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let type: AchievementType
    let unlockedAt: Date
    
    init(type: AchievementType) {
        self.id = UUID()
        self.type = type
        self.unlockedAt = Date()
    }
    
    var title: String {
        type.title
    }
    
    var icon: String {
        type.icon
    }
}

enum AchievementType: Codable, Equatable {
    case firstGame
    case tenGames
    case fiftyGames
    case score100
    case score500
    case gemCollector
    case levelUp(Int)
    
    var title: String {
        switch self {
        case .firstGame: return "First Steps"
        case .tenGames: return "Getting Started"
        case .fiftyGames: return "Arcade Master"
        case .score100: return "Century Score"
        case .score500: return "High Scorer"
        case .gemCollector: return "Gem Collector"
        case .levelUp(let level): return "Level \(level) Reached"
        }
    }
    
    var icon: String {
        switch self {
        case .firstGame: return "🎮"
        case .tenGames: return "🎯"
        case .fiftyGames: return "👑"
        case .score100: return "💯"
        case .score500: return "🌟"
        case .gemCollector: return "💎"
        case .levelUp: return "⚡"
        }
    }
}


