import SwiftUI
import Combine

struct StackTowerView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameState = StackTowerGameState()
    
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
                Text("Stack Tower")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var startView: some View {
        VStack(spacing: 30) {
            Text("🏗️")
                .font(.system(size: 80))
            
            Text("Stack Tower")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tap to drop blocks\nStack them perfectly!")
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
                    gameState.dropBlock(geometry: geometry)
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Height: \(gameState.stackedBlocks.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Score: \(gameState.score)")
                        .font(.headline)
                        .foregroundColor(Color("ElementAccent"))
                }
                .padding()
                .background(Color("BackgroundSecondary"))
                
                Spacer()
            }
            
            // Stacked blocks
            ForEach(gameState.stackedBlocks) { block in
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: [block.color, block.color.opacity(0.7)],
                                     startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: block.width, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .position(x: block.x, y: block.y)
            }
            
            // Moving block
            if let movingBlock = gameState.movingBlock {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: [movingBlock.color, movingBlock.color.opacity(0.7)],
                                     startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: movingBlock.width, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .position(x: movingBlock.x, y: movingBlock.y)
                    .animation(.linear(duration: 0.016), value: movingBlock.x)
            }
        }
        .onAppear {
            gameState.startMovingBlock(geometry: geometry)
        }
    }
    
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Text("Tower Collapsed!")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Text("Tower Height")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(gameState.stackedBlocks.count)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                Text("Score: \(gameState.score)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                if gameState.perfectStacks > 0 {
                    Text("⭐ \(gameState.perfectStacks) Perfect Stacks!")
                        .font(.title3)
                        .foregroundColor(Color("ElementAccent"))
                }
                
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

class StackTowerGameState: ObservableObject {
    @Published var score: Int = 0
    @Published var perfectStacks: Int = 0
    @Published var gameStarted: Bool = false
    @Published var gameOver: Bool = false
    @Published var stackedBlocks: [StackBlock] = []
    @Published var movingBlock: StackBlock?
    @Published var gemsEarned: Int = 0
    
    private var gameTimer: AnyCancellable?
    private var moveDirection: CGFloat = 1
    private var moveSpeed: CGFloat = 2.0
    private var screenWidth: CGFloat = 0
    private let blockColors: [Color] = [
        Color("ActionPrimary"),
        Color("ElementAccent"),
        .purple,
        .orange,
        .pink,
        .cyan,
        .mint,
        .indigo
    ]
    
    func startGame() {
        gameStarted = true
        gameOver = false
        score = 0
        perfectStacks = 0
        stackedBlocks = []
        movingBlock = nil
        moveSpeed = 2.0
        gemsEarned = 0
    }
    
    func startMovingBlock(geometry: GeometryProxy) {
        screenWidth = geometry.size.width
        
        // Place first block at bottom center
        let firstBlock = StackBlock(
            x: geometry.size.width / 2,
            y: geometry.size.height - 100,
            width: 180,
            color: blockColors.randomElement() ?? .blue
        )
        stackedBlocks.append(firstBlock)
        
        spawnNextBlock(geometry: geometry)
    }
    
    private func spawnNextBlock(geometry: GeometryProxy) {
        guard let lastBlock = stackedBlocks.last else { return }
        
        let newY = lastBlock.y - 50
        // Start from left edge with proper offset
        let startX = lastBlock.width / 2 + 20
        let newBlock = StackBlock(
            x: startX,
            y: newY,
            width: lastBlock.width,
            color: blockColors.randomElement() ?? .blue
        )
        
        movingBlock = newBlock
        moveDirection = 1
        
        // Start moving animation with smoother interval
        gameTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMovingBlock(geometry: geometry)
            }
    }
    
    private func updateMovingBlock(geometry: GeometryProxy) {
        guard var block = movingBlock, !gameOver else { return }
        
        let halfWidth = block.width / 2
        let minX = halfWidth + 10
        let maxX = geometry.size.width - halfWidth - 10
        
        block.x += moveDirection * moveSpeed
        
        // Bounce at edges with proper bounds
        if block.x <= minX {
            block.x = minX
            moveDirection = 1
        } else if block.x >= maxX {
            block.x = maxX
            moveDirection = -1
        }
        
        movingBlock = block
    }
    
    func dropBlock(geometry: GeometryProxy) {
        guard var droppingBlock = movingBlock,
              let lastBlock = stackedBlocks.last else { return }
        
        gameTimer?.cancel()
        
        // Calculate overlap
        let leftEdge = max(droppingBlock.x - droppingBlock.width / 2,
                          lastBlock.x - lastBlock.width / 2)
        let rightEdge = min(droppingBlock.x + droppingBlock.width / 2,
                           lastBlock.x + lastBlock.width / 2)
        
        let overlap = rightEdge - leftEdge
        
        if overlap <= 0 {
            // No overlap - game over
            endGame()
            return
        }
        
        // Calculate accuracy
        let accuracy = overlap / lastBlock.width
        
        if accuracy >= 0.95 {
            // Perfect stack!
            score += 50
            perfectStacks += 1
            droppingBlock.x = lastBlock.x // Align perfectly
        } else {
            score += Int(accuracy * 20)
            droppingBlock.width = overlap
            droppingBlock.x = (leftEdge + rightEdge) / 2
        }
        
        // Add to stack
        stackedBlocks.append(droppingBlock)
        movingBlock = nil
        
        // Increase difficulty
        moveSpeed = min(moveSpeed + 0.2, 8.0)
        
        // Check if tower is too high (success condition)
        if droppingBlock.y < 150 {
            endGame()
            return
        }
        
        // Spawn next block
        spawnNextBlock(geometry: geometry)
    }
    
    private func endGame() {
        gameOver = true
        gameTimer?.cancel()
        
        // Calculate gems based on height and perfect stacks
        gemsEarned = stackedBlocks.count * 3 + perfectStacks * 5
    }
    
    func resetGame() {
        gameStarted = false
        gameOver = false
        gameTimer?.cancel()
    }
}

struct StackBlock: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var color: Color
}


