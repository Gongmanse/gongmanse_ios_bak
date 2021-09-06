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
    var id: String
    var iSeriesId: String?
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
    
    var simpleDt: String {
        let dateGet = DateFormatter()
        dateGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let beforeDate = dateGet.date(from: dtRegister ?? "")
        if beforeDate == nil {
            return ""
        }
        let elapsed: Int64 = Int64(Date().timeIntervalSince(beforeDate!))
        if elapsed < 60 {
            return "\(elapsed)초 전"
        } else if elapsed < 60 * 60 {
            return "\(elapsed / 60)분 전"
        } else if elapsed < 60 * 60 * 24 {
            return "\(elapsed / 3600)시간 전"
        } else if elapsed < 60 * 60 * 24 * 7 {
            return "\(elapsed / 86400)일 전"
        } else if elapsed < 60 * 60 * 24 * 7 * 4 {
            return "\(elapsed / 604800)주 전"
        } else if elapsed < 60 * 60 * 24 * 7 * 4 * 12 {
            return "\(elapsed / 2419200)개월 전"
        } else {
            return "\(elapsed / 29030400)년 전"
        }
    }
}

