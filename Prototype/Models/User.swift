import Foundation

struct AppUser: Codable, Identifiable {
    let id: String
    var email: String
    var firstName: String
    var lastName: String
    var profileImageURL: String?
    var enrolledCourses: [String] // Course IDs
    var completedCourses: [String] // Course IDs
    var dateJoined: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(id: String = UUID().uuidString, email: String, firstName: String, lastName: String) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.enrolledCourses = []
        self.completedCourses = []
        self.dateJoined = Date()
    }
} 