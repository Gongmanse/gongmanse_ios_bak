//
//  LectureNoteController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/25.
//

import UIKit
import Alamofire

/// 05.25 이후 노트 컨트롤러
class LessonNoteController: UIViewController {
    
    // MARK: - Properties
    // MARK: Data
    private let id: String?
    private let token: String?
    private var url: String?
    private var strokesString = ""
    
    // 노트 이미지 인스턴스
    // Dummydata - 인덱스로 접근하기 위해 미리 배열 요소 생성
    private var noteImageArr = [UIImage(), UIImage(), UIImage(), UIImage(), UIImage(), UIImage(), UIImage(), UIImage(),
                                UIImage(), UIImage(), UIImage(), UIImage(), UIImage()]
    private var noteImageCount = 0
//    private var receivedNoteImage: UIImage?
    
    // MARK: UI
    // 노트 객체
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView01: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    // 노트필기 객체
    public let canvas = Canvas()
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
    
    private var isFoldingWritingImplement = true  // 필기도구 View가 축소된 상태면 false
    private var writingImplementLeftConstraint: NSLayoutConstraint?
    private let writingImplement: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .mainOrange
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()
    
    private let redButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "redPencilOff"), for: .normal)
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let greenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "greenPencilOff"), for: .normal)
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let blueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "bluePencilOff"), for: .normal)
        button.addTarget(self, action: #selector(handleColorChange), for: .touchUpInside)
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "eraserOff"), for: .normal)
        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        return button
    }()
    
    private let writingImplementToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("필기\n도구", for: .normal)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 12)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(openWritingImplement), for: .touchUpInside)
        return button
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("이전", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 12)
        button.backgroundColor = UIColor.rgb(red: 21, green: 176, blue: 172)
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appBoldFontWith(size: 12)
        button.backgroundColor = UIColor.rgb(red: 21, green: 176, blue: 172)
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 5
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
        setupNoteTaking()
    }
    
    
    // MARK: - Actions
    
    @objc fileprivate func handleUndo() {
        canvas.undo()
    }
    
    @objc fileprivate func handleClear() {
        canvas.clear()
    }
    
    @objc fileprivate func handleColorChange(button: UIButton) {
        
        var pencilColor = #colorLiteral(red: 0.7536085248, green: 0.2732567191, blue: 0.3757801056, alpha: 1)
        
        switch button {
        case redButton:
            pencilColor = #colorLiteral(red: 0.7536085248, green: 0.2732567191, blue: 0.3757801056, alpha: 1)
        case greenButton:
            pencilColor = #colorLiteral(red: 0.2518872917, green: 0.6477053165, blue: 0.3158096969, alpha: 1)
        case blueButton:
            pencilColor = #colorLiteral(red: 0.07627140731, green: 0.6886936426, blue: 0.6746042967, alpha: 1)
        default:
            pencilColor = #colorLiteral(red: 0.7536085248, green: 0.2732567191, blue: 0.3757801056, alpha: 1)
        }
        
        canvas.setStrokeColor(color: pencilColor)
    }
    
    @objc fileprivate func toggleSketchMode() {
        scrollView.isScrollEnabled.toggle()
    }
    
    @objc fileprivate func openWritingImplement() {
        
        let width = view.frame.width * 0.5
        let noteMode = self.scrollView.isScrollEnabled
        scrollView.isScrollEnabled.toggle()

        // !noteMode -> 노트필기 가능한상태
        if !noteMode {
            self.writingImplementLeftConstraint?.constant = -(width * 0.8)
            self.writingImplementToggleButton.setImage(.none, for: .normal)
            self.writingImplementToggleButton.setTitle("필기\n도구", for: .normal)

            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: []) {
                self.savingNoteButton.alpha = 0
                self.previousButton.alpha = 1
                self.nextButton.alpha = 1
                self.view.layoutIfNeeded()
            } completion: { _ in
                //
            }

        } else {
            
            self.writingImplementLeftConstraint?.constant = 0
            self.writingImplementToggleButton.setTitle("", for: .normal)
            self.writingImplementToggleButton.setImage(#imageLiteral(resourceName: "doubleArrow"), for: .normal)

            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: []) {
                self.savingNoteButton.alpha = 1
                self.previousButton.alpha = 0
                self.nextButton.alpha = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                //
            }
        }
    }
    
    @objc fileprivate func handleSavingNote() {
        
        // canvas 객체로 부터 x,y 위치 정보를 받는다.
        canvas.saveNoteTakingData()
        
        // 이 클래스의 전역범위에 있는 데이터를 지역변수로 옮긴다.
        guard let token = self.token else { return }
        guard let id = self.id else { return }
        
        // 21.05.26 영상 상세정보 API에서 String으로 넘겨주는데, request 시, Int로 요청하도록 API가 구성되어 있음
        let intID = Int(id)!
        
        let sJson = "{\"aspectRatio\":0.45,\"strokes\":[" + "\(self.strokesString)" + "]}"
        
        let willPassNoteData = NoteTakingInput(token: token,
                                               video_id: intID,
                                               sjson: sJson)

        // 노트 필기 좌표 입력하는 API메소드
        DetailNoteDataManager().savingNoteTakingAPI(willPassNoteData, viewController: self)
    }
    
    @objc func tapBackbutton() {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    // MARK: - Heleprs
    
    private func setupData() {
        
        guard let id = self.id else { return }
        guard let token = self.token else { return }
        
        let dataForSearchNote = NoteInput(video_id: id,
                                          token: token)
        // 노트이미지 불러오는 API메소드
        DetailNoteDataManager().DetailNoteDataManager(dataForSearchNote,
                                                      viewController: self)
    }
    
    private func setupLayout() {
        
        canvas.delegate = self // canvas position 데이터 전달받기 위한 델리게이션
        setupScrollView()
        setupWritingImplement()
        
        let naviBackButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(tapBackbutton))
        navigationItem.leftBarButtonItem = naviBackButton
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
        
        // 우선 구현 후, 추후 리펙토링할 예정. 0527
        // 이미지를 UIImage에 할당한다.
        var image01 = noteImageArr[0]
        var image02 = noteImageArr[1]
        var image03 = noteImageArr[2]
        var image04 = noteImageArr[3]
        var image05 = noteImageArr[4]
        var image06 = noteImageArr[5]
        var image07 = noteImageArr[6]
        var image08 = noteImageArr[7]
        var image09 = noteImageArr[8]
        var image10 = noteImageArr[9]
        var image11 = noteImageArr[10]
        var image12 = noteImageArr[11]
        var image13 = noteImageArr[12]
        
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
        
        resize(image: image08, scale: scale) { image in
            image08 = image!
        }
        
        resize(image: image09, scale: scale) { image in
            image09 = image!
        }
        
        resize(image: image10, scale: scale) { image in
            image10 = image!
        }
        
        resize(image: image11, scale: scale) { image in
            image11 = image!
        }
        
        resize(image: image12, scale: scale) { image in
            image12 = image!
        }
        
        resize(image: image13, scale: scale) { image in
            image13 = image!
        }
        
        // 여러 이미지를 하나의 UIImage로 변환한다.
        let convertedImage = mergeVerticallyImagesIntoImage(images:
                                                                image01,
                                                                image02,
                                                                image03,
                                                                image04,
                                                                image05,
                                                                image06,
                                                                image07,
                                                                image08,
                                                                image09,
                                                                image10,
                                                                image11,
                                                                image12,
                                                                image13)
        imageView01.image = convertedImage
    }
    
    private func setupWritingImplement() {
        
        let width = view.frame.width * 0.5
        let bottomPadding = view.frame.height * 0.07
        let height = view.frame.height * 0.09
        
        writingImplement.alpha = 1
        view.addSubview(writingImplement)
        writingImplement.setDimensions(height: height,
                                       width: width)
        writingImplement.anchor(bottom: view.bottomAnchor,
                                paddingBottom: bottomPadding)
        
        writingImplementLeftConstraint = writingImplement.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -(width * 0.8))
        writingImplementLeftConstraint?.isActive = true
        
        view.addSubview(savingNoteButton)
        savingNoteButton.setDimensions(height: height, width: width * 0.25)
        savingNoteButton.anchor(bottom: view.bottomAnchor,
                                right: view.rightAnchor,
                                paddingBottom: bottomPadding)
        savingNoteButton.alpha = 0
        
        view.addSubview(previousButton)
        previousButton.setDimensions(height: height * 0.45, width: width * 0.25)
        previousButton.anchor(bottom: view.bottomAnchor,
                              right: view.rightAnchor,
                              paddingBottom: bottomPadding + height - (height * 0.45))
        
        view.addSubview(nextButton)
        nextButton.setDimensions(height: height * 0.45, width: width * 0.25)
        nextButton.anchor(top: previousButton.bottomAnchor,
                          right: view.rightAnchor,
                          paddingTop: 10)
        
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
    
    func setupNoteTaking() {
        
    }
}




