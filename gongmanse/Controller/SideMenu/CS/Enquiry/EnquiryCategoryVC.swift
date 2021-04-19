//
//  EnquiryCategoryVC.swift
//  gongmanse
//
//  Created by taeuk on 2021/04/01.
//
/* *
 문의하기 기능
 카테고리의 텍스트, 질문 텍스트, 오늘 날짜, 유저의 id
 
 */
import UIKit

class SelectButtonState: UIButton {
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.orange : UIColor.gray
        }
    }
}

class EnquiryCategoryVC: UIViewController {

    //label
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var useButton: SelectButtonState!
    @IBOutlet weak var serviceDisorderButton: SelectButtonState!
    @IBOutlet weak var paymentAuthButton: SelectButtonState!
    @IBOutlet weak var lectureRequestButton: SelectButtonState!
    @IBOutlet weak var otherInquiryButton: SelectButtonState!
    @IBOutlet weak var writeButton: SelectButtonState!
    
    //textview
    @IBOutlet weak var QuestionTextView: UITextView!
    
    // 문의하기 작성 파라미터
    private var categoryButtonTag = 0
    private var questionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        basicScreenUI()
        
        
    }
}


//MARK: - extension drawing UI요소들만
extension EnquiryCategoryVC {
    
    func basicScreenUI() {
        initButton()
        initLabel()
        initTextView()
        navigationSetting()
    }
    
    func initLabel() {
        categoryLabel.font = UIFont(name: "NanumSquareRoundEB", size: 16)
        categoryLabel.tintColor = UIColor.rgb(red: 128, green: 128, blue: 128)
        
        categoryLabel.font = UIFont(name: "NanumSquareRoundEB", size: 16)
        categoryLabel.tintColor = UIColor.rgb(red: 128, green: 128, blue: 128)
    }
    
    func initButton() {
        useButton.layer.cornerRadius = 10
        useButton.tintColor = .white
        useButton.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200)
        useButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        serviceDisorderButton.layer.cornerRadius = 10
        serviceDisorderButton.tintColor = .white
        serviceDisorderButton.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200)
        serviceDisorderButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        paymentAuthButton.layer.cornerRadius = 10
        paymentAuthButton.tintColor = .white
        paymentAuthButton.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200)
        paymentAuthButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        lectureRequestButton.layer.cornerRadius = 10
        lectureRequestButton.tintColor = .white
        lectureRequestButton.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200)
        lectureRequestButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        
        otherInquiryButton.layer.cornerRadius = 10
        otherInquiryButton.tintColor = .white
        otherInquiryButton.backgroundColor = UIColor.rgb(red: 200, green: 200, blue: 200)
        otherInquiryButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        
        writeButton.tintColor = .white
        writeButton.backgroundColor = UIColor.rgb(red: 237, green: 118, blue: 0)
        writeButton.layer.cornerRadius = 10
        writeButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
    }
    
    @objc func sendTag(_ sender: UIButton) {
        print(sender.tag)
    }
    
    func initTextView() {
        QuestionTextView.layer.cornerRadius = 10
        QuestionTextView.layer.borderWidth = 1
        QuestionTextView.layer.borderColor = UIColor.rgb(red: 237, green: 237, blue: 237).cgColor
        
        QuestionTextView.font = UIFont(name: "NanumSquareRoundB", size: 14)
    }
    
    func navigationSetting() {
        
        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "문의하기"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
}
