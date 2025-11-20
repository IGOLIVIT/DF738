//
//  RewardSystem.swift
//  DF738
//

import Foundation
import Combine

struct GameStats: Codable {
    var gamesPlayed: Int = 0
    var highScore: Int = 0
    var totalScore: Int = 0
    var totalPlayTimeMinutes: Int = 0
    var lastPlayed: Date?
    
    var averageScore: Double {
        return gamesPlayed > 0 ? Double(totalScore) / Double(gamesPlayed) : 0
    }
}

class RewardSystem: ObservableObject {
    static let shared = RewardSystem()
    
    @Published var stars: Int = 0
    @Published var trophies: Int = 0
    @Published var cosmosPoints: Int = 0
    @Published var totalSessions: Int = 0
    @Published var totalPlayTimeMinutes: Int = 0
    
    // Game-specific statistics
    @Published var asteroidDashStats = GameStats()
    @Published var crystalCollectorStats = GameStats()
    @Published var spaceRunnerStats = GameStats()
    @Published var cosmicPatternStats = GameStats()
    
    private let starsKey = "stars"
    private let trophiesKey = "trophies"
    private let cosmosPointsKey = "cosmosPoints"
    private let totalSessionsKey = "totalSessions"
    private let totalPlayTimeKey = "totalPlayTimeMinutes"
    
    private let asteroidDashStatsKey = "asteroidDashStats"
    private let crystalCollectorStatsKey = "crystalCollectorStats"
    private let spaceRunnerStatsKey = "spaceRunnerStats"
    private let cosmicPatternStatsKey = "cosmicPatternStats"
    
    private init() {
        loadRewards()
    }
    
    func addStars(_ amount: Int) {
        stars += amount
        saveRewards()
    }
    
    func addTrophies(_ amount: Int) {
        trophies += amount
        saveRewards()
    }
    
    func addCosmosPoints(_ amount: Int) {
        cosmosPoints += amount
        saveRewards()
    }
    
    func recordSession(playTimeMinutes: Int = 0) {
        totalSessions += 1
        totalPlayTimeMinutes += playTimeMinutes
        saveRewards()
    }
    
    func recordGameSession(game: String, score: Int, playTimeMinutes: Int) {
        var stats: GameStats
        let statsKey: String
        
        switch game {
        case "asteroidDash":
            stats = asteroidDashStats
            statsKey = asteroidDashStatsKey
        case "crystalCollector":
            stats = crystalCollectorStats
            statsKey = crystalCollectorStatsKey
        case "spaceRunner":
            stats = spaceRunnerStats
            statsKey = spaceRunnerStatsKey
        case "cosmicPattern":
            stats = cosmicPatternStats
            statsKey = cosmicPatternStatsKey
        default:
            return
        }
        
        stats.gamesPlayed += 1
        stats.totalScore += score
        stats.totalPlayTimeMinutes += playTimeMinutes
        stats.lastPlayed = Date()
        
        if score > stats.highScore {
            stats.highScore = score
        }
        
        // Update published property
        switch game {
        case "asteroidDash":
            asteroidDashStats = stats
        case "crystalCollector":
            crystalCollectorStats = stats
        case "spaceRunner":
            spaceRunnerStats = stats
        case "cosmicPattern":
            cosmicPatternStats = stats
        default:
            break
        }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    func resetProgress() {
        stars = 0
        trophies = 0
        cosmosPoints = 0
        totalSessions = 0
        totalPlayTimeMinutes = 0
        
        asteroidDashStats = GameStats()
        crystalCollectorStats = GameStats()
        spaceRunnerStats = GameStats()
        cosmicPatternStats = GameStats()
        
        saveRewards()
        
        UserDefaults.standard.removeObject(forKey: asteroidDashStatsKey)
        UserDefaults.standard.removeObject(forKey: crystalCollectorStatsKey)
        UserDefaults.standard.removeObject(forKey: spaceRunnerStatsKey)
        UserDefaults.standard.removeObject(forKey: cosmicPatternStatsKey)
    }
    
    private func saveRewards() {
        UserDefaults.standard.set(stars, forKey: starsKey)
        UserDefaults.standard.set(trophies, forKey: trophiesKey)
        UserDefaults.standard.set(cosmosPoints, forKey: cosmosPointsKey)
        UserDefaults.standard.set(totalSessions, forKey: totalSessionsKey)
        UserDefaults.standard.set(totalPlayTimeMinutes, forKey: totalPlayTimeKey)
    }
    
    private func loadRewards() {
        stars = UserDefaults.standard.integer(forKey: starsKey)
        trophies = UserDefaults.standard.integer(forKey: trophiesKey)
        cosmosPoints = UserDefaults.standard.integer(forKey: cosmosPointsKey)
        totalSessions = UserDefaults.standard.integer(forKey: totalSessionsKey)
        totalPlayTimeMinutes = UserDefaults.standard.integer(forKey: totalPlayTimeKey)
        
        // Load game stats
        if let data = UserDefaults.standard.data(forKey: asteroidDashStatsKey),
           let stats = try? JSONDecoder().decode(GameStats.self, from: data) {
            asteroidDashStats = stats
        }
        
        if let data = UserDefaults.standard.data(forKey: crystalCollectorStatsKey),
           let stats = try? JSONDecoder().decode(GameStats.self, from: data) {
            crystalCollectorStats = stats
        }
        
        if let data = UserDefaults.standard.data(forKey: spaceRunnerStatsKey),
           let stats = try? JSONDecoder().decode(GameStats.self, from: data) {
            spaceRunnerStats = stats
        }
        
        if let data = UserDefaults.standard.data(forKey: cosmicPatternStatsKey),
           let stats = try? JSONDecoder().decode(GameStats.self, from: data) {
            cosmicPatternStats = stats
        }
    }
}

