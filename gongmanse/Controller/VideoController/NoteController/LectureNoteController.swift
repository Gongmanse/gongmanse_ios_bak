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
    // Dummydata - 인덱스로 접근하기 위해 미리 배열 요소 생성
    var noteImageArr = [UIImage(), UIImage(), UIImage(),
                        UIImage(), UIImage(), UIImage(), UIImage()]
    var noteImageCount = 0
    var url: String?
    var receivedNoteImage: UIImage?
    
    // 노트필기 객체
    let canvas = Canvas()
    
    public let noteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let writingImplement: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainOrange
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()
    
    private let touchPositionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let redButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    let greenButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .green
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()

    let blueButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    let writingImplementToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left.2")
        button.setImage(image, for: .normal)
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()
    
    // UI
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let imageView01: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private var testImageView = UIImageView()

    
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
    
    @objc fileprivate func handleUndo() {
        canvas.undo()
    }
    
    @objc fileprivate func handleClear() {
        canvas.clear()
    }
    
    @objc fileprivate func handleColorChange(button: UIButton) {
        canvas.setStrokeColor(color: button.backgroundColor ?? .black)
    }
        
    @objc fileprivate func toggleSketchMode() {
        scrollView.isScrollEnabled.toggle()
    }
    
    @objc fileprivate func openWritingImplement() {
        scrollView.isScrollEnabled.toggle()
    }
    
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
        setupWritingImplement()
    }
    
    func setupScrollView() {
        
        view.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerX(inView: view)
        scrollView.anchor(top: view.topAnchor,
                          bottom: view.bottomAnchor,
                          width: view.frame.width)
        
        contentView.centerX(inView: view)
        contentView.anchor(top: scrollView.topAnchor,
                           bottom: scrollView.bottomAnchor)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.backgroundColor = .white
        
        // 배경이 될 imageView를 쌓는다.
        imageView01.contentMode = .topLeft
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
    }
    
    func setupViews() {
        
        // 이미지를 UIImage에 할당한다.
        var image01 = noteImageArr[0]
        var image02 = noteImageArr[1]
        var image03 = noteImageArr[2]
        var image04 = noteImageArr[3]
        var image05 = noteImageArr[4]
        var image06 = noteImageArr[5]
        var image07 = noteImageArr[6]

        // 이미지의 크기를 줄인다.
        let scale = CGFloat(0.45)
        resize(image: image01, scale: scale) { image in
            image01 = image!
        }
        
        resize(image: image02, scale: scale) { image in
            image02 = image!
        }
        
        resize(image: image03, scale: scale) { image in
            image03 = image!
        }
        
        resize(image: image04, scale: scale) { image in
            image04 = image!
        }
        
        resize(image: image05, scale: scale) { image in
            image05 = image!
        }
        
        resize(image: image06, scale: scale) { image in
            image06 = image!
        }
        
        resize(image: image07, scale: scale) { image in
            image07 = image!
        }
  
        // 여러 이미지를 하나의 UIImage로 변환한다.
        let convertedImage = mergeVerticallyImagesIntoImage(images:
                                                            image01,
                                                            image02,
                                                            image03,
                                                            image04,
                                                            image05,
                                                            image06,
                                                            image07)
        imageView01.image = convertedImage
    }
    
    func setupWritingImplement() {
        
        let width = view.frame.width * 0.5
        writingImplement.alpha = 1
        view.addSubview(writingImplement)
        writingImplement.frame = CGRect(x: 0,
                                        y: 250,
                                        width: width,
                                        height: 50)
        
        let colorStackView = UIStackView(arrangedSubviews: [
            redButton,
            greenButton,
            blueButton,
            clearButton,
            writingImplementToggleButton
        ])
        
        colorStackView.spacing = 4
        colorStackView.distribution = .fillEqually
        writingImplement.addSubview(colorStackView)
        colorStackView.centerY(inView: writingImplement)
        colorStackView.anchor(left: writingImplement.leftAnchor,
                              bottom: writingImplement.bottomAnchor,
                              paddingLeft: 15,
                              width: width - 15,
                              height: 59)
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
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async {
                    resultImage = UIImage(data: data)!
                    self.noteImageArr[index] = resultImage
                    self.setupViews()
                }
            }
            task.resume()
        }
    }
}
