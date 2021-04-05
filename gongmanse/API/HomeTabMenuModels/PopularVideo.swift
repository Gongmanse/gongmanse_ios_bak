import Foundation

struct PopularVideoInput: Codable {
    let totalNum: String
    let data: [PopularVideoData]
}

struct PopularVideoData: Codable {
    var sTitle: String
    var id: String
    var sTags: String
    var sFilename: String
    var dtDateCreated: String
    var dtLastModified: String
    var iRating: String
    var sTeacher: String
    var sThumbnail: String
    var sSubjectColor: String
    var sSubject: String
    var sUnit: String
}
