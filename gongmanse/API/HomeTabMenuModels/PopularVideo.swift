import Foundation

struct PopularVideoInput: Codable {
    var header: PopularVideoHeaderData
    var body: [PopularVideoData]
}

struct PopularVideoHeaderData: Codable {
    var resultMsg: String
    var totalRows: String
    var isMore: String
}

struct PopularVideoData: Codable {
    var videoId: String
    var title: String
    var tags: String
    var teacherName: String
    var thumbnail: String
    var subject: String
    var subjectColor: String
    var unit: String?
    var rating: String
    var isRecommended: String
    var registrationDate: String
    var modifiedDate: String
}
