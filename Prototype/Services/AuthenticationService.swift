import Foundation
import Combine

class AuthenticationService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "currentUser"
    
    init() {
        loadCurrentUser()
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            // In a real app, this would make an API call
            // For now, we'll simulate successful registration
            
            if isValidEmail(email) && password.count >= 6 {
                let newUser = AppUser(email: email, firstName: firstName, lastName: lastName)
                self.currentUser = newUser
                self.isAuthenticated = true
                self.saveCurrentUser(newUser)
                self.errorMessage = nil
            } else {
                self.errorMessage = "Invalid email or password too short (minimum 6 characters)"
            }
            
            self.isLoading = false
        }
    }
    
    func signIn(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            // In a real app, this would make an API call to verify credentials
            // For demo purposes, we'll simulate successful login
            
            if isValidEmail(email) && password.count >= 6 {
                // Create a demo user (in real app, this would come from server)
                let user = AppUser(email: email, firstName: "Demo", lastName: "User")
                self.currentUser = user
                self.isAuthenticated = true
                self.saveCurrentUser(user)
                self.errorMessage = nil
            } else {
                self.errorMessage = "Invalid email or password"
            }
            
            self.isLoading = false
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: currentUserKey)
    }
    
    // MARK: - Course Enrollment
    
    func enrollInCourse(_ courseId: String) {
        guard var user = currentUser else { return }
        
        if !user.enrolledCourses.contains(courseId) {
            user.enrolledCourses.append(courseId)
            self.currentUser = user
            saveCurrentUser(user)
        }
    }
    
    func completeCourse(_ courseId: String) {
        guard var user = currentUser else { return }
        
        if !user.completedCourses.contains(courseId) {
            user.completedCourses.append(courseId)
            self.currentUser = user
            saveCurrentUser(user)
        }
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func saveCurrentUser(_ user: AppUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: currentUserKey)
        }
    }
    
    private func loadCurrentUser() {
        if let data = userDefaults.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(AppUser.self, from: data) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
} 