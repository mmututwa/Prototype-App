import Foundation

/// Represents the possible errors that can occur during a network request.
enum NetworkError: Error, LocalizedError {
    /// The server's response was not a valid HTTP response or had a non-200 status code.
    case invalidResponse
    
    /// The data from the server could not be decoded into the expected type.
    case decodingFailed(Error)
    
    /// A general network error occurred.
    case networkFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed(let error):
            return "Failed to decode the server's response: \(error.localizedDescription)"
        case .networkFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        }
    }
} 