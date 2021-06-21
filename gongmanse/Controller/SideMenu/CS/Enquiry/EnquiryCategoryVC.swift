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

enum EnquiryState{
    case create, update
}

class EnquiryCategoryVC: UIViewController {

    //label
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var serviceDisorderButton: UIButton!
    @IBOutlet weak var paymentAuthButton: UIButton!
    @IBOutlet weak var lectureRequestButton: UIButton!
    @IBOutlet weak var otherInquiryButton: UIButton!
    @IBOutlet weak var registButton: UIButton!
    
    //textview
    @IBOutlet weak var QuestionTextView: UITextView!
    
    // 문의하기 작성 파라미터
    private var categoryButtonTag = 0
    private var questionText = ""
    
    var enquiryViewModel: OneOneViewModel? = OneOneViewModel()
    
    var enquiryText: String?
    
    var buttonType: Int = 0
    
    // 업데이트에서 데이터 넘어옴
    var updateModel: OneOneQnADataList?
    
    // 등록 수정창 상태관리
    var enquiryState: EnquiryState?
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationSetting()
        basicScreenUI()
        configuration()
        
        switch enquiryState {
        case .update:
            
            QuestionTextView.text = updateModel?.sQuestion
            QuestionTextView.textColor = .black
            guard let buttonTag = Int(updateModel?.iType ?? "0") else { return }
            buttonType = buttonTag
            print(buttonTag)
            switch buttonTag {
            case 1:
                useButton.backgroundColor = .mainOrange
            case 2:
                serviceDisorderButton.backgroundColor = .mainOrange
            case 3:
                paymentAuthButton.backgroundColor = .mainOrange
            case 4:
                otherInquiryButton.backgroundColor = .mainOrange
            case 5:
                lectureRequestButton.backgroundColor = .mainOrange
            default:
                return
            }
            
        default:
            return
        }
        
    }
    
    @IBAction func registEnquiryAction(_ sender: UIButton) {
        
        switch enquiryState {
        case .create:
            
            if let question = enquiryText {
                enquiryViewModel?.requestOneOneRegist(question: question, type: buttonType, comepletionHandler: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            
        case .update:
            guard let viewcontroller: [UIViewController] = self.navigationController?.viewControllers else { return }
            
            enquiryViewModel?.requestOneOneUpdate(id: updateModel?.id ?? "",
                                                  quetion: enquiryText ?? "",
                                                  type: "\(buttonType)", completionHandler: {
                                                    self.navigationController?.popToViewController(viewcontroller[viewcontroller.count - 3], animated: true)
                                                  })
            
        default:
            return
        }
    }
}


//MARK: - extension drawing UI요소들만
extension EnquiryCategoryVC {
    
    func configuration() {
        
        QuestionTextView.delegate = self
        QuestionTextView.text = "질문을 입력해 주세요"
        QuestionTextView.textColor = .lightGray
        QuestionTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        QuestionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        categoryLabel.font = .appBoldFontWith(size: 16)
        categoryLabel.textColor = .rgb(red: 128, green: 128, blue: 128)
        
        questionLabel.font = .appBoldFontWith(size: 16)
        questionLabel.textColor = .rgb(red: 128, green: 128, blue: 128)
    }
    
    func basicScreenUI() {
        initButton()
        initLabel()
        initTextView()
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
        useButton.backgroundColor = .gray200Color
        useButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        serviceDisorderButton.layer.cornerRadius = 10
        serviceDisorderButton.tintColor = .white
        serviceDisorderButton.backgroundColor = .gray200Color
        serviceDisorderButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        paymentAuthButton.layer.cornerRadius = 10
        paymentAuthButton.tintColor = .white
        paymentAuthButton.backgroundColor = .gray200Color
        paymentAuthButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        lectureRequestButton.layer.cornerRadius = 10
        lectureRequestButton.tintColor = .white
        lectureRequestButton.backgroundColor = .gray200Color
        lectureRequestButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        
        otherInquiryButton.layer.cornerRadius = 10
        otherInquiryButton.tintColor = .white
        otherInquiryButton.backgroundColor = .gray200Color
        otherInquiryButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        
        registButton.tintColor = .white
        registButton.backgroundColor = UIColor.rgb(red: 237, green: 118, blue: 0)
        registButton.layer.cornerRadius = 10
        registButton.addTarget(self, action: #selector(sendTag(_:)), for: .touchUpInside)
        
        switch enquiryState {
        case .create:
            registButton.setTitle("작성하기", for: .normal)
            registButton.isEnabled = false
            registButton.backgroundColor = .gray200Color
        case .update:
            registButton.setTitle("수정하기", for: .normal)
        default:
            return
        }
    }
    
    @objc func sendTag(_ sender: UIButton) {
        
        // 전체버튼을 회색으로 만든다.
        useButton.backgroundColor = .gray200Color
        serviceDisorderButton.backgroundColor = .gray200Color
        paymentAuthButton.backgroundColor = .gray200Color
        lectureRequestButton.backgroundColor = .gray200Color
        otherInquiryButton.backgroundColor = .gray200Color
        
        sender.backgroundColor = .mainOrange
        buttonType = sender.tag

        
        switch enquiryState {
        case .create:
            // 버튼의 tag가 0이 아니면 true
            if buttonType != 0 {
                enquiryViewModel?.selectButtons.value = true
            }
            
            // confirm이 true를 리턴하면 value == true or value == false
            if let value = enquiryViewModel?.allConfirm() {
                registButton.isEnabled = value
                if value {
                    registButton.backgroundColor = .mainOrange
                } else {
                    registButton.backgroundColor = .gray200Color
                }
            }
        default:
            return
        }
        
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

extension EnquiryCategoryVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "질문을 입력해 주세요" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = "질문을 입력해 주세요"
            textView.textColor = .lightGray
            enquiryViewModel?.selectText.value = false
        } else {
            enquiryText = textView.text
            enquiryViewModel?.selectText.value = true
        }
        
        switch enquiryState {
        case .create:
            if let value = enquiryViewModel?.allConfirm() {
                registButton.isEnabled = value
                if value {
                    registButton.backgroundColor = .mainOrange
                } else {
                    registButton.backgroundColor = .gray200Color
                }
            }

        default:
            return
        }
    }
    
}
