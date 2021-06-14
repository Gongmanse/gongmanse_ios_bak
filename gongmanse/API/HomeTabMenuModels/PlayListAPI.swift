import Foundation

//국영수, 과학, 사회, 기타
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
    var iSeriesId: String
    var sTitle: String
    var dtDateCreated: String
    var dtLastModified: String
    var sSubject: String
    var sTeacher: String
    var sSubjectColor: String
    var sThumbnail: String
    var sUnit: String
}

//추천
struct BeforeApiModels: Codable {
    var totalNum: String
    var data: [BeforeApiData]
}

struct BeforeApiData: Codable {
    var sTitle: String
    var iSeriesId: String
    var id: String
    var sTags: String
    var sFilename: String
    var cRecommended: String?
    var dtDateCreated: String
    var dtLastModified: String
    var iRating: String
    var sTeacher: String
    var sThumbnail: String
    var sSubjectColor: String
    var sSubject: String
    var sUnit: String
}

struct LectureQnAModels: Codable {
    var totalNum: String?
    var data: [LectureQnAData]
}

struct LectureQnAData: Codable {
    var sQid: String?
    var sQuestion: String?
    var dtRegister: String?
    var sAnswer: String?
    var sNickname: String?
    var sTeacher: String?
    var sUserImg: String?
    var sTeacherImg: String?
}

