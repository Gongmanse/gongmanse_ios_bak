//
//  EndLabelPickerViewController.swift
//  gongmanse
//
//  Created by wallter on 2021/06/02.
//

import UIKit
import BottomPopup


protocol PassAllEndDate: AnyObject {
    var allEndDate: String? { get set }
    func reloadTable()
}

class EndLabelPickerViewController: BottomPopupViewController, PassEndDateTime {
    
    
    
    weak var allEndDelegate: PassAllEndDate?

    // topView
    let topLittleImage: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "popup_date")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let topTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "날짜"
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
    
    // 하단 버튼
    let todayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("오늘", for: .normal)
        button.titleLabel?.font = .appBoldFontWith(size: 16)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.rgb(red: 237, green: 237, blue: 237).cgColor
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("시간 선택", for: .normal)
        button.titleLabel?.font = .appBoldFontWith(size: 16)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.rgb(red: 237, green: 237, blue: 237).cgColor
        return button
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todayButton, confirmButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    //
    
    let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        picker.datePickerMode = .date
        picker.timeZone = NSTimeZone.local
        picker.backgroundColor = .white
        picker.locale = Locale(identifier: "ko-KR")
        return picker
    }()
    
    // DatePicker 데이터 넣을 변수
    var startDate: String?
    
    var allDateTimeString: String?{
        get {
            return allEndDelegate?.allEndDate
        }
        set(value) {
            allEndDelegate?.allEndDate = value
            allEndDelegate?.reloadTable()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configuration()
        constraints()
        
        endDatePicker.addTarget(self, action: #selector(pickerDateValue(_:)), for: .valueChanged)
        topDismissButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(nextTimePicker(_:)), for: .touchUpInside)
    }

    @objc func pickerDateValue(_ sender: UIDatePicker) {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        
        let dayformatter: DateFormatter = DateFormatter()
        dayformatter.dateFormat = "EE"
        dayformatter.locale = Locale(identifier: "ko_KR")
        
        let selectedDate: String = dateformatter.string(from: sender.date)
        let dayString: String = dayformatter.string(from: sender.date)
        
        startDate = "\(selectedDate) (\(dayString))"
    }
    
    @objc func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func nextTimePicker(_ sender: UIButton) {
        
        
        guard let selfViewController = self.presentingViewController else { return }
        
        let endTiemVC = EndTimePickerViewController()
        endTiemVC.dateSelectString = startDate
        endTiemVC.endDelegate = self
        
        
        self.dismiss(animated: true) {
            selfViewController.present(endTiemVC, animated: true)
        }
    }
}

extension EndLabelPickerViewController {
    
    func configuration() {
        
        view.backgroundColor = .white
        view.addSubview(topStackView)
        view.addSubview(topOrangeLineView)
        view.addSubview(buttonStack)
        view.addSubview(endDatePicker)
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
        
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endDatePicker.topAnchor.constraint(equalTo: topOrangeLineView.bottomAnchor).isActive = true
        endDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        endDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        endDatePicker.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
    }
}

