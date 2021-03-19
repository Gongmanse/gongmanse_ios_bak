//
//  UIViewController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/12.
//

import UIKit

extension UIViewController {
    // MARK: UIWindow의 rootViewController를 변경하여 화면전환
    func changeRootViewController(_ viewControllerToPresent: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewControllerToPresent
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        } else {
            viewControllerToPresent.modalPresentationStyle = .overFullScreen
            self.present(viewControllerToPresent, animated: true, completion: nil)
        }
    }
    
    // MARK: 중복을 제거한 Array 생성 메소드
    func removeDuplicate (_ array: [String]) -> [String] {
        var removedArray = [String]()
        for i in array {
            if removedArray.contains(i) == false {
                removedArray.append(i)
            }
        }
        return removedArray
    }
    
    // MARK: - CustonTextField로 동일한 Textfield 구성 시, 공통사항
    
    func custonTextField(tf: UITextField, width: CGFloat, leftImage: UIImage, placehoder: String) {
        let idImage = leftImage.withTintColor(.mainOrange)
        tf.leftView = UIImageView(image: idImage)
        tf.leftViewMode = .always
        tf.borderStyle = .none
        tf.placeholder = "  \(placehoder)"
        tf.clearButtonMode = .whileEditing
        
        // Textfield 하단 Divider 추가
        let dividerView: UIView = {
            let view = UIView()
            view.backgroundColor = .mainOrange
            return view
        }()
        
        view.addSubview(dividerView)
        dividerView.anchor(top: tf.bottomAnchor, paddingTop: 1)
        dividerView.setDimensions(height: 1.2, width: width)
        dividerView.centerX(inView: view)
    }
    
}
