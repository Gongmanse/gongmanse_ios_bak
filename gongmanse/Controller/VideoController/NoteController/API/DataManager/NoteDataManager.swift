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
    
    func savingNoteTakingAPI(_ inputData: NoteTakingInput, viewController: DetailNoteController) {
        
        let url = "https://api.gongmanse.com/v/video/detail_notes"
        
        let param: Parameters =
            [
            "token"     : inputData.token,
            "video_id"  : inputData.video_id,
            "sjson"     : inputData.sjson
            ]
        
        AF.request(url,
                   method: .patch,
                   parameters: param,
                   encoding: URLEncoding.httpBody,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
            
            .responseData { response in
                switch response.result {
                case .success(let result):
                    print("DEBUG: 노트필기 API 성공")
                    print("DEBUG: 성공결과: \(result)")
                    
                case .failure(let error):
                    print("DEBUG: 노트필기 API 실패")
                    print("DEBUG: 실패이유: \(error.localizedDescription)")
                    print("DEBUG: 실패이유: \(String(describing: error.errorDescription))")
                }
            }
    }
    
    func DetailNoteDataManager(_ parameters: NoteInput, viewController: LectureNoteController) {
        
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
    
    func savingNoteTakingAPI(_ inputData: NoteTakingInput, viewController: LectureNoteController) {
        
        let url = "https://api.gongmanse.com/v/video/detail_notes"
        
        let param: Parameters =
            [
            "token"     : inputData.token,
            "video_id"  : inputData.video_id,
            "sjson"     : inputData.sjson
            ]
        
        AF.request(url,
                   method: .patch,
                   parameters: param,
                   encoding: URLEncoding.httpBody,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
            
            .responseData { response in
                switch response.result {
                case .success(let result):
                    print("DEBUG: 노트필기 API 성공")
                    print("DEBUG: 성공결과: \(result)")
                    
                case .failure(let error):
                    print("DEBUG: 노트필기 API 실패")
                    print("DEBUG: 실패이유: \(error.localizedDescription)")
                    print("DEBUG: 실패이유: \(String(describing: error.errorDescription))")
                }
            }
    }
//
//    func patchNoteTaking(_ parameters: NoteTakingInput, viewController: DetailNoteController) {
//
//        let data = parameters
//
//        let renewalParameters: Parameters = [
////            "token": data.token,
////            "video_id": data.videoID,
//            "sjson": data.sjson
//        ]
//
//
////        var token: String
////        var videoID: Int
////        var sjson: [sJson]
////
//        let url = "https://api.gongmanse.com/v/video/detail_notes"
//
//        AF.request(url,
//                   method: .patch,
//                   parameters: renewalParameters,
//                   encoding: URLEncoding.httpBody,
//                   headers: nil)
//            .responseData { response in
//                print("DEBUG: response is \(response)")
//            }
//
//
//
//
////        AF.request(url, method: .patch, parameters: data)
////            .responseData { response in
////                switch response.result {
////                case .success(let response):
////                    print("DEBUG: response is \(response.debugDescription)")
////                    print("DEBUG: 노트필기 API 성공")
////                case .failure(let error):
////                    print("DEBUG: 노트필기 API 실패")
////                }
////            }
//    }
    
//    struct CustomPATCHEncoding: ParameterEncoding {
//        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//            let mutableRequest = try! URLEncoding().encode(urlRequest, with: parameters) as? NSMutableURLRequest
//
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
//                mutableRequest?.httpBody = jsonData
//            } catch {
//                print(error.localizedDescription)
//            }
//
//            return mutableRequest! as URLRequest
//        }
//    }
//
    
    //    func patch(completionHandler: @escaping (Result<[UserData], Error>) -> Void) {
    //        let userData = PostUserData(id: 1)
    //        self.request = AF.request("\(Config.baseURL)/posts/1", method: .patch, parameters: userData)
    //        self.request?.responseDecodable { (response: DataResponse<PatchUserData>) in
    //            switch response.result {
    //            case .success(let userData):
    //                completionHandler(.success([userData.toUserData()]))
    //            case .failure(let error):
    //                completionHandler(.failure(error))
    //            }
    //        }
    //    }
    
    
}


