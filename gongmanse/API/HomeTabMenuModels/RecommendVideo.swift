import Foundation

//베너 이미지
struct RecommendBannerImage: Codable {
    var header: RecomendBannerHeader
    var body: [RecommendBannerImageData]
}

struct RecomendBannerHeader: Codable {
    var resultMsg: String
    var totalRows: String
}

struct RecommendBannerImageData: Codable{
    var videoId: String
    var title: String
    var thumbnail: String
}

//추천 동영상
struct RecommendVideoInput: Codable {
    var header: RecommendHeaderData
    var body: [RecommendVideo]
}

struct RecommendHeaderData: Codable {
    var resultMsg: String
    var totalRows: String
    var isMore: String
}

struct RecommendVideo: Codable {
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
