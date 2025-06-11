//
//  ContentView.swift
//  Prototype
//
//  Created by Mututwa Mututwa on 2/23/25.
//

import SwiftUI

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let coursesCompleted: Int
    let skillRating: Int
    let rank: Int
}

struct AnimatedFeatureTile: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            iconView
            titleView
            descriptionView
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(tileBackground)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(
            color: iconColor.opacity(isPressed ? 0.3 : 0.1),
            radius: isPressed ? 8 : 4,
            x: 0,
            y: isPressed ? 6 : 2
        )
        .simultaneousGesture(TapGesture().onEnded {
            handleTap()
        })
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: isPressed ? 32 : 28))
            .foregroundColor(iconColor)
    }
    
    private var titleView: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
    
    private var descriptionView: some View {
        Text(description)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }
    
    private var tileBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(isPressed ? 0.25 : 0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(isPressed ? 0.4 : 0.2), lineWidth: isPressed ? 2 : 1)
            )
    }
    
    private func handleTap() {
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            logoSection
            Spacer()
            iconSection
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .padding(.top, 8)
        .shadow(color: .gray.opacity(0.15), radius: 4, y: 1)
    }
    
    private var logoSection: some View {
        HStack(spacing: 8) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            Text("ProtoType.")
                .font(.title3)
                .fontWeight(.bold)
        }
        .foregroundColor(.blue)
    }
    
    private var navigationSection: some View {
        HStack(spacing: 20) {
            Text("Courses")
            Text("About")
            Text("Pricing")
        }
        .font(.caption)
        .foregroundColor(.primary)
    }
    
    private var iconSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
            Image(systemName: "person.circle")
        }
        .font(.system(size: 16))
        .foregroundColor(.blue)
    }
}

struct HeroSectionView: View {
    @State private var hasAppeared = false
    @State private var typedText = ""
    @State private var showCursor = true
    
    private let fullText = "Average is overrated..."
    private let typingSpeed: Double = 0.08
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(typedText.isEmpty ? " " : typedText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .shadow(
                        color: .green.opacity(0.2),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                    .frame(minHeight: 30)
                
                if showCursor && typedText.count < fullText.count {
                    Text("|")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .opacity(showCursor ? 1.0 : 0.0)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .onAppear {
            // Initial appear animation
            withAnimation(.easeOut(duration: 0.8)) {
                hasAppeared = true
            }
            
            // Start typing animation after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startTypingAnimation()
            }
        }
    }
    
    private func startTypingAnimation() {
        performTypingCycle()
    }
    
    private func performTypingCycle() {
        // Reset text to start fresh
        typedText = ""
        
        // Start cursor blinking (without animation)
        showCursor = true
        
        // Type each character
        for i in 0..<fullText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * typingSpeed) {
                typedText = String(fullText.prefix(i + 1))
            }
        }
        
        // Hide cursor after typing is complete and schedule next cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(fullText.count) * typingSpeed + 0.5) {
            showCursor = false // Hide cursor when typing is done
            
            // Schedule next typing cycle after a pause (8 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                performTypingCycle()
            }
        }
    }
    

}

struct FeaturesSectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            // sectionHeader
            featuresGrid
        }
    }
    
    // private var sectionHeader: some View {
    //     HStack {
    //         Text("✨ Features")
    //             .font(.system(size: 20, weight: .semibold))
    //             .foregroundColor(.white)
    //             .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
    //         Spacer()
    //     }
    //     .padding(.horizontal, 24)
    // }
    
    private var featuresGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 10) {
            
            NavigationLink(destination: CoursesView()) {
                AnimatedFeatureTile(
                    icon: "play.tv.fill",
                    iconColor: .blue,
                    title: "Training Academy",
                    description: "Video lessons + physical drills with feedback"
                )
            }
            
            AnimatedFeatureTile(
                icon: "target",
                iconColor: .blue,
                title: "Skill Challenges",
                description: "Shooting accuracy, dribbling, passing circuits"
            )
                     
            AnimatedFeatureTile(
                icon: "gamecontroller.fill",
                iconColor: .blue,
                title: "Tactical Scenarios",
                description: "Game simulations: 2v2, 5v5 match scenarios"
            )
            
            AnimatedFeatureTile(
                icon: "rosette",
                iconColor: .blue,
                title: "Certifications",
                description: "Skill certifications & tournaments"
            )
            
            AnimatedFeatureTile(
                icon: "eye.fill",
                iconColor: .blue,
                title: "Scouting System",
                description: "Performance profiles for coaches to see"
            )
            
            AnimatedFeatureTile(
                icon: "person.3.fill",
                iconColor: .blue,
                title: "Teams & Forums",
                description: "Shared improvement & peer motivation"
            )
        }
        .padding(.horizontal, 20)
        .buttonStyle(.plain)
    }
    
         private var gridColumns: [GridItem] {
         [
             GridItem(.flexible(minimum: 100, maximum: 170), spacing: 14),
             GridItem(.flexible(minimum: 100, maximum: 170), spacing: 14)
         ]
     }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            scrollableContent
                .navigationTitle("")
                .navigationBarHidden(true)
                .background(BackgroundView())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var scrollableContent: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                HeaderView()
                    .padding(.top, 32)
                HeroSectionView()
                FeaturesSectionView()
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Image("Image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

#Preview("iPhone") {
    ContentView()
        .preferredColorScheme(.dark)
}
