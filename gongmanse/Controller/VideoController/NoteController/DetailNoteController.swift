//
//  DetailNoteController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/17.
//

import UIKit
import SDWebImage

private let cellID = "NoteImageCell"

/// 05.25 이전 노트 컨트롤러
class DetailNoteController: UIViewController {
    
    // MARK: - Properties
    // MARK: Data
    
    var noteImageCount = 0
    var noteImageArr = [UIImage(), UIImage(), UIImage(), UIImage(), UIImage(), UIImage()]
    { didSet { collectionView.reloadData() } }
    var url: String?
    var receivedNoteImage: UIImage?
    var id: String?
    var token: String?
    
    // MARK: UI
    
    var canvas = Canvas()
    
    private let textImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let layout = UICollectionViewFlowLayout()
    lazy var frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    lazy var collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    
    // 노트필기 객체
    private let noteTakingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "scribble.variable")?.withTintColor(.mainOrange, renderingMode: .alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.contentMode = .scaleToFill
//        button.addTarget(self, action: #selector(playPausePlayer), for: .touchUpInside)
        return button
    }()
    
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
        configureUI()
        guard let id = self.id else { return }
        guard let token = self.token else { return }
        
        DetailNoteDataManager().DetailNoteDataManager(NoteInput(video_id: id, token: token), viewController: self)
        
        print("DEBUG: VideoID는 \(id)")
        print("DEBUG: 토큰은 \(Constant.token) 입니다.")
        
        let receivedToken: String = Constant.token
        let videoID: Int          = Int(id)!
        let sJson: String         =
        """
        {\"aspectRatio\":0.5095108695652174,
        \"strokes\":[
                    {\"points\":[{\"x\":0.4533333333333333,
                                \"y\":0.8389521059782609}],
        \"color\":\"#d82579\",
        \"size\":0.005333333333333333,
        \"cap\":\"round\",
        \"join\":\"round\",
        \"miterLimit\":10}]}
        """
        
//        let input                  = NoteTakingInput(token: receivedToken,
//                                                     video_id: videoID,
//                                                     sjson: sJson)
//
//        DetailNoteDataManager().savingNoteTakingAPI(input, viewController: self)
    }
    
    
    // MARK: - Actions
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        let touch = touches.first!
//        let point = touch.location(in: touchPositionView)
//        print("DEBUG: 현재 터치한 곳의 위치는 \(point) 입니다.")
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("DEBUG: 터치를 종료합니다...")
//    }
    
    @objc func openWritingImplement() {

        if canvas.alpha == 0 {
            canvas.alpha = 1
        } else {
            canvas.alpha = 0
        }
    }
    
    @objc fileprivate func handleUndo() {
        canvas.undo()
    }
    
    @objc fileprivate func handleClear() {
        canvas.clear()
    }
    
    @objc fileprivate func handleColorChange(button: UIButton) {
        canvas.setStrokeColor(color: button.backgroundColor ?? .black)
    }
    
    
    // MARK: - Heleprs
    
    func configureUI() {
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.itemSize.height = 310
        collectionView.backgroundColor = .systemGreen
        layout.itemSize.width = view.frame.width
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor,
                              left: view.leftAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor)
        collectionView.register(NoteImageCell.self, forCellWithReuseIdentifier: cellID)
        
        view.addSubview(canvas)
        canvas.anchor(top:collectionView.topAnchor,
                      left: collectionView.leftAnchor)
        canvas.setDimensions(height: collectionView.frame.height, width: collectionView.frame.width)
        canvas.backgroundColor = .lightGray
        canvas.alpha = 0
        
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


extension DetailNoteController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("DEBUG: self.noteImageArr.count \(self.noteImageArr.count)")
        return self.noteImageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NoteImageCell
        let image = noteImageArr[indexPath.row]
//        resize(image: image, scale: 0.45) { image in
//            cell.noteImageView.image = image
//        }
        return cell
    }
}


// MARK: - API

extension DetailNoteController {
    internal func didSaveNote() {
//        let alert = UIAlertController(title: nil, message: "저장 완료", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
        presentAlert(message: "저장 완료")
    }
    
    func didSucceedReceiveNoteData(responseData: NoteResponse) {
        
        guard let data = responseData.data else { return }
        self.noteImageCount = data.sNotes.count
        
        for noteData in 0 ... (self.noteImageCount-1) {
            let convertedURL = makeStringKoreanEncoded("\(fileBaseURL)/" + "\(data.sNotes[noteData])")
            getImageFromURL(url: convertedURL, index: noteData)
        }
        collectionView.reloadData()
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
