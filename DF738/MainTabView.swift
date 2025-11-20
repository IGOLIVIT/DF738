//
//  MainTabView.swift
//  DF738
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var rewardSystem = RewardSystem.shared
    
    var body: some View {
        TabView {
            GamesView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(Color("ActionPrimary"))
    }
}

#Preview {
    MainTabView()
}

