import SwiftUI
import Combine

struct ColorCascadeView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameState = ColorCascadeGameState()
    
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
                Text("Color Cascade")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var startView: some View {
        VStack(spacing: 30) {
            Text("🌈")
                .font(.system(size: 80))
            
            Text("Color Cascade")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tap only the blocks matching\nthe target color!")
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
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score: \(gameState.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Lives: \(String(repeating: "❤️", count: gameState.lives))")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Target Color:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Circle()
                        .fill(gameState.targetColor)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            
            // Game area
            ZStack {
                ForEach(gameState.fallingBlocks) { block in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(block.color)
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .position(x: block.x, y: block.y)
                        .onTapGesture {
                            gameState.tapBlock(block, geometry: geometry, rewardSystem: rewardSystem)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            gameState.startSpawning(geometry: geometry)
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
                
                Text("💎 +\(gameState.gemsEarned) Gems")
                    .font(.title2.bold())
                    .foregroundColor(.white)
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

class ColorCascadeGameState: ObservableObject {
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var gameStarted: Bool = false
    @Published var gameOver: Bool = false
    @Published var fallingBlocks: [FallingBlock] = []
    @Published var targetColor: Color = .red
    @Published var gemsEarned: Int = 0
    
    private var gameTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private var fallSpeed: Double = 2.5
    private let availableColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan]
    private var startTime: Date?
    
    func startGame() {
        gameStarted = true
        gameOver = false
        score = 0
        lives = 3
        fallingBlocks = []
        fallSpeed = 2.5
        gemsEarned = 0
        targetColor = availableColors.randomElement() ?? .red
        startTime = Date()
    }
    
    func startSpawning(geometry: GeometryProxy) {
        // Update blocks position
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateBlocks(geometry: geometry)
            }
        
        // Spawn new blocks
        spawnTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnBlock(geometry: geometry)
            }
    }
    
    private func spawnBlock(geometry: GeometryProxy) {
        guard !gameOver else { return }
        
        let isTargetColor = Double.random(in: 0...1) < 0.4 // 40% chance
        let color = isTargetColor ? targetColor : availableColors.filter { $0 != targetColor }.randomElement() ?? .gray
        
        let block = FallingBlock(
            x: CGFloat.random(in: 60...(geometry.size.width - 60)),
            y: -30,
            color: color
        )
        
        fallingBlocks.append(block)
    }
    
    private func updateBlocks(geometry: GeometryProxy) {
        guard !gameOver else { return }
        
        for i in fallingBlocks.indices {
            fallingBlocks[i].y += fallSpeed
            
            // Block reached bottom - lose life if it's target color
            if fallingBlocks[i].y > geometry.size.height + 30 {
                if fallingBlocks[i].color == targetColor {
                    lives -= 1
                    if lives <= 0 {
                        endGame()
                    }
                }
                fallingBlocks.remove(at: i)
                break
            }
        }
    }
    
    func tapBlock(_ block: FallingBlock, geometry: GeometryProxy, rewardSystem: RewardSystem) {
        guard let index = fallingBlocks.firstIndex(where: { $0.id == block.id }) else { return }
        
        if block.color == targetColor {
            // Correct tap
            score += 10
            fallingBlocks.remove(at: index)
            
            // Increase difficulty
            if score % 50 == 0 {
                fallSpeed += 0.3
                // Change target color
                targetColor = availableColors.randomElement() ?? .red
            }
        } else {
            // Wrong tap
            lives -= 1
            fallingBlocks.remove(at: index)
            if lives <= 0 {
                endGame()
            }
        }
    }
    
    private func endGame() {
        gameOver = true
        gameTimer?.cancel()
        spawnTimer?.cancel()
        
        // Calculate gems
        gemsEarned = score / 2
    }
    
    func resetGame() {
        gameStarted = false
        gameOver = false
        gameTimer?.cancel()
        spawnTimer?.cancel()
    }
}

struct FallingBlock: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
}



