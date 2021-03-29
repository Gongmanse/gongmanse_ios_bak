import Foundation

//배너 이미지
struct RecommendBannerImage: Codable {
    var sTitle: String
    var sTumbnail: String
    var id: String
}

//추천 동영상
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
    var sTumbnail: String
    var sSubjectColor: String
    var sSubject: String
    var sUnit: String
}
