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
    var counselId: String?
    var userId: String?
    var view: String?
    var question: String?
    var nickname: String?
    var profile: String?
    var answer: String?
    var answerComplete: String?
    var answerRegisterDate: String?
    var registerDate: String?
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
