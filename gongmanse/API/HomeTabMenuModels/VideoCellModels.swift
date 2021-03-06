import Foundation

//추천 베너 이미지
struct RecommendBannerImage: Codable {
    var header: RecomendBannerHeader?
    var body: [RecommendBannerImageData]
}

struct RecomendBannerHeader: Codable {
    var resultMsg: String?
    var totalRows: String?
}

struct RecommendBannerImageData: Codable{
    var videoId: String?
    var title: String?
    var thumbnail: String?
}

//추천 동영상
struct VideoInput: Codable {
    var header: HeaderData?
    var body: [VideoModels]
}

struct HeaderData: Codable {
    var resultMsg: String?
    var totalRows: String?
    var isMore: String?
}

struct VideoModels: Codable {
    var seriesId: String?
    var videoId: String?
    var title: String?
    var tags: String?
    var teacherName: String?
    var thumbnail: String?
    var subject: String?
    var subjectColor: String?
    var unit: String?
    var rating: String?
    var isRecommended: String?
    var registrationDate: String?
    var modifiedDate: String?
    var totalRows: String?
}

struct FilterVideoModels: Codable {
    var isMore: Bool?
    var totalNum: String?
    var data: [FilterVideoData]
}

struct FilterVideoData: Codable {
    var id: String?
    var iSeriesId: String?
    var iBookmarkId: String?
    var dtRegister: String?
    var user_id: String?
    var video_id: String?
    var iActive: String?
    var iCommentary: String?
    var sTitle: String?
    var sTags: String?
    var sFilename: String?
    var dtTimestamp: String?
    var dtDateCreated: String?
    var dtLastModified: String?
    var dtLastUpdated: String?
    var iRating: String?
    var sSubject: String?
    var sTeacher: String?
    var sSubjectColor: String?
    var sThumbnail: String?
    var sUnit: String?
    var iAnswer: String?
    var sQuestion: String?
    var iQnaId: String?
}

//시리즈 보기
struct SeriesModels: Codable {
    var isMore: Bool
    var totalNum: String
    var seriesInfo: SeriesMainInfo
    var data: [SeriesData]
    
    struct SeriesMainInfo: Codable {
        var sTitle: String
        var sTeacher: String
        var sSubjectColor: String
        var sSubject: String
        var sGrade: String
    }
}

struct SeriesData: Codable {
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

