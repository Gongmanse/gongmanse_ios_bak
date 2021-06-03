//
//  EndTimePickerViewController.swift
//  gongmanse
//
//  Created by wallter on 2021/06/02.
//

import UIKit
import BottomPopup

protocol PassEndDateTime {
    var allDateTimeString: String? { get set }
}

class EndTimePickerViewController: BottomPopupViewController {

    // topView
    let topLittleImage: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "popup_time")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let topTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "시간"
        return label
    }()
    
    let topDismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "largeX"), for: .normal)
        return button
    }()
    
    let topOrangeLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainOrange
        return view
    }()
    
    lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topLittleImage, topTextLabel, topDismissButton])
        stack.backgroundColor = .white
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    //
    
    
    let dismissBottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .appBoldFontWith(size: 16)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.rgb(red: 237, green: 237, blue: 237).cgColor
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = .appBoldFontWith(size: 16)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.rgb(red: 237, green: 237, blue: 237).cgColor
        return button
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dismissBottomButton, confirmButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    let endTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        picker.datePickerMode = .time
        picker.timeZone = NSTimeZone.local
        picker.backgroundColor = .white
        picker.locale = Locale(identifier: "ko-KR")
        return picker
    }()
    
    
    // 이전 VC에서 Date받는 변수 2020 02 20
    var dateSelectString: String?
    
    // datePicker선택 시 저장 변수
    var timePicker: String?
    
    var endDelegate: PassEndDateTime?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configuration()
        constraints()
        
        endTimePicker.addTarget(self, action: #selector(pickerTimeValue(_:)), for: .valueChanged)
        topDismissButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        dismissBottomButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButton(_:)), for: .touchUpInside)
    }
    
    @objc func pickerTimeValue(_ sender: UIDatePicker) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let selectTime: String = dateFormatter.string(from: sender.date)
        timePicker = "\(dateSelectString ?? "") \(selectTime)"
        
    }
    
    @objc func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func confirmButton(_ sender: UIButton) {
        
        switch timePicker {
        case .some(let value):
            endDelegate?.allDateTimeString = value
            
        case .none:
            let datefomatter: DateFormatter = DateFormatter()
            datefomatter.dateFormat = "HH:mm"
            let encodeTiemString = datefomatter.string(from: Date())
            timePicker = "\(dateSelectString ?? "") \(encodeTiemString)"

            endDelegate?.allDateTimeString = timePicker
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension EndTimePickerViewController {
    
    func configuration() {
        
        view.backgroundColor = .white
        view.addSubview(topStackView)
        view.addSubview(topOrangeLineView)
        view.addSubview(buttonStack)
        view.addSubview(endTimePicker)
    }
    
    func constraints() {
        
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        topOrangeLineView.translatesAutoresizingMaskIntoConstraints = false
        topOrangeLineView.topAnchor.constraint(equalTo: topStackView.bottomAnchor).isActive = true
        topOrangeLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topOrangeLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topOrangeLineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimePicker.topAnchor.constraint(equalTo: topOrangeLineView.bottomAnchor).isActive = true
        endTimePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        endTimePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        endTimePicker.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
        
    }
}

