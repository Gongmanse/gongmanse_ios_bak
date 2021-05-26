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
    
    private let id: String?
    private let token: String?
    private var url: String?
    private var pointString = ""
    
    // 노트 이미지 인스턴스
    // Dummydata - 인덱스로 접근하기 위해 미리 배열 요소 생성
    private var noteImageArr = [UIImage(), UIImage(), UIImage(),
                        UIImage(), UIImage(), UIImage(), UIImage()]
    private var noteImageCount = 0
    private var receivedNoteImage: UIImage?
    
    // 노트 객체
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView01: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // 노트필기 객체
    private let canvas = Canvas()
    
    private let savingNoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("노트\n저장", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 12)
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.rgb(red: 21, green: 176, blue: 172)
        button.addTarget(self, action: #selector(handleSavingNote), for: .touchUpInside)
        return button
    }()
    
    private let writingImplement: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainOrange.withAlphaComponent(0.88)
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()
    
    private let redButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .red
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let greenButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .green
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()

    private let blueButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        return button
    }()
    
    private let writingImplementToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left.2")
        button.setImage(image, for: .normal)
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()

    
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
        let noteMode = self.scrollView.isScrollEnabled
        scrollView.isScrollEnabled.toggle()

        // !noteMode -> 노트필기 가능한상태
        if !noteMode {
            UIView.animate(withDuration: 0.33) {
                self.writingImplement.frame.origin = CGPoint(x: -100,
                                                             y: 250)
            }
            
        } else {
            UIView.animate(withDuration: 0.33) {
                self.writingImplement.frame.origin = CGPoint(x: 0,
                                                             y: 250)
            }
        }
    }
    
    @objc fileprivate func handleSavingNote() {
        
        // canvas 객체로 부터 x,y 위치 정보를 받는다.
        canvas.saveNoteTakingData()
        
        
        // 이 클래스의 전역범위에 있는 데이터를 지역변수로 옮긴다.
        guard let token = self.token else { return }
        guard let id = self.id else { return }
        let intID = Int(id)!    // 21.05.26 영상 상세정보 API에서 String으로 넘겨주는데, request 시, Int로 요청하도록 API가 구성되어 있음
        
        // API양식에 맞게 데이터를 기입한다.
        let sJson: String         =
        """
        {\"aspectRatio\":0.45,
        \"strokes\":[
                    {\"points\":[\(self.pointString)],
                    \"color\":\"#B34E61\",
                    \"size\":1000,
                    \"cap\":\"round\",
                    \"join\":\"round\",
                    \"miterLimit\":10}
                    ]
        }
        """
        
//        let sJson: String = "스트링테스트"
        
        
        let willPassNoteData = NoteTakingInput(token: "Y2Q1YTYzM2NjNjE3NmZlYmI5MTYwMmVkNDVjOTE0MGI3NDIwYTFjN2U5ZGI1MzdkYzMyMjE0Y2M4YjIyMjEwNzM1NzEyZDQ3ODk1NGQ1Y2U5NWFlNzQ3NjFjOWU5Y2FlMmMzZTVlMTQwMmRmYjg1M2E3NjhiYWFmNjc5ZmU4ZGZFdUx1RzNjVVFmQk1uajdCKzdUMlhCdCtHOEltTnlJN0hSL2Y5anc3Z1lZaTFQNTNGWWk4cmhYM1hVdlRIV0pSd25aWGxpdWJrUHBsTEJocExrYmFnQT09",
                                               video_id: 21093,
                                               sjson: sJson)
        DetailNoteDataManager().savingNoteTakingAPI(willPassNoteData, viewController: self)
        
    }
    
    // MARK: - Heleprs
    
    private func setupData() {
        
        guard let id = self.id else { return }
        guard let token = self.token else { return }
        
        let dataForSearchNote = NoteInput(video_id: id,
                                          token: token)
        DetailNoteDataManager().DetailNoteDataManager(dataForSearchNote,
                                                      viewController: self)
    }
    
    private func setupLayout() {
        
        canvas.delegate = self // canvas position 데이터 전달받기 위한 델리게이션
        setupScrollView()
        setupWritingImplement()
    }
    
    private func setupScrollView() {
        
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
    
    private func setupViews() {
        
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
    
    private func setupWritingImplement() {
        
        let width = view.frame.width * 0.5
        writingImplement.alpha = 1
        view.addSubview(writingImplement)
        writingImplement.setDimensions(height: 50,
                                       width: width)
        writingImplement.anchor(left: view.leftAnchor,
                                bottom: view.bottomAnchor,
                                paddingBottom: 10)
        
        view.addSubview(savingNoteButton)
        savingNoteButton.setDimensions(height: 50, width: 55)
        savingNoteButton.anchor(bottom: view.bottomAnchor,
                                right: view.rightAnchor,
                                paddingBottom: 10)
        
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
    
    internal func didSucceedReceiveNoteData(responseData: NoteResponse) {
        
        guard let data = responseData.data else { return }
        
        self.noteImageCount = data.sNotes.count
        
        for noteData in 0 ... (self.noteImageCount-1) {
            let convertedURL = makeStringKoreanEncoded("\(fileBaseURL)/" + "\(data.sNotes[noteData])")
            getImageFromURL(url: convertedURL, index: noteData)
        }
    }
    
    private func getImageFromURL(url: String, index: Int) {
        
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


// MARK: - CanvasDelegate

extension LectureNoteController: CanvasDelegate {
    
    func passLinePositionDataForLectureNoteController(points: [String]) {
//        self.pointString = String(points.dropLast(1))
//        print("DEBUG: \(self.pointString)")
        
        var testArr = [String]()
        let color = "#B34E61"
        
        for (_, p) in points.enumerated() {
            
            let sJson: String         =
            "{\"aspectRatio\":0.45,\"strokes\":[{\"points\":[\(String(p.dropLast(1)))],\"color\":\"\(color)\",\"size\":1000,\"cap\":\"round\",\"join\":\"round\",\"miterLimit\":10}]}"
            
            testArr.append(sJson)
            
        }
        print("DEBUG: sJsonTest \(testArr)")
        
        
        
    }
}
