//
//  RewardSystem.swift
//  DF738
//

import Foundation
import Combine

class RewardSystem: ObservableObject {
    static let shared = RewardSystem()
    
    @Published var stars: Int = 0
    @Published var trophies: Int = 0
    @Published var cosmosPoints: Int = 0
    @Published var totalSessions: Int = 0
    @Published var totalPlayTimeMinutes: Int = 0
    
    private let starsKey = "stars"
    private let trophiesKey = "trophies"
    private let cosmosPointsKey = "cosmosPoints"
    private let totalSessionsKey = "totalSessions"
    private let totalPlayTimeKey = "totalPlayTimeMinutes"
    
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
    
    func resetProgress() {
        stars = 0
        trophies = 0
        cosmosPoints = 0
        totalSessions = 0
        totalPlayTimeMinutes = 0
        saveRewards()
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
    }
}

