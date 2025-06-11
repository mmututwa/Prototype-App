import Foundation

/// A service to handle network requests to the prototype server.
class ApiService {
    /// The base URL for the API.
    private let baseURL = URL(string: "https://prototype-server-eta.vercel.app/api/v1")!

    /// An instance of a JSONDecoder to reuse.
    private let decoder = JSONDecoder()

    /// Fetches all courses from the server.
    /// - Returns: An array of `Course` objects.
    func fetchCourses() async throws -> [Course] {
        // Construct the full URL for the get-courses endpoint.
        let url = baseURL.appendingPathComponent("get-courses")
        
        // Perform an asynchronous data request.
        let (data, response) = try await URLSession.shared.data(from: url)

        // Check for a successful HTTP status code.
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // Print the raw data as a string for debugging
        if let dataString = String(data: data, encoding: .utf8) {
            print("--- Raw Server Response ---")
            print(dataString)
            print("-------------------------")
        }

        do {
            // Decode the JSON data into our response model.
            let coursesResponse = try decoder.decode(CoursesResponse.self, from: data)
            return coursesResponse.courses
        } catch {
            // If decoding fails, print a detailed error message to help with debugging.
            if let decodingError = error as? DecodingError {
                print("--- JSON Decoding Error ---")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    print("Debug description: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found for type \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    print("Debug description: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    print("Debug description: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    print("Debug description: \(context.debugDescription)")
                @unknown default:
                    print("An unknown decoding error occurred: \(error.localizedDescription)")
                }
                print("---------------------------")
            }
            throw NetworkError.decodingFailed(error)
        }
    }
} 