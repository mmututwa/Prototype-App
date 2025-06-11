import SwiftUI

struct ProfileView: View {
    @ObservedObject var authService: AuthenticationService
    
    var body: some View {
        VStack(spacing: 24) {
            if let user = authService.currentUser {
                profileHeader(for: user)
                profileStats(for: user)
                profileActions
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .background(BackgroundView())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private func profileHeader(for user: AppUser) -> some View {
        VStack(spacing: 16) {
            // Profile Image Placeholder
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(user.firstName.prefix(1) + user.lastName.prefix(1))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 4) {
                Text(user.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Member since \(formatDate(user.dateJoined))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.vertical, 20)
    }
    
    private func profileStats(for user: AppUser) -> some View {
        HStack(spacing: 20) {
            statCard(
                title: "Enrolled",
                value: "\(user.enrolledCourses.count)",
                color: .blue
            )
            
            statCard(
                title: "Completed",
                value: "\(user.completedCourses.count)",
                color: .green
            )
            
            statCard(
                title: "Progress",
                value: progressPercentage(for: user),
                color: .orange
            )
        }
    }
    
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var profileActions: some View {
        VStack(spacing: 16) {
            // Account Settings Button
            Button(action: {
                // TODO: Implement account settings
            }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                    
                    Text("Account Settings")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Help & Support Button
            Button(action: {
                // TODO: Implement help & support
            }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Help & Support")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Sign Out Button
            Button(action: {
                authService.signOut()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .foregroundColor(.red)
                    
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.top, 20)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func progressPercentage(for user: AppUser) -> String {
        guard user.enrolledCourses.count > 0 else { return "0%" }
        let percentage = (Double(user.completedCourses.count) / Double(user.enrolledCourses.count)) * 100
        return "\(Int(percentage))%"
    }
}

#Preview {
    NavigationView {
        ProfileView(authService: AuthenticationService())
    }
    .preferredColorScheme(.dark)
} 