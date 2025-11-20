//
//  SettingsView.swift
//  DF738
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var rewardSystem = RewardSystem.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Spacer()
                            .frame(height: 20)
                        
                        // App Info Section
                        VStack(spacing: 15) {
                            Text("⚙️")
                                .font(.system(size: 50))
                            Text("Settings")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("ElementAccent"))
                        }
                        
                        // Quick Stats Summary
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quick Summary")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("ElementAccent"))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                SettingsStatRow(icon: "🌟", label: "Total Stars", value: "\(rewardSystem.stars)")
                                SettingsStatRow(icon: "🏆", label: "Total Trophies", value: "\(rewardSystem.trophies)")
                                SettingsStatRow(icon: "💫", label: "Cosmos Points", value: "\(rewardSystem.cosmosPoints)")
                                SettingsStatRow(icon: "🎮", label: "Game Sessions", value: "\(rewardSystem.totalSessions)")
                                SettingsStatRow(icon: "⏱️", label: "Play Time", value: "\(rewardSystem.totalPlayTimeMinutes) min")
                            }
                            .padding(20)
                            .background(Color("BackgroundSecondary"))
                            .cornerRadius(16)
                            .shadow(color: Color("ElementAccent").opacity(0.1), radius: 5, y: 2)
                            .padding(.horizontal, 20)
                        }
                        
                        // Reset Progress Button
                        VStack(spacing: 15) {
                            Text("Danger Zone")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("ElementAccent"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            Button(action: {
                                showingResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Reset All Progress")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    rewardSystem.resetProgress()
                }
            } message: {
                Text("Are you sure you want to reset all your progress? This action cannot be undone.")
            }
        }
    }
}

struct SettingsStatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(icon)
                .font(.system(size: 28))
            
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(Color("ElementAccent").opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("ElementAccent"))
        }
    }
}

