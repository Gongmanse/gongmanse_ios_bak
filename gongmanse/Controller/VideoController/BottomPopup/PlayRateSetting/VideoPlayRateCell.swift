//
//  VideoPlayRateCell.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/30.
//

import UIKit

class VideoPlayRateCell: UITableViewCell {

    // MARK: - Properties
    
    var stateText = "x1.0" {
        didSet { configure() }
    }
    
    private let view = UIView()
    
    let leftImageView: UIImageView = {
        let imageView = UIImageView()
        var image = UIImage(systemName: "forward")
        imageView.tintAdjustmentMode = .dimmed
        imageView.tintColor = .black
        imageView.image = image
        return imageView
    }()
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.text = "재생 속도"
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
        label.font = UIFont.appBoldFontWith(size: 11)
        label.textColor = .mainOrange
        label.text = "x1.0"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helpers
    
    func configure() {
        
        /* Input state to Label */
        state.text = stateText

        /* Constant */
        let horizontalPadding = CGFloat(10)
        let imageViewHeight = CGFloat(25)
        let labelWidth = CGFloat(47)
        
        /* view */
        contentView.addSubview(view)
        view.setDimensions(height: contentView.frame.height,
                           width: Constant.width)
        view.centerY(inView: contentView)
        view.anchor(left: self.leftAnchor)
        
        /* leftImageView */
        view.addSubview(leftImageView)
        
        leftImageView.setDimensions(height: imageViewHeight, width: imageViewHeight)
        leftImageView.centerY(inView: view)
        leftImageView.anchor(left: view.leftAnchor,
                             paddingLeft: 20)
        
        /* cellLabel */
        view.addSubview(cellLabel)
        cellLabel.setDimensions(height: imageViewHeight, width: labelWidth)
        cellLabel.centerY(inView: view)
        cellLabel.anchor(left: leftImageView.rightAnchor, paddingLeft: horizontalPadding)
        
        /* verticalBorderLine */
        view.addSubview(verticalBorderLine)
        verticalBorderLine.setDimensions(height: imageViewHeight - 2,
                                         width: 2.2)
        verticalBorderLine.centerY(inView: view)
        verticalBorderLine.anchor(left: cellLabel.rightAnchor, paddingLeft: horizontalPadding)
        
        /* state */
        view.addSubview(state)
        state.setDimensions(height: imageViewHeight, width: labelWidth)
        state.centerY(inView: view)
        state.anchor(left: verticalBorderLine.rightAnchor,
                     paddingLeft: horizontalPadding)
        
    }

}
