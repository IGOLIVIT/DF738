import SwiftUI
import Combine

struct PulseRhythmView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameState = PulseRhythmGameState()
    
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
                Text("Pulse Rhythm")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var startView: some View {
        VStack(spacing: 30) {
            Text("🎵")
                .font(.system(size: 80))
            
            Text("Pulse Rhythm")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tap when the pulse ring\nmatches the target circle!")
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
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Score: \(gameState.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Combo: x\(gameState.combo)")
                        .font(.headline)
                        .foregroundColor(Color("ElementAccent"))
                    
                    Spacer()
                    
                    Text("Lives: \(String(repeating: "❤️", count: gameState.lives))")
                        .font(.subheadline)
                }
                .padding()
                .background(Color("BackgroundSecondary"))
                
                Spacer()
            }
            
            // Game area
            VStack {
                Spacer()
                
                ZStack {
                    // Target circle (static)
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 200, height: 200)
                    
                    // Perfect zone
                    Circle()
                        .stroke(Color("ElementAccent").opacity(0.5), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    // Pulsing circles
                    ForEach(gameState.pulseCircles) { pulse in
                        Circle()
                            .stroke(
                                LinearGradient(colors: [Color("ActionPrimary"), Color("ElementAccent")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 4
                            )
                            .frame(width: pulse.radius * 2, height: pulse.radius * 2)
                            .opacity(pulse.opacity)
                    }
                    
                    // Center dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    
                    // Tap feedback
                    if gameState.showTapFeedback {
                        Text(gameState.tapFeedbackText)
                            .font(.title.bold())
                            .foregroundColor(gameState.tapFeedbackColor)
                            .offset(y: -150)
                    }
                }
                
                Spacer()
                
                // Tap button
                Button(action: {
                    gameState.handleTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color("ActionPrimary"), Color("ElementAccent")],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color("ElementAccent").opacity(0.5), radius: 20)
                        
                        Text("TAP")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 60)
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
                
                HStack(spacing: 30) {
                    VStack {
                        Text("Perfect")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(gameState.perfectHits)")
                            .font(.title2.bold())
                            .foregroundColor(Color("ElementAccent"))
                    }
                    
                    VStack {
                        Text("Good")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(gameState.goodHits)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    
                    VStack {
                        Text("Max Combo")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(gameState.maxCombo)")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                    }
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

class PulseRhythmGameState: ObservableObject {
    @Published var score: Int = 0
    @Published var combo: Int = 0
    @Published var maxCombo: Int = 0
    @Published var lives: Int = 3
    @Published var gameStarted: Bool = false
    @Published var gameOver: Bool = false
    @Published var pulseCircles: [PulseCircle] = []
    @Published var perfectHits: Int = 0
    @Published var goodHits: Int = 0
    @Published var showTapFeedback: Bool = false
    @Published var tapFeedbackText: String = ""
    @Published var tapFeedbackColor: Color = .white
    @Published var gemsEarned: Int = 0
    
    private var gameTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private let targetRadius: CGFloat = 100
    private let perfectZone: CGFloat = 10
    private let goodZone: CGFloat = 30
    private var pulseSpeed: CGFloat = 1.5
    
    func startGame() {
        gameStarted = true
        gameOver = false
        score = 0
        combo = 0
        maxCombo = 0
        lives = 3
        perfectHits = 0
        goodHits = 0
        pulseCircles = []
        pulseSpeed = 1.5
        gemsEarned = 0
    }
    
    func startGameLoop(geometry: GeometryProxy) {
        // Update existing pulses
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePulses()
            }
        
        // Spawn new pulses
        spawnTimer = Timer.publish(every: 1.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnPulse()
            }
        
        // Spawn first pulse
        spawnPulse()
    }
    
    private func spawnPulse() {
        guard !gameOver else { return }
        
        let pulse = PulseCircle(radius: 0, opacity: 1.0)
        pulseCircles.append(pulse)
    }
    
    private func updatePulses() {
        guard !gameOver else { return }
        
        for i in pulseCircles.indices.reversed() {
            pulseCircles[i].radius += pulseSpeed
            
            // Fade out as it expands
            let progress = pulseCircles[i].radius / (targetRadius + 50)
            pulseCircles[i].opacity = max(0, 1.0 - progress)
            
            // Remove if too big
            if pulseCircles[i].radius > targetRadius + 100 {
                pulseCircles.remove(at: i)
                // Missed - lose life
                lives -= 1
                combo = 0
                if lives <= 0 {
                    endGame()
                }
            }
        }
    }
    
    func handleTap() {
        guard !pulseCircles.isEmpty else { return }
        
        // Find closest pulse to target
        let closestPulse = pulseCircles.min(by: { abs($0.radius - targetRadius) < abs($1.radius - targetRadius) })
        
        guard let pulse = closestPulse,
              let index = pulseCircles.firstIndex(where: { $0.id == pulse.id }) else { return }
        
        let distance = abs(pulse.radius - targetRadius)
        
        if distance <= perfectZone {
            // Perfect hit!
            score += 100 * (combo + 1)
            combo += 1
            maxCombo = max(maxCombo, combo)
            perfectHits += 1
            showFeedback(text: "PERFECT! ✨", color: Color("ElementAccent"))
            pulseSpeed = min(pulseSpeed + 0.05, 3.0)
        } else if distance <= goodZone {
            // Good hit
            score += 50 * (combo + 1)
            combo += 1
            maxCombo = max(maxCombo, combo)
            goodHits += 1
            showFeedback(text: "GOOD! 👍", color: .white)
        } else {
            // Miss
            lives -= 1
            combo = 0
            showFeedback(text: "MISS!", color: .red)
            if lives <= 0 {
                endGame()
            }
        }
        
        pulseCircles.remove(at: index)
    }
    
    private func showFeedback(text: String, color: Color) {
        tapFeedbackText = text
        tapFeedbackColor = color
        showTapFeedback = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showTapFeedback = false
        }
    }
    
    private func endGame() {
        gameOver = true
        gameTimer?.cancel()
        spawnTimer?.cancel()
        
        gemsEarned = (perfectHits * 5) + (goodHits * 2)
    }
    
    func resetGame() {
        gameStarted = false
        gameOver = false
        gameTimer?.cancel()
        spawnTimer?.cancel()
    }
}

struct PulseCircle: Identifiable {
    let id = UUID()
    var radius: CGFloat
    var opacity: Double
}


