//
//  PlayerViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/10.
//

import Foundation

class PlayerViewModel {
    
    var videoURL = NSURL(string: "")
    var vttURL = ""
    var id = ""
    var playRate = Float(1.0)
    var currentPlayTime = 0
    var lessonTtitle = ""
    var categoryID = ""
    var rating = ""
    var userRating = ""
    var bookmark = false
    var highlight: String? = ""
    var subjectname = ""
    var subjectColor = ""
    var tags = [String]()
    var unit = ""
    
//    init(dataByAPI: DetailVideoResponse?) {
//        guard let response = dataByAPI  else { return }
//        videoURL = response.data.source_url ?? ""
//        vttURL = response.data.sSubtitle
//        id = response.data.id
//        lessonTtitle = response.data.sTitle
//        categoryID = response.data.iCategoryId
//        rating = response.data.iRating
//        userRating = response.data.iUserRating ?? "0"
//        bookmark = response.data.sBookmarks
//        highlight = response.data.sHighlight
//        subjectname = response.data.sSubject
//        subjectColor = response.data.sSubjectColor
//        tags = response.data.sTags
//        unit = response.data.sUnit
//    }
}
