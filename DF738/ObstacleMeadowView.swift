//
//  ObstacleMeadowView.swift
//  DF738
//

import SwiftUI
import Combine

struct ObstacleMeadowView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var rewardSystem = RewardSystem.shared
    @StateObject private var gameState = ObstacleMeadowGameState()
    
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
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Distance: \(gameState.distance)m")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("ElementAccent"))
                        Text("Speed: \(String(format: "%.1f", gameState.speed))")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ElementAccent").opacity(0.7))
                    }
                }
                .padding()
                .background(Color("BackgroundSecondary"))
                
                if gameState.gameStatus == .playing {
                    ObstacleMeadowGameView(gameState: gameState)
                } else if gameState.gameStatus == .ready {
                    ObstacleMeadowReadyScreen(gameState: gameState)
                } else {
                    ObstacleMeadowResultScreen(
                        distance: gameState.distance,
                        earnedFeathers: gameState.earnedFeathers,
                        earnedMarks: gameState.earnedMarks,
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

class ObstacleMeadowGameState: ObservableObject {
    enum GameStatus {
        case ready, playing, finished
    }
    
    enum PlayerState {
        case running, jumping, sliding
    }
    
    @Published var gameStatus: GameStatus = .ready
    @Published var playerState: PlayerState = .running
    @Published var obstacles: [Obstacle] = []
    @Published var distance: Int = 0
    @Published var speed: Double = 2.5  // Ещё замедлил с 3.0 до 2.5
    @Published var earnedFeathers: Int = 0
    @Published var earnedMarks: Int = 0
    
    private var gameTimer: Timer?
    private var obstacleTimer: Timer?
    private var jumpTimer: Timer?
    private var slideTimer: Timer?
    
    struct Obstacle: Identifiable {
        let id = UUID()
        var xPosition: CGFloat
        var type: ObstacleType
        
        enum ObstacleType {
            case low, high
        }
    }
    
    func startGame() {
        gameStatus = .playing
        distance = 0
        speed = 3.5  // Ещё медленнее - с 4.0 до 3.5
        obstacles = []
        playerState = .running
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
        
        obstacleTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.spawnObstacle()
        }
    }
    
    func jump() {
        guard playerState == .running else { return }
        
        // НЕМЕДЛЕННО меняем состояние через main queue
        DispatchQueue.main.async { [weak self] in
            self?.playerState = .jumping
            print("🚀 JUMP activated")
        }
        
        jumpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.playerState = .running
            print("🚀 JUMP ended, back to running")
        }
    }
    
    func slide() {
        guard playerState == .running else { return }
        
        // НЕМЕДЛЕННО меняем состояние через main queue
        DispatchQueue.main.async { [weak self] in
            self?.playerState = .sliding
            print("⬇️ SLIDE activated")
        }
        
        slideTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: false) { [weak self] _ in
            self?.playerState = .running
            print("⬇️ SLIDE ended, back to running")
        }
    }
    
    private func updateGame() {
        // Move obstacles
        for i in obstacles.indices {
            obstacles[i].xPosition -= CGFloat(speed)
        }
        
        // Remove off-screen obstacles
        obstacles.removeAll { $0.xPosition < -50 }
        
        // Check collision
        if checkCollision() {
            endGame()
            return
        }
        
        // Increase distance and speed
        distance += 1
        if distance % 100 == 0 {
            speed += 0.5
        }
    }
    
    private func spawnObstacle() {
        let type: Obstacle.ObstacleType = Bool.random() ? .low : .high
        // Появляются ещё дальше - 150px от края экрана
        obstacles.append(Obstacle(xPosition: UIScreen.main.bounds.width + 150, type: type))
    }
    
    private func checkCollision() -> Bool {
        let playerX: CGFloat = 100
        
        // Вычисляем РЕАЛЬНУЮ Y-позицию игрока (нужно знать groundLevel)
        // groundLevel = screenHeight * 0.7
        let screenHeight = UIScreen.main.bounds.height
        let groundLevel = screenHeight * 0.7
        
        // Реальная Y-координата игрока
        let playerY: CGFloat
        switch playerState {
        case .running:
            playerY = groundLevel + 0
        case .jumping:
            playerY = groundLevel - 150
        case .sliding:
            playerY = groundLevel + 20
        }
        
        // Размеры (половина размера для проверки от центра)
        let playerHalfSize: CGFloat = 25  // Игрок 50px
        
        for obstacle in obstacles {
            let distance = abs(obstacle.xPosition - playerX)
            
            // Проверяем только если препятствие близко по X
            if distance < 35 {  // Горизонтальная зона
                
                // Реальная Y-координата препятствия
                let obstacleY: CGFloat
                let obstacleHalfSize: CGFloat
                
                if obstacle.type == .low {
                    obstacleY = groundLevel
                    obstacleHalfSize = 25  // Низкое 50px
                } else {
                    obstacleY = groundLevel - 180
                    obstacleHalfSize = 30  // Высокое 60px
                }
                
                // ГЕОМЕТРИЧЕСКАЯ проверка: пересекаются ли по вертикали?
                let verticalDistance = abs(playerY - obstacleY)
                let minSafeDistance = playerHalfSize + obstacleHalfSize
                
                if verticalDistance < minSafeDistance {
                    // Вертикальное пересечение - столкновение!
                    print("❌ COLLISION: type=\(obstacle.type), playerY=\(Int(playerY)), obstacleY=\(Int(obstacleY)), vertDist=\(Int(verticalDistance)), minSafe=\(Int(minSafeDistance))")
                    return true
                } else {
                    // Вертикально безопасно
                    print("✅ SAFE: type=\(obstacle.type), playerY=\(Int(playerY)), obstacleY=\(Int(obstacleY)), vertDist=\(Int(verticalDistance)), minSafe=\(Int(minSafeDistance))")
                }
            }
        }
        return false
    }
    
    private func endGame() {
        stopGame()
        gameStatus = .finished
        
        earnedFeathers = distance / 2
        earnedMarks = distance / 100
        
        RewardSystem.shared.addStars(earnedFeathers)
        RewardSystem.shared.addCosmosPoints(earnedMarks)
        RewardSystem.shared.recordSession(playTimeMinutes: 1)
        RewardSystem.shared.recordGameSession(game: "spaceRunner", score: distance, playTimeMinutes: 1)
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        obstacleTimer?.invalidate()
        jumpTimer?.invalidate()
        slideTimer?.invalidate()
        gameTimer = nil
        obstacleTimer = nil
        jumpTimer = nil
        slideTimer = nil
    }
    
    func reset() {
        stopGame()
        gameStatus = .ready
        playerState = .running
        obstacles = []
        distance = 0
        speed = 5.0
    }
}

