import Foundation

// MARK: - API Response Wrapper
struct CoursesResponse: Codable {
    let success: Bool
    let courses: [Course]
}

// MARK: - Main Course Model
struct Course: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let categories: [String]
    let price: Int
    let estimatedPrice: Int?
    let tags: String
    let level: String
    let demoUrl: String?
    let benefits: [Benefit]
    let prerequisites: [Prerequisite]
    let courseData: [CourseData]
    let ratings: Double?
    let purchased: Int?
    let reviews: [Review]
    let isFree: Bool?
    let lessons: [[String]]?
    let thumbnail: Thumbnail
    let status: String?
    let views: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id", name, description, categories, price, estimatedPrice, tags, level, demoUrl, benefits, prerequisites, courseData, ratings, purchased, reviews, isFree, lessons = "Lessons", thumbnail, status, views = "Views"
    }
}

// MARK: - Supporting Models
struct Benefit: Codable, Identifiable {
    let id: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", title
    }
}

struct Prerequisite: Codable, Identifiable {
    let id: String
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", title
    }
}

struct Thumbnail: Codable { let public_id: String; let url: String }
struct Avatar: Codable { let public_id: String?; let url: String? }

struct Review: Codable, Identifiable {
    let id: String
    let user: User
    let rating: Int
    let comment: String?
    let commentReplies: [ReviewReply]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", user, rating, comment, commentReplies
    }
}

struct ReviewReply: Codable, Identifiable {
    let id: String
    let user: User
    let comment: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case user, comment, createdAt, updatedAt
    }
}

struct CourseData: Codable, Identifiable {
    let id: String, title: String, description: String, videoSection: String
    let videoUrl: String?, videoLength: Int, links: [Link]?, questions: [Question]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", title, description, videoSection, videoUrl, videoLength, links, questions
    }
}

struct Link: Codable, Identifiable {
    let id: String, title: String, url: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", title, url
    }
}

struct Question: Codable, Identifiable {
    let id: String, user: User, question: String, questionReplies: [QuestionReply]
    let createdAt: Date, updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", user, question, questionReplies, createdAt, updatedAt
    }
}

struct QuestionReply: Codable, Identifiable {
    let id: String
    let user: User
    let comment: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case user, answer, comment, createdAt, updatedAt
    }
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let avatar: Avatar?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", name, avatar
    }
}

// MARK: - Custom Decoders for MongoDB Extended JSON
extension KeyedDecodingContainer {
    
    // Decodes either a plain string or MongoDB extended JSON format
    func decodeId(forKey key: K) throws -> String {
        // Try plain string first (your API format)
        if let plainString = try? self.decode(String.self, forKey: key) {
            return plainString
        }
        
        // Fallback to MongoDB extended JSON format
        let nested = try self.nestedContainer(keyedBy: MongoCodingKeys.self, forKey: key)
        return try nested.decode(String.self, forKey: .oid)
    }

    // Decodes either a plain int or MongoDB extended JSON format
    func decodeFlexibleInt(forKey key: K) throws -> Int {
        // Try plain int first
        if let plainInt = try? self.decode(Int.self, forKey: key) {
            return plainInt
        }
        
        // Fallback to MongoDB extended JSON format
        let nested = try self.nestedContainer(keyedBy: MongoCodingKeys.self, forKey: key)
        let stringValue = try nested.decode(String.self, forKey: .numberInt)
        return Int(stringValue) ?? 0
    }
    
    func decodeFlexibleIntIfPresent(forKey key: K) throws -> Int? {
        guard self.contains(key), !(try self.decodeNil(forKey: key)) else { return nil }
        
        // Try plain int first
        if let plainInt = try? self.decode(Int.self, forKey: key) {
            return plainInt
        }
        
        // Fallback to MongoDB extended JSON format
        do {
            let nested = try self.nestedContainer(keyedBy: MongoCodingKeys.self, forKey: key)
            let stringValue = try nested.decode(String.self, forKey: .numberInt)
            return Int(stringValue)
        } catch {
            return nil
        }
    }

    // Decodes either a plain double or MongoDB extended JSON format
    func decodeFlexibleDoubleIfPresent(forKey key: K) throws -> Double? {
        guard self.contains(key), !(try self.decodeNil(forKey: key)) else { return nil }
        
        // Try plain double first
        if let plainDouble = try? self.decode(Double.self, forKey: key) {
            return plainDouble
        }
        
        // Fallback to MongoDB extended JSON format
        do {
            let nested = try self.nestedContainer(keyedBy: MongoCodingKeys.self, forKey: key)
            let stringValue = try nested.decode(String.self, forKey: .numberDouble)
            return Double(stringValue)
        } catch {
            return nil
        }
    }
    
    // Decodes either a Bool or a String that represents a Bool
    func decodeFlexibleBoolIfPresent(forKey key: K) throws -> Bool? {
        guard self.contains(key), !(try self.decodeNil(forKey: key)) else { return nil }
        
        // Try to decode as Bool first
        if let boolValue = try? self.decode(Bool.self, forKey: key) {
            return boolValue
        }
        
        // If that fails, try to decode as String and convert
        if let stringValue = try? self.decode(String.self, forKey: key) {
            return (stringValue as NSString).boolValue
        }
        
        return nil
    }

