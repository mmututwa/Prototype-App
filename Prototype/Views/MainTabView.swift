import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                ContentView()
                    .navigationViewStyle(StackNavigationViewStyle())
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // Courses Tab
            NavigationView {
                CoursesView()
                    .environmentObject(authService)
            }
            .tabItem {
                Image(systemName: "play.rectangle.fill")
                Text("Courses")
            }
            
            // Profile Tab
            NavigationView {
                ProfileView(authService: authService)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationService())
        .preferredColorScheme(.dark)
} 