//
//  GamesView.swift
//  DF738
//

import SwiftUI

struct GamesView: View {
    @ObservedObject var rewardSystem = RewardSystem.shared
    @State private var selectedGame: GameType? = nil
    
    enum GameType: String, CaseIterable {
        case crossingSprint = "Asteroid Dash"
        case fallingGrain = "Cosmic Crystal Collector"
        case obstacleMeadow = "Space Runner"
        case featherMemory = "Cosmic Pattern"
        
        var icon: String {
            switch self {
            case .crossingSprint: return "☄️"
            case .fallingGrain: return "💎"
            case .obstacleMeadow: return "🛸"
            case .featherMemory: return "🌟"
            }
        }
        
        var description: String {
            switch self {
            case .crossingSprint: return "Navigate through asteroid fields and avoid collisions"
            case .fallingGrain: return "Collect falling space crystals in your ship"
            case .obstacleMeadow: return "Fly through space and dodge cosmic obstacles"
            case .featherMemory: return "Remember and repeat the star constellation"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Spacer()
                            .frame(height: 20)
                        
                        // Header with decorative stars
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Text("🚀")
                                    .font(.system(size: 30))
                                Text("Choose Your Mission")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(Color("ElementAccent"))
                                Text("🚀")
                                    .font(.system(size: 30))
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        }
                        
                        // Rewards Summary
                        VStack(spacing: 15) {
                            HStack(spacing: 20) {
                                RewardBadge(icon: "🌟", label: "Stars", value: rewardSystem.stars)
                                RewardBadge(icon: "🏆", label: "Trophies", value: rewardSystem.trophies)
                                RewardBadge(icon: "💫", label: "Cosmos", value: rewardSystem.cosmosPoints)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Game Cards
                        VStack(spacing: 20) {
                            ForEach(GameType.allCases, id: \.self) { game in
                                GameCard(game: game, selectedGame: $selectedGame)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationDestination(for: GameType.self) { game in
                gameView(for: game)
            }
        }
    }
    
    @ViewBuilder
    private func gameView(for game: GameType) -> some View {
        switch game {
        case .crossingSprint:
            CrossingSprintView()
        case .fallingGrain:
            FallingGrainView()
        case .obstacleMeadow:
            ObstacleMeadowView()
        case .featherMemory:
            FeatherMemoryView()
        }
    }
}

struct RewardBadge: View {
    let icon: String
    let label: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            Text("\(value)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("ElementAccent"))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color("ElementAccent").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(16)
        .shadow(color: Color("ElementAccent").opacity(0.1), radius: 5, y: 2)
    }
}

struct GameCard: View {
    let game: GamesView.GameType
    @Binding var selectedGame: GamesView.GameType?
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(value: game) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color("ActionPrimary"))
                        .frame(width: 70, height: 70)
                    
                    Text(game.icon)
                        .font(.system(size: 36))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(game.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("ElementAccent"))
                    
                    Text(game.description)
                        .font(.system(size: 14))
                        .foregroundColor(Color("ElementAccent").opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("ActionPrimary"))
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
            .shadow(color: Color("ElementAccent").opacity(0.15), radius: 8, y: 3)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

