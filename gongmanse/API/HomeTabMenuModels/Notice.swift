import Foundation

struct NoticeModels: Codable {
    var data: [NoticeData]
}

struct NoticeData: Codable {
    var id: String?
    var eType: String?
    var sTitle: String?
    var sBody: String?
    var sUri: String?
    var sData: String?
    var sPriority: String?
    var dtDateCreated: String?
}
