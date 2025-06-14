import SwiftUI

struct CoursesView: View {
    @State private var courses: [Course] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    private let apiService = ApiService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(.top, 16)
        .background(BackgroundView())
        .navigationTitle("Featured Courses")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .task {
            await loadCourses()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
        } else {
            coursesList
        }
    }
    
    private var coursesList: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(courses) { course in
                    NavigationLink(destination: CourseDetailView(course: course)) {
                        CourseCard(course: course)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func loadCourses() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allCourses = try await apiService.fetchCourses()
            courses = allCourses.filter { course in
                course.categories.contains { category in
                    category.localizedCaseInsensitiveContains("Football")
                }
            }
        } catch {
            errorMessage = "Failed to load courses. Please try again later."
            print("Error loading courses: \(error)")
        }
        
        isLoading = false
    }
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            courseImage
            courseDetails
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var courseImage: some View {
        AsyncImage(url: URL(string: course.thumbnail.url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.3)
        }
        .frame(height: 120)
        .clipped()
    }
    
    private var courseDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(course.name)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(12)
    }
}

#Preview {
    CoursesView()
        .environmentObject(AuthenticationService())
        .preferredColorScheme(.dark)
} 