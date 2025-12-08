import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var rewardSystem: RewardSystem
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Color("ElementAccent"))
    }
}
