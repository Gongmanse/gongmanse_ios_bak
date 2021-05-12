//
//  NoteController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/10.
//

import UIKit

private let cellID = "NoteImageCell"

class NoteController: UIViewController {
    
    // MARK: - Properties
    
    /// 재생 및 일시정지 버튼
    private let noteTakingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "scribble.variable")?.withTintColor(.mainOrange, renderingMode: .alwaysOriginal)
        button.setBackgroundImage(image, for: .normal)
        button.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(playPausePlayer), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func playPausePlayer() {
        print("DEBUG: 클릭이잘된다.")
    }
    
    
    // MARK: - Heleprs
    
    func configureUI() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.itemSize.height = 300
        layout.itemSize.width = view.frame.width
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
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


extension NoteController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NoteImageCell
        return cell
    }
    
    
}
