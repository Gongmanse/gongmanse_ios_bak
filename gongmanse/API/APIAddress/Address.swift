import Foundation
import UIKit
import Alamofire

let apiBaseURL = "https://api.gongmanse.com"
let fileBaseURL = "https://file.gongmanse.com"
let BannerList_URL = apiBaseURL + "/v/video/bannervid"
let Recommend_Video_URL = apiBaseURL + "/v/video/recommendvid"
let Popular_Video_URL = apiBaseURL + "/v/video/trendingvid"
let KoreanEnglishMath_Video_URL = apiBaseURL + "/v/video/bycategory?category_id=34&offset=0&commentary=0&sort_id=3&limit=20"
let Science_Video_URL = apiBaseURL + "/v/video/bycategory?category_id=36&offset=0&commentary=0&sort_id=3&limit=20"
let SocialStudies_Video_URL = apiBaseURL + "/v/video/bycategory?category_id=35&offset=0&commentary=0&sort_id=3&limit=20"
let OtherSubjects_Video_URL = apiBaseURL + "/v/video/bycategory?category_id=37&offset=0&commentary=0&sort_id=3&limit=20"

