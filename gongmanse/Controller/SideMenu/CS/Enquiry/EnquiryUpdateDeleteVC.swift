//
//  EnquiryUpdateDeleteVC.swift
//  gongmanse
//
//  Created by wallter on 2021/06/17.
//

import UIKit

class EnquiryUpdateDeleteVC: UIViewController {

    
    @IBOutlet weak var enquriyText: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var typeTextLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var answerText: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    var oneoneModel: OneOneQnADataList?
    var oneoneViewModel: OneOneViewModel?
    var oneoneListID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration()
        oneoneViewModel?.delegatePop = self
    }

    @IBAction func updateAction(_ sender: UIButton) {
        let updateVC = EnquiryCategoryVC()
        updateVC.enquiryState = .update
        updateVC.updateModel = oneoneModel
        self.navigationController?.pushViewController(updateVC, animated: true)
    }
    
    @IBAction func deleteAction(_ sedner: UIButton) {
        let alert = UIAlertController(title: "1:1 문의", message: "삭제하시겠습니까?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default) { (_) in
            self.oneoneViewModel?.requestOneOneDelete(id: self.oneoneListID ?? "")
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension EnquiryUpdateDeleteVC {
    
    func configuration() {
        
        guard let qnaModel = oneoneModel else {
            print("1:1문의 목록 불러오기 오류!")
            return
        }
        
        typeTextLabel.text = qnaModel.typeConvert
//        questionLabel.text = qnaModel.sQuestion
        questionLabel.attributedText = qnaModel.sQuestion.htmlToAttributedString
        stateLabel.text = qnaModel.answerStates
        stateLabel.textColor = .white
        stateLabel.backgroundColor = qnaModel.answerBackgroundColor
        stateLabel.clipsToBounds = true
        stateLabel.layer.cornerRadius = 10
        dateLabel.text = qnaModel.dateConvert
        dateLabel.textColor = .rgb(red: 128, green: 128, blue: 128)
        
//        answerLabel.text = qnaModel.sAnswer ?? "답변을 기다리는 중입니다."
        if let answer = qnaModel.sAnswer {
            answerLabel.attributedText = answer.htmlToAttributedString
        } else {
            answerLabel.text = "답변을 기다리는 중입니다."
        }
        
        // 질문 >, 수정, 삭제
        enquriyText.text = "질문 >"
        enquriyText.font = .appBoldFontWith(size: 16)
        enquriyText.textColor = .rgb(red: 128, green: 128, blue: 128)
        
        updateButton.setTitle("수정", for: .normal)
        updateButton.titleLabel?.font = .appBoldFontWith(size: 14)
        updateButton.titleLabel?.textColor = .black
        deleteButton.setTitle("삭제", for: .normal)
        deleteButton.titleLabel?.font = .appBoldFontWith(size: 14)
        deleteButton.titleLabel?.textColor = .rgb(red: 255, green: 0, blue: 35)
        
        // 답변
        answerText.text = "답변 >"
        answerLabel.font = .appBoldFontWith(size: 16)
        
        
    }
    
}

extension EnquiryUpdateDeleteVC: PopDelgate {
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
