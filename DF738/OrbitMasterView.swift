import SwiftUI
import Combine

struct OrbitMasterView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameState = OrbitGameState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("BackgroundPrimary").ignoresSafeArea()
                
                if gameState.gameOver {
                    gameOverView
                } else if !gameState.gameStarted {
                    startView
                } else {
                    gameView(geometry: geometry)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Orbit Master")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var startView: some View {
        VStack(spacing: 30) {
            Text("🌀")
                .font(.system(size: 80))
            
            Text("Orbit Master")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tap to change orbit direction\nCollect stars, avoid obstacles!")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button(action: {
                gameState.startGame()
            }) {
                Text("Start Game")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(colors: [Color("ActionPrimary"), Color("ElementAccent")],
                                     startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func gameView(geometry: GeometryProxy) -> some View {
        ZStack {
            // Background tap area
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    gameState.toggleDirection()
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Score: \(gameState.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("💎 \(gameState.starsCollected)")
                        .font(.headline)
                        .foregroundColor(Color("ElementAccent"))
                }
                .padding()
                .background(Color("BackgroundSecondary"))
                
                Spacer()
            }
            
            // Center circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: gameState.orbitRadius * 2, height: gameState.orbitRadius * 2)
            
            Circle()
                .fill(Color("ActionPrimary").opacity(0.5))
                .frame(width: 30, height: 30)
            
            // Player
            Circle()
                .fill(
                    LinearGradient(colors: [Color("ActionPrimary"), Color("ElementAccent")],
                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .position(gameState.playerPosition)
            
            // Stars
            ForEach(gameState.stars) { star in
                Text("⭐")
                    .font(.system(size: 30))
                    .position(star.position)
            }
            
            // Obstacles
            ForEach(gameState.obstacles) { obstacle in
                Circle()
                    .fill(Color.red)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .position(obstacle.position)
            }
        }
        .onAppear {
            gameState.startGameLoop(geometry: geometry)
        }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Text("Final Score")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(gameState.score)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                Text("⭐ \(gameState.starsCollected) Stars Collected")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text("💎 +\(gameState.gemsEarned) Gems")
                    .font(.title2.bold())
                    .foregroundColor(Color("ElementAccent"))
            }
            .padding(30)
            .background(Color("BackgroundSecondary"))
            .cornerRadius(20)
            
            VStack(spacing: 15) {
                Button(action: {
                    gameState.resetGame()
                }) {
                    Text("Play Again")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            LinearGradient(colors: [Color("ActionPrimary"), Color("ElementAccent")],
                                         startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Back to Menu")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("BackgroundSecondary"))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

class OrbitGameState: ObservableObject {
    @Published var score: Int = 0
    @Published var starsCollected: Int = 0
    @Published var gameStarted: Bool = false
    @Published var gameOver: Bool = false
    @Published var playerPosition: CGPoint = .zero
    @Published var stars: [OrbitStar] = []
    @Published var obstacles: [OrbitObstacle] = []
    @Published var gemsEarned: Int = 0
    
    let orbitRadius: CGFloat = 120
    private var gameTimer: AnyCancellable?
    private var angle: Double = 0
    private var angularSpeed: Double = 2.0
    private var isClockwise: Bool = true
    private var centerPoint: CGPoint = .zero
    
    func startGame() {
        gameStarted = true
        gameOver = false
        score = 0
        starsCollected = 0
        angle = 0
        isClockwise = true
        angularSpeed = 2.0
        stars = []
        obstacles = []
        gemsEarned = 0
    }
    
    func startGameLoop(geometry: GeometryProxy) {
        centerPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        updatePlayerPosition()
        
        // Spawn initial items
        spawnStar(geometry: geometry)
        
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update(geometry: geometry)
            }
    }
    
    func toggleDirection() {
        isClockwise.toggle()
    }
    
    private func update(geometry: GeometryProxy) {
        guard !gameOver else { return }
        
        // Update angle
        let direction: Double = isClockwise ? 1 : -1
        angle += (angularSpeed * direction * 0.016)
        updatePlayerPosition()
        
        // Check collisions with stars
        checkStarCollisions(geometry: geometry)
        
        // Check collisions with obstacles
        checkObstacleCollisions()
        
        // Spawn items randomly
        if Double.random(in: 0...1) < 0.02 {
            spawnStar(geometry: geometry)
        }
        
        if Double.random(in: 0...1) < 0.015 {
            spawnObstacle(geometry: geometry)
        }
    }
    
    private func updatePlayerPosition() {
        let x = centerPoint.x + orbitRadius * cos(angle)
        let y = centerPoint.y + orbitRadius * sin(angle)
        playerPosition = CGPoint(x: x, y: y)
    }
    
    private func spawnStar(geometry: GeometryProxy) {
        let randomAngle = Double.random(in: 0...(2 * .pi))
        let randomRadius = orbitRadius + CGFloat.random(in: -20...20)
        let x = centerPoint.x + randomRadius * cos(randomAngle)
        let y = centerPoint.y + randomRadius * sin(randomAngle)
        
        let star = OrbitStar(position: CGPoint(x: x, y: y))
        stars.append(star)
    }
    
    private func spawnObstacle(geometry: GeometryProxy) {
        let randomAngle = Double.random(in: 0...(2 * .pi))
        let x = centerPoint.x + orbitRadius * cos(randomAngle)
        let y = centerPoint.y + orbitRadius * sin(randomAngle)
        
        let obstacle = OrbitObstacle(position: CGPoint(x: x, y: y))
        obstacles.append(obstacle)
    }
    
    private func checkStarCollisions(geometry: GeometryProxy) {
        for i in stars.indices.reversed() {
            let distance = hypot(stars[i].position.x - playerPosition.x,
                               stars[i].position.y - playerPosition.y)
            
            if distance < 30 {
                stars.remove(at: i)
                score += 10
                starsCollected += 1
                angularSpeed = min(angularSpeed + 0.1, 5.0)
                spawnStar(geometry: geometry)
            }
        }
    }
    
    private func checkObstacleCollisions() {
        for obstacle in obstacles {
            let distance = hypot(obstacle.position.x - playerPosition.x,
                               obstacle.position.y - playerPosition.y)
            
            if distance < 26 {
                endGame()
                return
            }
        }
    }
    
    private func endGame() {
        gameOver = true
        gameTimer?.cancel()
        
        gemsEarned = starsCollected * 2
    }
    
    func resetGame() {
        gameStarted = false
        gameOver = false
        gameTimer?.cancel()
    }
}

struct OrbitStar: Identifiable {
    let id = UUID()
    var position: CGPoint
}

struct OrbitObstacle: Identifiable {
    let id = UUID()
    var position: CGPoint
}


