import Foundation

struct KoreanEnglishVideoInput: Codable {
    var header: KoreanEnglishVideoHeaderData
    var body: [KoreanEnglishVideoData]
}

struct KoreanEnglishVideoHeaderData: Codable {
    var resultMsg: String
    var totalRows: String
    var isMore: String
}

struct KoreanEnglishVideoData: Codable {
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
