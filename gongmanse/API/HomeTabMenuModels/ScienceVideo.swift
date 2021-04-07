import Foundation

struct ScienceVideoInput: Codable {
    let isMore: Bool
    let totalNum: String
    let data: [ScienceVideoData]
}

struct ScienceVideoData: Codable {
    var id: String
    var iActive: String
    var iCommentary: String
    var sTitle: String
    var sTags: String
    var sFilename: String
    var dtDateCreated: String
    var dtLastModified: String
    var iRating: String
    var sSubject: String
    var sTeacher: String
    var sSubjectColor: String
    var sThumbnail: String
    var sUnit: String
}
