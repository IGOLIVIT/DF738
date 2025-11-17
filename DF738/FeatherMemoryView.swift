//
//  FeatherMemoryView.swift
//  DF738
//

import SwiftUI
import Combine

struct FeatherMemoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var rewardSystem = RewardSystem.shared
    @StateObject private var gameState = FeatherMemoryGameState()
    
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
                        Text("Round: \(gameState.currentRound)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("ElementAccent"))
                        if gameState.isShowingSequence {
                            Text("Watch!")
                                .font(.system(size: 14))
                                .foregroundColor(Color("ActionPrimary"))
                        } else if gameState.gameStatus == .playing {
                            Text("Your Turn!")
                                .font(.system(size: 14))
                                .foregroundColor(Color("ActionPrimary"))
                        }
                    }
                }
                .padding()
                .background(Color("BackgroundSecondary"))
                
                if gameState.gameStatus == .playing {
                    FeatherMemoryGameView(gameState: gameState)
                } else if gameState.gameStatus == .ready {
                    FeatherMemoryReadyScreen(gameState: gameState)
                } else {
                    FeatherMemoryResultScreen(
                        rounds: gameState.currentRound - 1,
                        earnedFeathers: gameState.earnedFeathers,
                        gotGolden: gameState.gotGoldenFeather,
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

class FeatherMemoryGameState: ObservableObject {
    enum GameStatus {
        case ready, playing, finished
    }
    
    @Published var gameStatus: GameStatus = .ready
    @Published var currentRound: Int = 1
    @Published var sequence: [Int] = []
    @Published var playerSequence: [Int] = []
    @Published var isShowingSequence: Bool = false
    @Published var activeIndex: Int? = nil
    @Published var earnedFeathers: Int = 0
    @Published var gotGoldenFeather: Bool = false
    
    private var sequenceTimer: Timer?
    
    func startGame() {
        gameStatus = .playing
        currentRound = 1
        sequence = []
        playerSequence = []
        isShowingSequence = false
        
        startNewRound()
    }
    
    func startNewRound() {
        playerSequence = []
        sequence.append(Int.random(in: 0...3))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showSequence()
        }
    }
    
    func showSequence() {
        isShowingSequence = true
        var index = 0
        
        sequenceTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if index < self.sequence.count {
                self.activeIndex = self.sequence[index]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.activeIndex = nil
                }
                
                index += 1
            } else {
                timer.invalidate()
                self.isShowingSequence = false
            }
        }
    }
    
    func tileTapped(_ index: Int) {
        guard !isShowingSequence else { return }
        
        playerSequence.append(index)
        
        // Flash the tile
        activeIndex = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.activeIndex = nil
        }
        
        // Check if correct
        let currentStep = playerSequence.count - 1
        if playerSequence[currentStep] != sequence[currentStep] {
            // Wrong!
            endGame()
        } else if playerSequence.count == sequence.count {
            // Completed this round!
            currentRound += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.startNewRound()
            }
        }
    }
    
    private func endGame() {
        stopGame()
        gameStatus = .finished
        
        let roundsCompleted = currentRound - 1
        earnedFeathers = roundsCompleted * 10
        gotGoldenFeather = roundsCompleted >= 10
        
        RewardSystem.shared.addStars(earnedFeathers)
        if gotGoldenFeather {
            RewardSystem.shared.addTrophies(1)
        }
        RewardSystem.shared.recordSession(playTimeMinutes: 1)
    }
    
    func stopGame() {
        sequenceTimer?.invalidate()
        sequenceTimer = nil
    }
    
    func reset() {
        stopGame()
        gameStatus = .ready
        currentRound = 1
        sequence = []
        playerSequence = []
        isShowingSequence = false
        activeIndex = nil
    }
}

struct FeatherMemoryGameView: View {
    @ObservedObject var gameState: FeatherMemoryGameState
    
    let colors: [Color] = [
        Color("ActionPrimary"),
        Color("BackgroundSecondary"),
        Color("ElementAccent"),
        Color("BackgroundPrimary")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    FeatherTile(
                        index: 0,
                        color: colors[0],
                        isActive: gameState.activeIndex == 0,
                        onTap: {
                            gameState.tileTapped(0)
                        }
                    )
                    
                    FeatherTile(
                        index: 1,
                        color: colors[1],
                        isActive: gameState.activeIndex == 1,
                        onTap: {
                            gameState.tileTapped(1)
                        }
                    )
                }
                
                HStack(spacing: 20) {
                    FeatherTile(
                        index: 2,
                        color: colors[2],
                        isActive: gameState.activeIndex == 2,
                        onTap: {
                            gameState.tileTapped(2)
                        }
                    )
                    
                    FeatherTile(
                        index: 3,
                        color: colors[3],
                        isActive: gameState.activeIndex == 3,
                        onTap: {
                            gameState.tileTapped(3)
                        }
                    )
                }
            }
            .padding(30)
            .background(Color("BackgroundSecondary").opacity(0.5))
            .cornerRadius(20)
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct FeatherTile: View {
    let index: Int
    let color: Color
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color)
                    .frame(width: 120, height: 120)
                    .shadow(color: isActive ? color.opacity(0.8) : Color.clear, radius: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(isActive ? 1 : 0.3), lineWidth: 4)
                    )
                
                Text("⭐")
                    .font(.system(size: 50))
                    .opacity(isActive ? 1 : 0.7)
            }
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isActive)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatherMemoryReadyScreen: View {
    @ObservedObject var gameState: FeatherMemoryGameState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("🌟")
                .font(.system(size: 100))
            
            Text("Star Pattern Memory")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("ElementAccent"))
            
            Text("Watch the constellation light up,\nthen repeat it!\nEach round adds one more step.\nGet 10+ rounds for a Golden Trophy! 🏆")
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

struct FeatherMemoryResultScreen: View {
    let rounds: Int
    let earnedFeathers: Int
    let gotGolden: Bool
    let onPlayAgain: () -> Void
    let onBackToHome: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                Text(gotGolden ? "🏆" : rounds >= 5 ? "🌟" : "💪")
                    .font(.system(size: 100))
                
                Text(gotGolden ? "Golden Trophy!" : rounds >= 5 ? "Great Memory!" : "Good Try!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                
                if gotGolden {
                    Text("You earned the Golden Trophy!")
                        .font(.system(size: 18))
                        .foregroundColor(Color("ActionPrimary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(spacing: 15) {
                    HStack(spacing: 12) {
                        Text("🔢")
                            .font(.system(size: 32))
                        Text("Rounds: \(rounds)")
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
                    
                    if gotGolden {
                        HStack(spacing: 12) {
                            Text("🏆")
                                .font(.system(size: 32))
                            Text("Earned: 1 Trophy")
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

