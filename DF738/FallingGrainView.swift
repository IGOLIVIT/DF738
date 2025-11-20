//
//  FallingGrainView.swift
//  DF738
//

import SwiftUI
import Combine

struct FallingGrainView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var rewardSystem = RewardSystem.shared
    @StateObject private var gameState = FallingGrainGameState()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundPrimary"), Color("BackgroundSecondary")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("ActionPrimary"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Score: \(gameState.score)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("ElementAccent"))
                        Text("Missed: \(gameState.missedCount)/5")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ElementAccent").opacity(0.7))
                    }
                }
                .padding()
                .background(Color("BackgroundSecondary").opacity(0.8))
                
                if gameState.gameStatus == .playing {
                    FallingGrainGameView(gameState: gameState)
                } else if gameState.gameStatus == .ready {
                    FallingGrainReadyScreen(gameState: gameState)
                } else {
                    FallingGrainResultScreen(
                        score: gameState.score,
                        earnedFeathers: gameState.earnedFeathers,
                        earnedBadges: gameState.earnedBadges,
                        onPlayAgain: {
                            gameState.reset()
                        },
                        onBackToHome: {
                            dismiss()
                        }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            gameState.stopGame()
        }
    }
}

class FallingGrainGameState: ObservableObject {
    enum GameStatus {
        case ready, playing, finished
    }
    
    @Published var gameStatus: GameStatus = .ready
    @Published var basketPosition: CGFloat = UIScreen.main.bounds.width / 2
    @Published var grains: [Grain] = []
    @Published var score: Int = 0
    @Published var missedCount: Int = 0
    @Published var earnedFeathers: Int = 0
    @Published var earnedBadges: Int = 0
    
    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    
    struct Grain: Identifiable {
        let id = UUID()
        var xPosition: CGFloat
        var yPosition: CGFloat
        var isSpecial: Bool
    }
    
    func startGame() {
        gameStatus = .playing
        score = 0
        missedCount = 0
        grains = []
        basketPosition = UIScreen.main.bounds.width / 2
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.spawnGrain()
        }
    }
    
    func moveBasket(to position: CGFloat) {
        let minX: CGFloat = 40
        let maxX = UIScreen.main.bounds.width - 40
        basketPosition = max(minX, min(maxX, position))
    }
    
    private func updateGame() {
        // Move grains down
        for i in grains.indices {
            grains[i].yPosition += 3
        }
        
        // Check if grains are caught or missed
        var indicesToRemove: [Int] = []
        
        // Ship is at bottom of screen (height - 100)
        // Using approximate screen height for calculations
        let screenHeight: CGFloat = 850 // Conservative estimate for collision
        let shipYPosition = screenHeight - 100
        
        for (index, grain) in grains.enumerated() {
            // Check if grain reached ship level (with tolerance)
            if grain.yPosition >= shipYPosition - 30 && grain.yPosition <= shipYPosition + 30 {
                // Check horizontal distance
                if abs(grain.xPosition - basketPosition) < 55 {
                    // Caught!
                    if grain.isSpecial {
                        score += 5
                    } else {
                        score += 1
                    }
                    indicesToRemove.append(index)
                }
            } else if grain.yPosition > screenHeight + 50 {
                // Missed - went past the bottom
                missedCount += 1
                indicesToRemove.append(index)
            }
        }
        
        // Remove caught/missed grains
        for index in indicesToRemove.reversed() {
            grains.remove(at: index)
        }
        
        // Check game over
        if missedCount >= 5 {
            endGame()
        }
    }
    
    private func spawnGrain() {
        let xPosition = CGFloat.random(in: 60...(UIScreen.main.bounds.width - 60))
        let isSpecial = Int.random(in: 1...10) == 1 // 10% chance
        grains.append(Grain(xPosition: xPosition, yPosition: 0, isSpecial: isSpecial))
    }
    
    private func endGame() {
        stopGame()
        gameStatus = .finished
        
        earnedFeathers = score * 2
        earnedBadges = score / 20
        
        RewardSystem.shared.addStars(earnedFeathers)
        RewardSystem.shared.addTrophies(earnedBadges)
        RewardSystem.shared.recordSession(playTimeMinutes: 1)
        RewardSystem.shared.recordGameSession(game: "crystalCollector", score: score, playTimeMinutes: 1)
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
    }
    
    func reset() {
        stopGame()
        gameStatus = .ready
        score = 0
        missedCount = 0
        grains = []
        basketPosition = UIScreen.main.bounds.width / 2
    }
}

struct FallingGrainGameView: View {
    @ObservedObject var gameState: FallingGrainGameState
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background
                Color.clear
                
                // Grains falling from top
                ForEach(gameState.grains) { grain in
                    Text(grain.isSpecial ? "💫" : "💎")
                        .font(.system(size: grain.isSpecial ? 32 : 28))
                        .position(x: grain.xPosition, y: grain.yPosition)
                }
                
                // Ship at bottom - fixed position
                Text("🛸")
                    .font(.system(size: 60))
                    .position(x: gameState.basketPosition, y: geometry.size.height - 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        gameState.moveBasket(to: value.location.x)
                    }
            )
        }
    }
}

struct FallingGrainReadyScreen: View {
    @ObservedObject var gameState: FallingGrainGameState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("💎")
                .font(.system(size: 100))
            
            Text("Cosmic Crystal Collector")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Drag your ship to collect falling crystals!\n💫 Special crystals are worth 5 points.\nDon't miss more than 5 crystals!")
                .font(.system(size: 18))
                .foregroundColor(Color("ElementAccent").opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                gameState.startGame()
            }) {
                Text("Start Mission")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: 250)
                    .padding(.vertical, 18)
                    .background(Color("ActionPrimary"))
                    .cornerRadius(16)
            }
            
            Spacer()
        }
    }
}

struct FallingGrainResultScreen: View {
    let score: Int
    let earnedFeathers: Int
    let earnedBadges: Int
    let onPlayAgain: () -> Void
    let onBackToHome: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                Text(score > 50 ? "🎉" : score > 20 ? "🌟" : "💪")
                    .font(.system(size: 100))
                
                Text(score > 50 ? "Excellent!" : score > 20 ? "Great Job!" : "Good Try!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                VStack(spacing: 15) {
                    HStack(spacing: 12) {
                        Text("📊")
                            .font(.system(size: 32))
                        Text("Score: \(score)")
                            .font(.system(size: 18))
                            .foregroundColor(Color("ElementAccent"))
                    }
                    
                    HStack(spacing: 12) {
                        Text("🌟")
                            .font(.system(size: 32))
                        Text("Earned: \(earnedFeathers) Stars")
                            .font(.system(size: 18))
                            .foregroundColor(Color("ElementAccent"))
                    }
                    
                    if earnedBadges > 0 {
                        HStack(spacing: 12) {
                            Text("🏆")
                                .font(.system(size: 32))
                            Text("Earned: \(earnedBadges) Troph\(earnedBadges > 1 ? "ies" : "y")")
                                .font(.system(size: 18))
                                .foregroundColor(Color("ElementAccent"))
                        }
                    }
                }
                .padding(20)
                .background(Color("BackgroundSecondary"))
                .cornerRadius(16)
                .padding(.horizontal, 40)
                
                VStack(spacing: 15) {
                    Button(action: onPlayAgain) {
                        Text("Play Again")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color("ActionPrimary"))
                            .cornerRadius(16)
                    }
                    
                    Button(action: onBackToHome) {
                        Text("Back to Home")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("ElementAccent"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("BackgroundSecondary"))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 60)
            }
        }
    }
}

