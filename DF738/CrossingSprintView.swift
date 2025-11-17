//
//  CrossingSprintView.swift
//  DF738
//

import SwiftUI
import Combine

struct CrossingSprintView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var rewardSystem = RewardSystem.shared
    @StateObject private var gameState = CrossingSprintGameState()
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
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
                    
                    Text("Time: \(Int(gameState.remainingTime))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("ElementAccent"))
                }
                .padding()
                .background(Color("BackgroundSecondary"))
                
                if gameState.gameStatus == .playing {
                    CrossingSprintGameView(gameState: gameState)
                } else if gameState.gameStatus == .ready {
                    ReadyScreen(gameState: gameState)
                } else {
                    ResultScreen(
                        earnedFeathers: gameState.earnedFeathers,
                        timeCompleted: gameState.timeCompleted,
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

class CrossingSprintGameState: ObservableObject {
    enum GameStatus {
        case ready, playing, finished
    }
    
    @Published var gameStatus: GameStatus = .ready
    @Published var playerLane: Int = 1 // 0, 1, 2 (3 lanes)
    @Published var obstacles: [Obstacle] = []
    @Published var remainingTime: Double = 30.0
    @Published var earnedFeathers: Int = 0
    @Published var timeCompleted: Int = 0
    
    private var gameTimer: Timer?
    private var obstacleTimer: Timer?
    
    struct Obstacle: Identifiable {
        let id = UUID()
        var lane: Int
        var yPosition: CGFloat
    }
    
    func startGame() {
        gameStatus = .playing
        remainingTime = 30.0
        earnedFeathers = 0
        obstacles = []
        playerLane = 1
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
        
        obstacleTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.spawnObstacle()
        }
    }
    
    func moveLeft() {
        if playerLane > 0 {
            playerLane -= 1
        }
    }
    
    func moveRight() {
        if playerLane < 2 {
            playerLane += 1
        }
    }
    
    private func updateGame() {
        remainingTime -= 0.1
        
        // Move obstacles
        for i in obstacles.indices {
            obstacles[i].yPosition += 5
        }
        
        // Remove off-screen obstacles
        obstacles.removeAll { $0.yPosition > 600 }
        
        // Check collision
        if checkCollision() {
            endGame(success: false)
            return
        }
        
        // Check time
        if remainingTime <= 0 {
            endGame(success: true)
        }
    }
    
    private func spawnObstacle() {
        let lane = Int.random(in: 0...2)
        obstacles.append(Obstacle(lane: lane, yPosition: 0))
    }
    
    private func checkCollision() -> Bool {
        for obstacle in obstacles {
            if obstacle.lane == playerLane && obstacle.yPosition > 400 && obstacle.yPosition < 500 {
                return true
            }
        }
        return false
    }
    
    private func endGame(success: Bool) {
        stopGame()
        gameStatus = .finished
        
        if success {
            timeCompleted = 30
            earnedFeathers = 50
        } else {
            timeCompleted = Int(30 - remainingTime)
            earnedFeathers = max(10, timeCompleted * 2)
        }
        
        RewardSystem.shared.addStars(earnedFeathers)
        RewardSystem.shared.recordSession(playTimeMinutes: 1)
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        obstacleTimer?.invalidate()
        gameTimer = nil
        obstacleTimer = nil
    }
    
    func reset() {
        stopGame()
        gameStatus = .ready
        playerLane = 1
        obstacles = []
        remainingTime = 30.0
        earnedFeathers = 0
    }
}

struct CrossingSprintGameView: View {
    @ObservedObject var gameState: CrossingSprintGameState
    
    var body: some View {
        ZStack {
            // Game Area
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    // Lanes
                    HStack(spacing: 0) {
                        ForEach(0..<3) { _ in
                            Rectangle()
                                .stroke(Color("ElementAccent").opacity(0.3), lineWidth: 2)
                                .background(Color("BackgroundSecondary").opacity(0.5))
                        }
                    }
                    .frame(height: 500)
                    .padding(.horizontal, 40)
                    
                    // Obstacles
                    ForEach(gameState.obstacles) { obstacle in
                        Text("☄️")
                            .font(.system(size: 40))
                            .position(
                                x: getLanePosition(lane: obstacle.lane),
                                y: obstacle.yPosition
                            )
                    }
                    
                    // Player
                    Text("🛸")
                        .font(.system(size: 50))
                        .position(
                            x: getLanePosition(lane: gameState.playerLane),
                            y: 450
                        )
                        .animation(.easeInOut(duration: 0.2), value: gameState.playerLane)
                }
                .frame(height: 500)
                
                Spacer()
            }
            
            // Controls
            VStack {
                Spacer()
                
                HStack(spacing: 40) {
                    Button(action: {
                        gameState.moveLeft()
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("ActionPrimary"))
                    }
                    
                    Button(action: {
                        gameState.moveRight()
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("ActionPrimary"))
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func getLanePosition(lane: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let laneWidth = (screenWidth - 80) / 3
        return 40 + laneWidth * CGFloat(lane) + laneWidth / 2
    }
}

struct ReadyScreen: View {
    @ObservedObject var gameState: CrossingSprintGameState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("☄️")
                .font(.system(size: 100))
            
            Text("Asteroid Dash")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Avoid asteroids for 30 seconds!\nUse arrows to switch lanes.")
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

struct ResultScreen: View {
    let earnedFeathers: Int
    let timeCompleted: Int
    let onPlayAgain: () -> Void
    let onBackToHome: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                Text(timeCompleted >= 30 ? "🎉" : "💪")
                    .font(.system(size: 100))
                
                Text(timeCompleted >= 30 ? "Success!" : "Good Try!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                VStack(spacing: 15) {
                    HStack(spacing: 12) {
                        Text("⏱️")
                            .font(.system(size: 32))
                        Text("Time: \(timeCompleted) seconds")
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

