import Foundation

//베너 이미지
struct RecommendBannerImage: Codable {
    let data: [RecommendBannerImageData]
}

struct RecommendBannerImageData: Codable{
    var sThumbnail: String
}

//추천 동영상
struct RecommendVideoInput: Codable {
    let totalNum: String
    var data: [RecommendVideo]
}

struct RecommendVideo: Codable {
    var sTitle: String
    var id: String
    var sTags: String
    var sFilename: String
    var cRecommended: String
    var dtDateCreated: String
    var dtLastModified: String
    var iRating: String
    var sTeacher: String
    var sThumbnail: String
    var sSubjectColor: String
    var sSubject: String
    var sUnit: String
}
