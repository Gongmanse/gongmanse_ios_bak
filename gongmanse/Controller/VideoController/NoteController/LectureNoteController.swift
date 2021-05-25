//
//  LectureNoteController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/25.
//

import UIKit
import Alamofire

/// 05.25 이후 노트 컨트롤러
class LectureNoteController: UIViewController {
    
    // MARK: - Properties
    
    let id: String?
    let token: String?
    
    // 노트 이미지 인스턴스
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageView01: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    var noteImageArr = [UIImage(), UIImage(), UIImage(), UIImage(), UIImage(), UIImage()]
    var noteImageCount = 0
    var url: String?
    var receivedNoteImage: UIImage?

    
    // 노트 필기 인스턴스
    let canvas = Canvas()
    
    // TODO: 여러장의 노트이미지를 한장의 이미지로 합친다.
    // TODO: 스크롤 뷰를 통해 노트를 스크롤 할 수 있도록 구현한다.
    // TODO: Canvas 생성한다.
    
    
    
    // MARK: - Lifecycle
    
    init(id: String, token: String) {
        
        self.id = id
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupData()
        setupLayout()
    }
    
    
    // MARK: - Actions
    
    
    
    // MARK: - Heleprs
    
    func setupData() {
        
        guard let id = self.id else { return }
        guard let token = self.token else { return }
        
        let dataForSearchNote = NoteInput(video_id: id,
                                          token: token)
        DetailNoteDataManager().DetailNoteDataManager(dataForSearchNote,
                                                      viewController: self)
    }
    
    func setupLayout() {
        
        setupScrollView()
        setupViews()
    }
    
    func setupScrollView() {
        
        view.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    func setupViews() {
        
        // TODO: 이 위치에 API에서 받아온 이미지를 UIImage로 변형하여 변수에 할당한다.
        var image01 = #imageLiteral(resourceName: "manual_6")
        var image02 = #imageLiteral(resourceName: "manual_7")
        var image03 = #imageLiteral(resourceName: "splash")
        var image04 = #imageLiteral(resourceName: "manual_4")
        
        // 이미지의 크기를 줄인다.
        resize(image: image01, scale: 0.2) { image in
            image01 = image!
        }
        
        resize(image: image02, scale: 0.2) { image in
            image02 = image!
        }
        
        resize(image: image03, scale: 0.2) { image in
            image03 = image!
        }
        
        resize(image: image04, scale: 0.2) { image in
            image04 = image!
        }
        
        // 여러 이미지를 하나의 UIImage로 변환한다. (UIViewController - Extension에 구헌)
        let convertedImage = mergeVerticallyImagesIntoImage(images: image01, image02, image03, image04)
        
        // 배경이 될 imageView를 쌓는다.
        imageView01.image = convertedImage
        imageView01.contentMode = .scaleAspectFit
        contentView.addSubview(imageView01)
        imageView01.anchor(top: contentView.topAnchor,
                           left: contentView.leftAnchor,
                           bottom: contentView.bottomAnchor,
                           right: contentView.rightAnchor)
        
        // 필기기능을 적용할 View(canvas)를 쌓는다. -> 최상위에 쌓여있는 상태
        contentView.addSubview(canvas)
        canvas.backgroundColor = .clear
        canvas.anchor(top: contentView.topAnchor,
                           left: contentView.leftAnchor,
                           bottom: contentView.bottomAnchor,
                           right: contentView.rightAnchor)
        scrollView.isScrollEnabled = true
        canvas.alpha = 0 // 테스트를 위해 알파 값을 0 으로 지정 05.25 10:55
    }
}


extension UIViewController {
    
    func mergeVerticallyImagesIntoImage(images: UIImage...) -> UIImage? {
        
        // 고차함수 "map" 을 활용한 각 이미지들의 높이와 너비 값을 더한다.
        let maxWidth = images.reduce(0.0) { max($0, $1.size.width) }
        let totalHeight = images.reduce(0.0) { $0 + $1.size.height }
        
        // "UIGraphicsBegininImageContextWithOptions" 메소드를 통해 bitmap image context를 생성한다.
        // 크기는 파라미터로 전달해주고, 투명도는 false 그리고 scale은 0.0 으로 화면에 맞게 이미지를 결정한다.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: totalHeight), false, 0.0)
        defer {
            // defer 구문을 통해 "mergeVertically" 함수를 빠져나가기 전에 반드시 "UIGraphicsEndImageContext"를 실행시킨다.
            UIGraphicsEndImageContext()
        }
        
        // 여기까지 진행되었다면, 이미지를 그린 상태이다.
        
        // 초기 값으로 "CGFloat(0.0)"을 파라미터로 전달한다.
        let _ = images.reduce(CGFloat(0.0)) {
            // 그리고 클로져로 시작위치는 0.0과 첫 번째 값의 y위치로 설정하고 크기는 이미지의 크기를 모두 합친 사이즈로 결정한다.
            $1.draw(in: CGRect(origin: CGPoint(x: 0.0, y: $0), size: $1.size))
            
            // 계산한 높이 값을 리턴한다.
            return $0 + $1.size.height
        }
        
        // 그래픽컨텍스트를 만들었다면, 이것을 UIImage로 반환해주는 메소드를 호출합니다. 이 메소드통해 UIImage를 리턴할 수 있습니다.
        // (비트맵 기반 그래픽 컨텍스트) -> UIImage
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// UIKit에서 이미지 리사이징
    /// 원본: UIImage, 결과: UIImages
    func resize(image: UIImage, scale: CGFloat, completionHandler: ((UIImage?) -> Void)) {
        
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let size = image.size.applying(transform)
        
        UIGraphicsBeginImageContext(size)
        
        image.draw(in: CGRect(origin: .zero, size: size))
        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        
        completionHandler(resultImage)
    }
}


// MARK: - API

extension LectureNoteController {
    
    func didSucceedReceiveNoteData(responseData: NoteResponse) {
        
        guard let data = responseData.data else { return }
        self.noteImageCount = data.sNotes.count
        
        for noteData in 0 ... (self.noteImageCount-1) {
            let convertedURL = makeStringKoreanEncoded("\(fileBaseURL)/" + "\(data.sNotes[noteData])")
            getImageFromURL(url: convertedURL, index: noteData)
        }
    }
    
    func getImageFromURL(url: String, index: Int) {
        
        var resultImage = UIImage()
        
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                print("DEBUG: data \(data!)")
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    resultImage = UIImage(data: data)!
                    self.noteImageArr.append(resultImage)
                    self.noteImageArr[index] = resultImage
                }
            }
            task.resume()
        }
    }
}
