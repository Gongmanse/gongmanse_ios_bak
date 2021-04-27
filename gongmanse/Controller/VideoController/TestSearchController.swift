//
//  TestSearchController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/27.
//

import UIKit

class TestSearchController: UIViewController {
    
    // MARK: - Property
    
    var clickedText: String?
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "키워드를 전달받지 못함"
        label.textColor = .mainOrange
        label.backgroundColor = .black
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    init(clickedText: String) {
        self.clickedText = clickedText
        label.text = clickedText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label)
        label.setDimensions(height: 200, width: 200)
        label.centerX(inView: view)
        label.centerY(inView: view)
    }
    
}
