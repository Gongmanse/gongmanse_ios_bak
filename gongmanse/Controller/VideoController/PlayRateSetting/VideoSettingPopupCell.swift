//
//  VideoSettingPopupCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/29.
//

import UIKit

class VideoSettingPopupCell: UITableViewCell {
    
    // MARK: - Properties
    
    var index = 0
    
    var imageName = String() {
        didSet { configureUI() }
    }
    
    var stateText = String() {
        didSet { configureUI() }
    }
    
    let leftImageView: UIImageView = {
        let imageView = UIImageView()
        var image = UIImage(systemName: "textbox")
        imageView.image = image
        return imageView
    }()
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appBoldFontWith(size: 11)
        return label
    }()
    
    private let verticalBorderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .progressBackgroundColor
        return view
    }()
    
    private let bottomBorderLine: UIView = {
        let view = UIView()
        let color = UIColor.progressBackgroundColor.withAlphaComponent(0.88)
        view.backgroundColor = color
        return view
    }()
    
    var state: UILabel = {
        let label = UILabel()
        label.font = UIFont.appRegularFontWith(size: 11)
        label.textColor = .mainOrange
        label.text = "Default"
        return label
    }()
    
    private let view = UIView()
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        
        leftImageView.image = UIImage(systemName: "\(imageName)")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        state.text = stateText
        
        /* View */
        self.addSubview(view)
        view.anchor(top: self.topAnchor, left: self.leftAnchor,
                    bottom: self.bottomAnchor, right: self.rightAnchor)
        view.backgroundColor = .white
        
        view.addSubview(leftImageView)
        leftImageView.setDimensions(height: 25, width: 25)
        leftImageView.centerY(inView: view)
        leftImageView.anchor(left: view.leftAnchor, paddingLeft: 25)
        
        view.addSubview(cellLabel)
        cellLabel.setDimensions(height: 25, width: 45)
        cellLabel.centerY(inView: view)
        cellLabel.anchor(left: leftImageView.rightAnchor, paddingLeft: 7.5)
        
        view.addSubview(verticalBorderLine)
        verticalBorderLine.setDimensions(height: 21, width: 2.6)
        verticalBorderLine.layer.cornerRadius = 2
        verticalBorderLine.centerY(inView: view)
        verticalBorderLine.anchor(left: cellLabel.rightAnchor, paddingLeft: 5)
        
        view.addSubview(state)
        state.setDimensions(height: 25, width: 45)
        state.centerY(inView: view)
        state.anchor(left: verticalBorderLine.rightAnchor, paddingLeft: 7.4)
        
        view.addSubview(bottomBorderLine)
        bottomBorderLine.setDimensions(height: 1.2, width: Constant.width * 0.88)
        bottomBorderLine.centerX(inView: view)
        bottomBorderLine.anchor(bottom: view.bottomAnchor)
        
        
    }
    
    
}
