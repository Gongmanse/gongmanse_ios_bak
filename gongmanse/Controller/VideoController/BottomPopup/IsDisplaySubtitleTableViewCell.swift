//
//  IsDisplaySubtitleTableViewCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/29.
//

import UIKit

/// VideoSettingBottomPopupController에서 처리해줄 Delegate 프로토콜
/// - 호출은 "IsDisplaySubtitleTableViewCell" 에서 합니다.
protocol IsDisplaySubtitleTableViewCellDelegate: class {
    func dismissBottomPopup()
}

class IsDisplaySubtitleTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: IsDisplaySubtitleTableViewCellDelegate?
    
    private let iConImageView: UIImageView = {
        let iv = UIImageView()
        let image = UIImage(systemName: "textbox")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        iv.image = image
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "옵션"
        label.font = UIFont.appBoldFontWith(size: 15.5)
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "largeX"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let bottomBorderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        
    }
    
    
    
    
    // MARK: - Actions
    
    @objc func handleDismiss() {
        
        print("DEBUG: 클릭되었습니다.")
        delegate?.dismissBottomPopup()
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        
        self.addSubview(iConImageView)
        iConImageView.setDimensions(height: 20, width: 20)
        iConImageView.centerY(inView: self)
        iConImageView.anchor(left: self.leftAnchor,
                             paddingLeft: 15)
        
        self.addSubview(bottomBorderLine)
        bottomBorderLine.setDimensions(height: 2.38, width: self.frame.width + 100)
        bottomBorderLine.centerX(inView: self)
        bottomBorderLine.anchor(bottom:self.bottomAnchor)
        
        self.addSubview(titleLabel)
        titleLabel.setDimensions(height: self.frame.height, width: self.frame.width * 0.77)
        titleLabel.centerY(inView: self)
        titleLabel.anchor(left: iConImageView.rightAnchor,
                          paddingLeft: 7.5)
        
        self.addSubview(closeButton)
        closeButton.setDimensions(height: 50, width: 50)
        closeButton.centerY(inView: self)
        closeButton.anchor(right: self.rightAnchor,
                           paddingRight: 15)
        
    }
    
}
