import Foundation
import UIKit
import Alamofire

/* Server API domain */
let apiBaseURL = "https://api.gongmanse.com"
let fileBaseURL = "https://file.gongmanse.com"
let webBaseURL = "https://webview.gongmanse.com"

// 21.10.20 settings Dev domain
//let apiBaseURL = "https://apidev.gongmanse.com"
//let fileBaseURL = "https://filedev.gongmanse.com"
//let webBaseURL = "https://webviewdev.gongmanse.com"

let BannerList_URL = apiBaseURL + "/v3/video/banner"
let Recommend_Video_URL = apiBaseURL + "/v3/video/recommend"
let Popular_Video_URL = apiBaseURL + "/v3/video/trending"
let KoreanEnglishMath_Video_URL = apiBaseURL + "/v3/video/subject/34?"
let Science_Video_URL = apiBaseURL + "/v3/video/subject/36?"
let SocialStudies_Video_URL = apiBaseURL + "/v3/video/subject/35?"
let OtherSubjects_Video_URL = apiBaseURL + "/v3/video/subject/37?"
let ExpertConsultation_URL = apiBaseURL + "/v/consultation/conlist?"


