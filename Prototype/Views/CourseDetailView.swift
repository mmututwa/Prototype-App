import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Course Header Image
                courseHeaderImage
                
                // Course Information
                VStack(alignment: .leading, spacing: 16) {
                    courseTitle
                    courseMetadata
                    courseDescription
                    courseBenefits
                    coursePrerequisites
                    enrollmentButton
                }
                .padding(.horizontal, 24)
            }
        }
        .background(BackgroundView())
        .navigationTitle("Course Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Course Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var courseHeaderImage: some View {
        AsyncImage(url: URL(string: course.thumbnail.url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.3)
        }
        .frame(height: 250)
        .clipped()
    }
    
    private var courseTitle: some View {
        Text(course.name)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
    }
    
    private var courseMetadata: some View {
        HStack(spacing: 16) {
            // Level Badge
            Text(course.level.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(12)
            
            // Price
            Text("$\(course.price)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Spacer()
            
            // Rating if available
            if let rating = course.ratings {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var courseDescription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(course.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
    }
    
    private var courseBenefits: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What You'll Learn")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(course.benefits) { benefit in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                        .padding(.top, 2)
                    
                    Text(benefit.title)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var coursePrerequisites: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prerequisites")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(course.prerequisites) { prerequisite in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                        .padding(.top, 2)
                    
                    Text(prerequisite.title)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var enrollmentButton: some View {
        let isEnrolled = authService.currentUser?.enrolledCourses.contains(course.id) ?? false
        let isCompleted = authService.currentUser?.completedCourses.contains(course.id) ?? false
        
        return Button(action: {
            if isCompleted {
                // Already completed, no action needed
                return
            } else if isEnrolled {
                authService.completeCourse(course.id)
            } else {
                authService.enrollInCourse(course.id)
            }
        }) {
            HStack {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Completed")
                } else if isEnrolled {
                    Image(systemName: "play.circle.fill")
                    Text("Mark as Complete")
                } else {
                    Image(systemName: "plus.circle.fill")
                    Text("Enroll Now")
                }
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isCompleted ? Color.green :
                isEnrolled ? Color.orange : Color.blue
            )
            .cornerRadius(16)
        }
        .disabled(isCompleted)
        .padding(.top, 24)
    }
}

#Preview {
    NavigationView {
        CourseDetailView(course: Course(
            id: "1",
            name: "Introduction to American Football | Rules 101",
            description: "In this video, we break down the essential rules of American football in an easy-to-follow format. Viewers will learn about the game's structure, scoring methods, player roles, and key regulations that dictate how the game is played.",
            categories: ["Sports", "Football", "Beginner"],
            price: 9,
            estimatedPrice: 80,
            tags: "Football, Rules",
            level: "beginner",
            demoUrl: "Mututwa",
            benefits: [
                Benefit(id: "1", title: "Get Started on your way to Football Expert"),
                Benefit(id: "2", title: "Get the Foundations right with this Foundational Course")
            ],
            prerequisites: [
                Prerequisite(id: "1", title: "All you need is love for the Game"),
                Prerequisite(id: "2", title: "You do not need to have taken any Course before")
            ],
            courseData: [],
            ratings: 2.5,
            purchased: 0,
            reviews: [],
            isFree: false,
            lessons: nil,
            thumbnail: Thumbnail(public_id: "test", url: "https://example.com/image.jpg"),
            status: "Published",
            views: nil
        ))
    }
    .preferredColorScheme(.dark)
} 