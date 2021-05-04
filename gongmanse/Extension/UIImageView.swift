//
//  UIImageView.swift
//  gongmanse
//
//  Created by wallter on 2021/04/12.
//

import UIKit


// 이미지 캐싱 처리
extension UIImageView {
    func setImageUrl(_ url: String) {
        guard let convertUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            let cacheKey = NSString(string: convertUrl) // 캐시에 사용될 Key 값
            
            if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) { // 해당 Key 에 캐시이미지가 저장되어 있으면 이미지를 사용
                self.image = cachedImage
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                if let imageUrl = URL(string: convertUrl) {
                    URLSession.shared.dataTask(with: imageUrl) { (data, res, err) in
                        if let _ = err {
                            DispatchQueue.main.async {
                                self.image = UIImage()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            if let data = data, let image = UIImage(data: data) {
                                ImageCacheManager.shared.setObject(image, forKey: cacheKey) // 다운로드된 이미지를 캐시에 저장
                                self.image = image
                            }
                        }
                    }.resume()
                }
            }
        }
}
