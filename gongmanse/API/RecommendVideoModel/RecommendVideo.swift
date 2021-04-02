import Foundation

//배너 이미지
struct RecommendVideoInput: Codable {
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
        var sThumbnail: String
        var sSubjectColor: String
        var sSubject: String
        var sUnit: String
    }
    
    let totalNum: String
    let data: [RecommendVideo]
    
    var sTitleName: String {
        return self.data[0].sTitle
    }
    
    var sTeacherName: String {
        return self.data[8].sTeacher
    }
    
    var sSubjectName: String {
        return self.data[11].sSubject
    }
    
    var iRatingCount: String {
        return self.data[7].iRating
    }
    
    var sThumbnailUrl: String {
        return self.data[9].sThumbnail
    }
    
    enum CodingKeys: String, CodingKey {
        case totalNum
        case data
    }
}