extension LessonNoteController {
    
    internal func didSucceedReceiveNoteData(responseData: NoteResponse) {
        
        guard let data = responseData.data else { return }
        
        // 노트 이미지를 가져오기 위한 로직으로 한글 URL 변경작업을 한다.
        self.noteImageCount = data.sNotes.count
        for noteData in 0 ... (self.noteImageCount-1) {
            let convertedURL = makeStringKoreanEncoded("\(fileBaseURL)/" + "\(data.sNotes[noteData])")
            getImageFromURL(url: convertedURL, index: noteData)
        }
        
        // MARK: 노트필기를 불러오는 로직
        // 서버에 저장되어 있는 좌표값을 canvas에 그릴 수 있는 형태로 변환한다.
        var previousNoteTakingData = [Line]()
        
        if let jsonData = data.sJson {
            if let strokes = jsonData.strokes { // "strokes" 에 LineData가 모두 있다.
                print("DEBUG: 불러온데이터 \(strokes)")
                for stroke in strokes {
                    // 3 개의 데이터
                    var xyPoints = [CGPoint]()
                    var penColorArr = [UIColor]()
                    // TODO: line 구조체 변경하여 color를 String으로 변경하면서 "color"를 사용할 예정이다.
                    let color = stroke.color  // 핵사코드로 전달해준다.
                    var penColor = UIColor()

                    switch color {
                    case "red":
                        penColor = .redPenColor
                    case "green":
                        penColor = .greenPenColor
                    case "blue":
                        penColor = .bluePenColor
                    default:
                        penColor = .redPenColor
                    }
                    
//                    for (i, p) in strokes.enumerated() {
//                        // 색상을 고른다.
//
//                        // 셋중 하나를 고른 후 penColorArr에 추가한다.
//                        penColorArr.append(penColor)
//                    }
                    // x,y 좌표 값을 arr에 append 한다.
                    for (_, p) in stroke.points.enumerated() {
                        
                        let xyPoint = CGPoint(x: CGFloat(p.x), y: CGFloat(p.y))
                        xyPoints.append(xyPoint)
                    }
                    //                        print("DEBUG: xyPoint데이터 \n\(xyPoints)")
                    let line = Line(strokeWidth: 0.5, color: penColor, points: xyPoints)
                    previousNoteTakingData.append(line)
                    //                        print("DEBUG: line데이터 \(line)")
                    
                }
            }
        }
        
        canvas.lines = previousNoteTakingData  // 이전에 필기한 노트정보를 canvas 인스턴스에 전달한다.
//        print("DEBUG: previousNoteTakingData \n\(previousNoteTakingData)")
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

extension LessonNoteController: CanvasDelegate {
    
    /// "02021. 동영상 노트 수정" (PATCH) 메소드 수행을 위한 메소드
    /// - 작성일시: 21.05.26
    /// - 기구현된 Web와 AOS 양식을 맞추기 위해 구현한 메소드
    /// - 이 외 연동 방법이 없다고 하여 구현함. 변경할 수 있다면, 노트필기 로직자체가 변경되는 것이 괜찮아보임
    func passLinePositionDataForLectureNoteController(points: [String], color: [UIColor]) {
        // "노트저장"을 클릭하면 이 메소드를 호출한다.
        
        // MARK: 노트필기를 작성하는 로직
        var tempArr = [String]()  // x, y 값이 있는 arr를 임시로 저장할 배열
        var uiColor2StringColorArr = [String]()

        // color 배열에 있는 UIColor 데이터를 string으로 변경한다. 이유는 API 양식에 맞추기 위함이다.
        for (_, p) in color.enumerated() {
            var tempColorString = String()
            // 색상을 고른다.
            switch p {
            case .redPenColor:
                tempColorString = "red"
            case .greenPenColor:
                tempColorString = "green"
            case .bluePenColor:
                tempColorString = "blue"
            default:
                tempColorString = "red"
            }
            uiColor2StringColorArr.append(tempColorString)
        }
        
        // 1:n = color:(x,y) 관계이므로 하나의 색상에 많은 좌표가 포함된다.
        // 그러므로 하나의 String에 하나의 색상에 다수의 x,y좌표를 입력한다.
        for (i, p) in points.enumerated() {
            
            // "strokes" String에 x,y 좌표값과 color를 String으로 입력한다.
            let strokes: String = "{\"points\":[\(String(p.dropLast(1)))],\"color\":\"\(uiColor2StringColorArr[i])\",\"size\":0.5,\"cap\":\"round\",\"join\":\"round\",\"miterLimit\":10}"
            
            // tempArr에 {points: 다수의 x,y좌표값들, color: 한개의 색상 ...} 의 구조 구성요소를 가지며
            // 이러한 구성요소를 배열의 형태로 저장하고 있다.
            tempArr.append(strokes)
        }
        
        
        // 하나의 String으로 하나의 Line을 표현했지만, 이것들을 다시 하나의 String으로 묶어서
        // API에 request해주어야 PATCH가 동작한다. (API가 이런식으로 되어있어서 어쩔 수 없음)
        var tempString = ""
        
        for (_, p) in tempArr.enumerated() {
            tempString += (p + ",")
        }

        // element의 끝에 "," 가 모두 추가되어 있기 때문에 마지막 ","는 제거한다.
        self.strokesString = String(tempString.dropLast(1))
    }
}