import Foundation

//전문가 상담
struct ExpertModels: Codable {
    var totalNum: String
    var data: [ExpertModelData]
}

struct ExpertModelData: Codable {
    var cu_id: String?
    var iAuthor: String?
    var iViews: String?
    var consultation_id: String?
    var dtAnswerRegister: String?
    var sQuestion: String?
    var sNickname: String?
    var sProfile: String?
    var sAnswer: String?
    var iAnswer: String?
    var dtRegister: String?
    var sFilepaths: String?
}

struct ExpertConsultImageData: Codable {
    var data: [String]
}
