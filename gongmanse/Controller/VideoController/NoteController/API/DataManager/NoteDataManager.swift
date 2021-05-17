//
//  DetailVideoDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/26.
//

import Foundation
import Alamofire

class DetailNoteDataManager {

    func DetailNoteDataManager(_ parameters: NoteInput, viewController: DetailNoteController) {

        let data = parameters
        
        let url = "https://api.gongmanse.com/v/video/detail_notes?video_id=\(data.video_id)&token=\(Constant.token)"
        
        AF.request(url)
            .responseDecodable(of: NoteResponse.self) { response in
                
                switch response.result {
                case .success(let response):
                    print("DEBUG: 노트 API 통신 성공")
                    viewController.didSucceedReceiveNoteData(responseData: response)
                    
                case .failure(let error):
                    print("DEBUG: 노트 API 통신 실패")
                    print("DEBUG: faild connection \(error.localizedDescription)")
                }
            }
    }
}


