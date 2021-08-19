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

struct ExpertConsultImageData: Codable {
    var data: [String]
}