struct ObstacleMeadowGameView: View {
    @ObservedObject var gameState: ObstacleMeadowGameState
    
    var body: some View {
        GeometryReader { geometry in
            let groundLevel = geometry.size.height * 0.7 // 70% from top is ground
            
            ZStack(alignment: .topLeading) {
                // Parallax Background
                VStack(spacing: 0) {
                    // Sky
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("BackgroundSecondary").opacity(0.5), Color("BackgroundPrimary")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: groundLevel)
                    
                    // Ground
                    Rectangle()
                        .fill(Color("BackgroundSecondary"))
                        .frame(height: geometry.size.height - groundLevel)
                }
                .ignoresSafeArea()
                
                // Ground line
                Rectangle()
                    .fill(Color("ElementAccent").opacity(0.4))
                    .frame(width: geometry.size.width, height: 3)
                    .position(x: geometry.size.width / 2, y: groundLevel)
                
                // Obstacles moving from right to left
                ForEach(gameState.obstacles) { obstacle in
                    Text(obstacle.type == .low ? "☄️" : "🌠")
                        .font(.system(size: obstacle.type == .low ? 50 : 60))
                        .position(
                            x: obstacle.xPosition,
                            // Низкое препятствие - на уровне земли (прыгаем через него)
                            // Высокое препятствие - ОЧЕНЬ ВЫСОКО над землёй (проползаем под ним)
                            // Учитываем что emoji размером 60px, центр на -180, значит низ на -150
                            y: obstacle.type == .low ? groundLevel : groundLevel - 180
                        )
                }
                
                // Player - fixed at left side, moves vertically on ground line
                Text(getPlayerEmoji())
                    .font(.system(size: 50))
                    .position(
                        x: 100,
                        y: groundLevel + getPlayerOffset()
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: gameState.playerState)
                
                // Controls overlay
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Button(action: {
                                gameState.jump()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 50))
                                    Text("Jump")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(Color("ActionPrimary"))
                                .padding()
                                .background(Color("BackgroundSecondary").opacity(0.8))
                                .clipShape(Circle())
                            }
                            
                            Button(action: {
                                gameState.slide()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 50))
                                    Text("Slide")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(Color("ActionPrimary"))
                                .padding()
                                .background(Color("BackgroundSecondary").opacity(0.8))
                                .clipShape(Circle())
                            }
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
    }
    
    private func getPlayerOffset() -> CGFloat {
        switch gameState.playerState {
        case .running:
            return 0  // На уровне земли
        case .jumping:
            return -150  // Прыжок вверх
        case .sliding:
            return 20   // Скольжение (небольшое опускание)
        }
    }
    
    private func getPlayerEmoji() -> String {
        return "🚀"
    }
}

struct ObstacleMeadowReadyScreen: View {
    @ObservedObject var gameState: ObstacleMeadowGameState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("🛸")
                .font(.system(size: 100))
            
            Text("Space Runner")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Fly through space!\nJump over asteroids ☄️\nSlide under comets 🌠\nGo as far as you can!")
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

struct ObstacleMeadowResultScreen: View {
    let distance: Int
    let earnedFeathers: Int
    let earnedMarks: Int
    let onPlayAgain: () -> Void
    let onBackToHome: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                Text(distance > 300 ? "🏆" : distance > 150 ? "🌟" : "💪")
                    .font(.system(size: 100))
                
                Text(distance > 300 ? "Amazing Flight!" : distance > 150 ? "Great Flight!" : "Good Try!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                VStack(spacing: 15) {
                    HStack(spacing: 12) {
                        Text("📏")
                            .font(.system(size: 32))
                        Text("Distance: \(distance) meters")
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
                    
                    if earnedMarks > 0 {
                        HStack(spacing: 12) {
                            Text("💫")
                                .font(.system(size: 32))
                            Text("Earned: \(earnedMarks) Cosmos Point\(earnedMarks > 1 ? "s" : "")")
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

