import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("BackgroundPrimary"), Color("BackgroundSecondary")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage(
                    emoji: "🎮",
                    title: "Welcome to\nNeon Arcade",
                    description: "Experience 4 unique mini-games with stunning neon visuals and addictive gameplay"
                )
                .tag(0)
                
                OnboardingPage(
                    emoji: "💎",
                    title: "Collect Gems &\nLevel Up",
                    description: "Earn gems by playing games and increase your Power Level to unlock achievements"
                )
                .tag(1)
                
                OnboardingPage(
                    emoji: "🏆",
                    title: "Master All\n4 Games",
                    description: "Color Cascade, Orbit Master, Stack Tower, and Pulse Rhythm - each with unique mechanics"
                )
                .tag(2)
                
                OnboardingPage(
                    emoji: "⚡",
                    title: "Ready to\nPlay?",
                    description: "Challenge yourself, beat your high scores, and become the ultimate arcade master!",
                    isLast: true,
                    action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showOnboarding = false
                        }
                    }
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

struct OnboardingPage: View {
    let emoji: String
    let title: String
    let description: String
    var isLast: Bool = false
    var action: (() -> Void)?
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text(emoji)
                .font(.system(size: 120))
                .scaleEffect(scale)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: scale)
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(opacity)
                    .animation(.easeIn(duration: 0.6).delay(0.3), value: opacity)
                
                Text(description)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(opacity)
                    .animation(.easeIn(duration: 0.6).delay(0.5), value: opacity)
            }
            
            Spacer()
            
            if isLast {
                Button(action: {
                    action?()
                }) {
                    HStack {
                        Text("Let's Go!")
                            .font(.title2.bold())
                        Image(systemName: "arrow.right")
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [Color("ActionPrimary"), Color("ElementAccent")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color("ElementAccent").opacity(0.5), radius: 20, y: 10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .opacity(opacity)
                .animation(.easeIn(duration: 0.6).delay(0.7), value: opacity)
            } else {
                Text("Swipe to continue")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 60)
                    .opacity(opacity)
                    .animation(.easeIn(duration: 0.6).delay(0.7), value: opacity)
            }
        }
        .onAppear {
            scale = 1.0
            opacity = 1.0
        }
    }
}
