//
//  DetailNoteController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/17.
//

import UIKit
import SDWebImage

private let cellID = "NoteImageCell"

class DetailNoteController: UIViewController {
    
    // MARK: - Properties
    // MARK: Data
    
    var noteImageCount = 0
    
    var noteImageArr = [UIImage(), UIImage(), UIImage(), UIImage(), UIImage(), UIImage()]
    {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var url: String?
//    {
//        didSet { collectionView.reloadData() }
//    }
    
    var receivedNoteImage: UIImage?
//    {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
    
    var id: String?
    var token: String?
    
    // MARK: UI
    
    private let textImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let layout = UICollectionViewFlowLayout()
    lazy var frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    lazy var collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    
    
    /// 재생 및 일시정지 버튼
    private let noteTakingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "scribble.variable")?.withTintColor(.mainOrange, renderingMode: .alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(playPausePlayer), for: .touchUpInside)
        return button
    }()
    
    private let noteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
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
        
        let points: points        = points(x: 0.4533333333333333,
                                           y: 0.8389521059782609)
        
        let strokes: strokes      = strokes(cap: "round",
                                            join: "round",
                                            miterLimit: 10,
                                            color: "#d82579",
                                            points: [points],
                                            size: 0.005333333333333333)
        
        let sJson: String           =
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
        
        let input                  = NoteTakingInput(token: receivedToken,
                                                     video_id: videoID,
                                                     sjson: sJson)
        
        DetailNoteDataManager().savingNoteTakingAPI(input, viewController: self)
    }
    
    
    // MARK: - Actions
    
    @objc func playPausePlayer() {
        print("DEBUG: 클릭이잘된다.")
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
    }
    
    func configureCollectionView() {
        
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
        resize(image: image, scale: 0.45) { image in
            cell.noteImageView.image = image
        }
        return cell
    }
    
    
}


// MARK: - API

extension DetailNoteController {
    
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
