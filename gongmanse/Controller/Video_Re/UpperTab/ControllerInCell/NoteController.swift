//
//  NoteController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/10.
//

import UIKit

class NoteController: UIViewController {
    
    // MARK: - Properties
    
    /// 재생 및 일시정지 버튼
    let noteTakingButton: UIButton = {
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
        view.backgroundColor = .white
        
        view.addSubview(noteTakingButton)
        noteTakingButton.setDimensions(height: 100, width: 100)
        noteTakingButton.centerX(inView: view)
        noteTakingButton.centerY(inView: view)
    }
    
    // MARK: - Actions
    
    @objc func playPausePlayer() {
        print("DEBUG: 클릭이잘된다.")
    }
    
    
    // MARK: - Heleprs
    
    
}
