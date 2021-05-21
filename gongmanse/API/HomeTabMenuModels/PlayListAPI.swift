import Foundation

struct PlayListModels: Codable {
    var isMore: Bool
    var totalNum: String
    var seriesInfo: PlayListInfo
    var data: [PlayListData]
}

struct PlayListInfo: Codable {
    var sTitle: String
    var sTeacher: String
    var sSubjectColor: String
    var sSubject: String
    var sGrade: String
}

struct PlayListData: Codable {
    var id: String
    var sTitle: String
    var dtDateCreated: String
    var dtLastModified: String
    var sSubject: String
    var sTeacher: String
    var sSubjectColor: String
    var sThumbnail: String
    var sUnit: String
}
