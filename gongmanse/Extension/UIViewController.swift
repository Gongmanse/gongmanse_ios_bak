//
//  UIViewController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/12.
//

import UIKit

extension UIViewController {
    // MARK: UIWindow의 rootViewController를 변경하여 화면전환
    func changeRootViewController(_ viewControllerToPresent: UIViewController, completion: @escaping () -> Void) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewControllerToPresent
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        } else {
            viewControllerToPresent.modalPresentationStyle = .overFullScreen
            self.present(viewControllerToPresent, animated: true, completion: nil)
        }
        completion()
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
    
    
    
    static func instantiateFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Can't instantiate \(self) from storyboard")
        }
        return viewController
    }
    
    // UITextField LeftView 추가 메소드
    func settingLeftViewInTextField(_ textField: UITextField,
                                           _ image: UIImage,
                                           y: Int = 10) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 0, y: y, width: 20, height: 20))
        imageView.image = image
        view.addSubview(imageView)
        return view
    }
    
    // textField 공통 세팅 커스텀메소드
    func setupTextField(_ tf: UITextField, placehoder: String, leftView: UIView) {
        tf.font = UIFont.appBoldFontWith(size: 14)
        tf.placeholder = placehoder
        tf.leftViewMode = .always
        tf.tintColor = .progressBackgroundColor
        tf.leftView = leftView
        tf.keyboardType = .emailAddress
    }
    
    // textField leftView 추가를 위한 view 내부에 ImageView 추가 커스텀메소드
    func addLeftView(image: UIImage) -> UIView {
        let leftView = UIView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        let leftImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        leftImageView.image = image
        leftView.addSubview(leftImageView)
        self.view.addSubview(leftView)
        return leftView
    }
    
    // 임시저장.
    func customTextField(placeholder: String, leftImage: UIImage) -> SloyTextField {
        let tf = SloyTextField()
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let leftImageView = UIImageView(image: leftImage)
        leftImageView.tintColor = .gray
        leftImageView.frame = CGRect(x: 0, y: 25, width: 20, height: 20)
        leftView.addSubview(leftImageView)
        tf.placeholder = placeholder
        tf.leftView = leftView
        tf.leftViewMode = .always
        return tf
    }
    
    
    // String 중에서 Int(1자리) 만 추출하는 메소드
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    } // 결과예시 ) ["1", "2", "3", "4"]
    
    /// 반복문을 통한 거듭제곱 메소드
    func power_for(x: Double, n: Int) -> Double {
        if n == 0 { return 1 } // 종료
        else {
            var result: Double = 1
            for _ in 1...n { result = result * x }
            return result
        }
    }
    
    /// 한글 인코딩 처리 메소드
    func makeStringKoreanEncoded(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
    
    /// 제플린 높이를 입력하면 비율에 맞게 높이을 리턴
    func convertHeight(_ zeplinHeight: CGFloat, standardView: UIView) -> CGFloat {
        return CGFloat((standardView.frame.height * zeplinHeight) / 640)
    }
    
    /// 제플린 넓이를 입력하면 비율에 맞게 넓이을 리턴
    func convertWidth(_ zeplinWidth: CGFloat, standardView: UIView) -> CGFloat {
        return CGFloat((standardView.frame.width * zeplinWidth) / 360)
    }
    
    /// 커스텀 경고창
    /// - 잠시 생겼다가 사라지는 경고창
    func presentAlert(message: String) {
        
        let alertSuperView = UIView()
        alertSuperView.backgroundColor
            = UIColor.black.withAlphaComponent(0.77)
        alertSuperView.layer.cornerRadius = 17
        alertSuperView.isHidden = true
        
        let alertLabel = UILabel()
        alertLabel.font = UIFont.appBoldFontWith(size: 12)
        alertLabel.textColor = .white
        
        self.view.addSubview(alertSuperView)
        alertSuperView.centerX(inView: self.view)
        alertSuperView.anchor(bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
                              paddingBottom: 50,
                              width: self.view.frame.width * 0.89,
                              height: 37)
        
        alertSuperView.addSubview(alertLabel)
        alertLabel.centerY(inView: alertSuperView)
        alertLabel.centerX(inView: alertSuperView)
        alertLabel.setDimensions(height: 37,
                                 width: self.view.frame.width * 0.83)
        alertLabel.textAlignment = .center
        alertLabel.numberOfLines = 0
        
        alertLabel.text = message
        alertSuperView.alpha = 1.0
        alertSuperView.isHidden = false
        UIView.animate(withDuration: 2.0,
                       delay: 1.0,
                       options: .curveEaseIn,
                       animations: { alertSuperView.alpha = 0 },
                       completion: { _ in
                        alertSuperView.removeFromSuperview()
                       })
    }
    
    /// View의 하단에 경계선을 추가하는 메소드
    func addBottomLine(superView: UIView, height: CGFloat) {
        
        let line = UIView()
        superView.addSubview(line)
        line.backgroundColor = .progressBackgroundColor
        line.setDimensions(height: height,
                           width: superView.frame.width)
        line.anchor(bottom: superView.bottomAnchor)
    }
}