    // Decodes a Date from either `{"$date": {"$numberLong": "..."}}` or ISO string
    func decodeFlexibleDate(forKey key: K) throws -> Date {
        // Try MongoDB extended JSON format first
        if let nested = try? self.nestedContainer(keyedBy: MongoCodingKeys.self, forKey: key) {
            let dateContainer = try nested.nestedContainer(keyedBy: MongoCodingKeys.self, forKey: .date)
            let longString = try dateContainer.decode(String.self, forKey: .numberLong)
            let ms = Double(longString) ?? 0
            return Date(timeIntervalSince1970: ms / 1000)
        }
        
        // Fallback to ISO string format
        let dateString = try self.decode(String.self, forKey: key)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }
        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Invalid date format")
    }
}

enum MongoCodingKeys: String, CodingKey {
    case oid = "$oid", date = "$date", numberLong = "$numberLong", numberInt = "$numberInt", numberDouble = "$numberDouble"
}

// Custom initializers for each model that needs special handling.
extension Course {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeId(forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        categories = try container.decode([String].self, forKey: .categories)
        price = try container.decodeFlexibleInt(forKey: .price)
        estimatedPrice = try container.decodeFlexibleIntIfPresent(forKey: .estimatedPrice)
        tags = try container.decode(String.self, forKey: .tags)
        level = try container.decode(String.self, forKey: .level)
        demoUrl = try container.decodeIfPresent(String.self, forKey: .demoUrl)
        benefits = try container.decode([Benefit].self, forKey: .benefits)
        prerequisites = try container.decode([Prerequisite].self, forKey: .prerequisites)
        courseData = try container.decode([CourseData].self, forKey: .courseData)
        ratings = try container.decodeFlexibleDoubleIfPresent(forKey: .ratings)
        purchased = try container.decodeFlexibleIntIfPresent(forKey: .purchased)
        reviews = try container.decode([Review].self, forKey: .reviews)
        isFree = try container.decodeFlexibleBoolIfPresent(forKey: .isFree)
        lessons = try container.decodeIfPresent([[String]].self, forKey: .lessons)
        thumbnail = try container.decode(Thumbnail.self, forKey: .thumbnail)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        views = try container.decodeIfPresent(String.self, forKey: .views)
    }
}

extension Benefit {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeId(forKey: .id)
        title = try container.decode(String.self, forKey: .title)
    }
}

extension Prerequisite {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeId(forKey: .id)
        title = try container.decode(String.self, forKey: .title)
    }
}

extension Review {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeId(forKey: .id)
        user = try container.decode(User.self, forKey: .user)
        rating = try container.decodeFlexibleInt(forKey: .rating)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        commentReplies = try container.decodeIfPresent([ReviewReply].self, forKey: .commentReplies)
    }
}

extension ReviewReply {
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Generate a unique ID since the server doesn't provide one
        id = UUID().uuidString
        user = try container.decode(User.self, forKey: .user)
        comment = try container.decode(String.self, forKey: .comment)
        createdAt = try container.decodeFlexibleDate(forKey: .createdAt)
        updatedAt = try container.decodeFlexibleDate(forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
        try container.encode(comment, forKey: .comment)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        // Note: We don't encode the generated ID since it's not part of the server model
    }
}

extension CourseData {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeId(forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        videoSection = try container.decode(String.self, forKey: .videoSection)
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        videoLength = try container.decodeFlexibleInt(forKey: .videoLength)
        links = try container.decodeIfPresent([Link].self, forKey: .links)
        questions = try container.decodeIfPresent([Question].self, forKey: .questions)
    }
}

extension Link {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeId(forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
    }
}

extension Question {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeId(forKey: .id)
        user = try container.decode(User.self, forKey: .user)
        question = try container.decode(String.self, forKey: .question)
        questionReplies = try container.decode([QuestionReply].self, forKey: .questionReplies)
        createdAt = try container.decodeFlexibleDate(forKey: .createdAt)
        updatedAt = try container.decodeFlexibleDate(forKey: .updatedAt)
    }
}

extension QuestionReply {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Generate a unique ID since question replies don't have _id
        id = UUID().uuidString
        user = try container.decode(User.self, forKey: .user)
        // Try "answer" first, then "comment" as fallback
        if let answer = try container.decodeIfPresent(String.self, forKey: .answer) {
            comment = answer
        } else {
            comment = try container.decode(String.self, forKey: .comment)
        }
        createdAt = try container.decodeFlexibleDate(forKey: .createdAt)
        updatedAt = try container.decodeFlexibleDate(forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
        try container.encode(comment, forKey: .answer) // Use "answer" for encoding
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        // Note: We don't encode the generated ID since it's not part of the server model
    }
}

extension User {
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        avatar = try container.decodeIfPresent(Avatar.self, forKey: .avatar)
        
        // User ID can be a plain string or a Mongo ID object. This handles both.
        id = try container.decodeId(forKey: .id)
    }
}
