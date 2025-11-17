//
//  OnboardingView.swift
//  DF738
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage1()
                    .tag(0)
                OnboardingPage2()
                    .tag(1)
                OnboardingPage3()
                    .tag(2)
                OnboardingPage4(isOnboardingComplete: $isOnboardingComplete)
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
    }
}

struct OnboardingPage1: View {
    @State private var rocketOffset: CGFloat = -20
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                ZStack {
                    Circle()
                        .fill(Color("BackgroundSecondary"))
                        .frame(width: 200, height: 200)
                        .shadow(color: Color("ElementAccent").opacity(0.2), radius: 10)
                    
                    Text("🚀")
                        .font(.system(size: 80))
                        .offset(y: rocketOffset)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                rocketOffset = 20
                            }
                        }
                }
                
                Text("Welcome, Space Explorer!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Text("Embark on a cosmic adventure filled with exciting challenges and stellar missions.")
                    .font(.system(size: 18))
                    .foregroundColor(Color("ElementAccent").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct OnboardingPage2: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("BackgroundSecondary"))
                        .frame(width: 200, height: 200)
                        .shadow(color: Color("ElementAccent").opacity(0.2), radius: 10)
                    
                    Text("🛸")
                        .font(.system(size: 80))
                        .scaleEffect(scale)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                scale = 1.2
                            }
                        }
                }
                
                Text("Meet Your Spacecraft")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Text("A sleek spacecraft ready to navigate through cosmic challenges and collect stellar rewards.")
                    .font(.system(size: 18))
                    .foregroundColor(Color("ElementAccent").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct OnboardingPage3: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color("ActionPrimary"))
                        .frame(width: 200, height: 200)
                        .shadow(color: Color("ElementAccent").opacity(0.2), radius: 10)
                    
                    VStack(spacing: 10) {
                        Text("🌟")
                            .font(.system(size: 40))
                        Text("🏆")
                            .font(.system(size: 40))
                        Text("💫")
                            .font(.system(size: 40))
                    }
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                }
                
                Text("Collect Rewards")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                VStack(spacing: 15) {
                    HStack(spacing: 12) {
                        Text("🌟")
                            .font(.system(size: 24))
                        Text("Stars — for every completed mission")
                            .font(.system(size: 16))
                            .foregroundColor(Color("ElementAccent").opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                    
                    HStack(spacing: 12) {
                        Text("🏆")
                            .font(.system(size: 24))
                        Text("Trophies — for special achievements")
                            .font(.system(size: 16))
                            .foregroundColor(Color("ElementAccent").opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                    
                    HStack(spacing: 12) {
                        Text("💫")
                            .font(.system(size: 24))
                        Text("Cosmos Points — for reaching milestones")
                            .font(.system(size: 16))
                            .foregroundColor(Color("ElementAccent").opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                    .frame(height: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct OnboardingPage4: View {
    @Binding var isOnboardingComplete: Bool
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("BackgroundSecondary"), Color("ActionPrimary")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: Color("ElementAccent").opacity(0.2), radius: 10)
                    
                    Text("🌌")
                        .font(.system(size: 80))
                }
                
                Text("Ready for Liftoff?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ElementAccent"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Text("Choose from multiple exciting cosmic games, each offering unique challenges and rewards. Your space adventure awaits!")
                    .font(.system(size: 18))
                    .foregroundColor(Color("ElementAccent").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    withAnimation {
                        isOnboardingComplete = true
                    }
                }) {
                    Text("Launch Adventure")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color("ActionPrimary"))
                        .cornerRadius(16)
                        .shadow(color: Color("ActionPrimary").opacity(0.4), radius: 8, y: 4)
                }
                .scaleEffect(buttonScale)
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        buttonScale = 1.05
                    }
                }
                
                Spacer()
                    .frame(height: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

