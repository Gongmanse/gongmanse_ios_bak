//
//  DetailVideoViewModel.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/26.
//

import Foundation
import Alamofire
import UIKit

class DetailVideoViewModel {
    
    // Input
    var video_id: String?
    var token = Constant.token
    
    public init(video_id: String?, token: String) {
        self.video_id = video_id
        self.token = token
    }


}
