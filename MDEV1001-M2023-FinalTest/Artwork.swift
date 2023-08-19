import Foundation

struct Artwork: Codable {
    var id: Int
    var documentID: String?
    var title: String
    var artists: String
    var medium: String
    var subjects: [String]
    var yearCreated: String
    var description: String
    var dimensions: String?
    var imageURL: String
    var style: String
    var currentLocation: String
}

