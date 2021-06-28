import UIKit
import BottomPopup
import Alamofire

class LectureQuestionsDeleteBottomPopUpVC: BottomPopupViewController {
    
    // IBOutlet
    @IBOutlet weak var lectureTitle: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var countLabel: PaddingLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allSelectButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Data
    var clickedRow: Int?
    var currentSelectedRowState = [Bool]()

    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    var deleteLectureQnA: LectureQnAModels?
    var video_id: String = ""
    var video_title: String = ""
    var selectImageChange: Dynamic<Bool> = Dynamic(false)
    var selectIndexId: Dynamic<Bool> = Dynamic(false)
    var isSelect: Bool = false
    var tableViewInputData: [LectureQnAData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderStyles()
        
        getDataFromJson()
        lectureTitle.text = video_title
        
    }
    
    func borderStyles() {
        borderView.backgroundColor = .mainOrange
        allSelectButton.layer.addBorder([.top, .left, .right, .bottom], color: .systemGray4, width: 0.7)
        deleteButton.layer.addBorder([.top, .right, .bottom], color: .systemGray4, width: 0.7)
    }
    
    func getDataFromJson() {
        if let url = URL(string: "https://api.gongmanse.com/v/member/detailqna?token=\(Constant.token)&offset=0&limit=20&video_id=\(video_id)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(LectureQnAModels.self, from: data) {
                    //print(json.body)
                    self.deleteLectureQnA = json
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.textSettings()
                }
                
            }.resume()
        }
    }
    
    func textSettings() {
        guard let value = self.deleteLectureQnA else { return }
        
        self.countLabel.text = "총 \(value.totalNum ?? "nil")개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countLabel.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countLabel.text! as NSString).range(of: value.totalNum ?? "nil"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countLabel.text! as NSString).range(of: value.totalNum ?? "nil"))
        
        self.countLabel.attributedText = attributedString
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func allSelectButtonAction(_ sender: UIButton) {
        isSelect = !isSelect
        selectImageChange.value = isSelect
        
        for index in currentSelectedRowState.indices {
            currentSelectedTableViewCell(index)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        //isSelect = !isSelect
        //selectIndexId.value = isSelect
        
        var currentTrueIndex = [Int]()
        
        for (index, state) in currentSelectedRowState.enumerated() {
            if state {
                currentTrueIndex.append(index)
            }
        }
        // 한 개 Row를 삭제하는 경우
        if currentTrueIndex.count == 1 {
            
            guard let firstIndex = currentTrueIndex.first else { return }
            deleteSelectedRowInAPI(firstIndex)
            
        } else {
            // 여러 Row를 삭제하는 경우
            for index in currentTrueIndex {
                deleteSelectedRowInAPI(index)
            }
            
        }

        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
        
//        guard let json = self.deleteLectureQnA else { return }
//        let indexPath = IndexPath(row: sender.tag, section: 0)
//        let indexid = json.data[indexPath.row].sQid
//        let inputData = LectureQuestionsDeleteBottomPopUpInput(id: indexid ?? "nil")
//
//        /**
//         1. 삭제 API 호출힌디
//         2. API 메소드를 호출한다.
//         3. API메소드 내에서 현재 남은 QnA를 가져온다.
//         4. layoutIfneeded를 호출하여 레이아웃을 업데이트한다.
//         */
//        LectureQuestionsDeleteBottomPopUpVCDataManager().postRemoveExpertConsult(param: inputData, viewController: self)
//        getDataFromJson()
        
    }
    
    /// (편집모드 클릭 후) 선택된 셀을 삭제하는 메소드
    func deleteSelectedRowInAPI(_ selectedIndex: Int) {
        
        guard let json = self.deleteLectureQnA else { return }
        guard let indexid = json.data[selectedIndex].sQid else { return }
        let inputData = LectureQuestionsDeleteBottomPopUpInput(id: indexid)
        LectureQuestionsDeleteBottomPopUpVCDataManager().postRemoveExpertConsult(param: inputData, viewController: self)
    }
    
    
    override var popupHeight: CGFloat {
        return height ?? CGFloat(240)
    }
    
    override var popupTopCornerRadius: CGFloat {
        return topCornerRadius ?? CGFloat(0)
    }
    
    override var popupPresentDuration: Double {
        return presentDuration ?? 0.2
    }
    
    override var popupDismissDuration: Double {
        return dismissDuration ?? 0.5
    }
    
    override var popupShouldBeganDismiss: Bool {
        return shouldDismissInteractivelty ?? true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("사라짐")
    }
}

extension LectureQuestionsDeleteBottomPopUpVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.deleteLectureQnA?.data else { return 0}
        
        for _ in (data.indices) {
            currentSelectedRowState.append(false)
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LectureQuestionsDeleteBottomPopUpCell", for: indexPath) as? LectureQuestionsDeleteBottomPopUpCell else { return UITableViewCell() }
        
        guard let json = self.deleteLectureQnA else { return cell }
        let indexData = json.data[indexPath.row]
        
        selectImageChange.bindAndFire(listener: { bool in
            cell.checkImage.image = bool ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle")
            cell.checkImage.tintColor = bool ? UIColor.mainOrange : UIColor.systemGray4
        })
        
        cell.deleteContext.text = indexData.sQuestion
        deleteButton.tag = indexPath.row
        
        if indexData.sAnswer != nil {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.answerStatus.text = "답변 완료 >"
        } else {
            cell.answerStatus.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
            cell.answerStatus.text = "대기중 >"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LectureQuestionsDeleteBottomPopUpCell else { return }
        
        let clickedRow = indexPath.row
        self.clickedRow = clickedRow
        
        currentSelectedTableViewCell(clickedRow)
        
        if cell.checkImage.image == UIImage(systemName: "checkmark.circle") {
            cell.checkImage.image = UIImage(systemName: "checkmark.circle.fill")
            cell.checkImage.tintColor = .mainOrange
        } else if cell.checkImage.image == UIImage(systemName: "checkmark.circle.fill") {
            cell.checkImage.image = UIImage(systemName: "checkmark.circle")
            cell.checkImage.tintColor = .systemGray4
        }
        
        print("클릭된 cell IndexPath is \(indexPath.row)")
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func currentSelectedTableViewCell(_ clickedRow: Int) {
        // Boolean  배열을 생성해서 현재 클릭된 여부를 확인한다.
        currentSelectedRowState[clickedRow].toggle()
    }
}

// MARK: - API

extension LectureQuestionsDeleteBottomPopUpVC {
    func didSuccessPostAPI() {
        self.getDataFromJson()
    }
    
    func didSuccessDeleteQnACell() {
        
    }
}

struct LectureQuestionsDeleteBottomPopUpInput: Encodable {
    
    var id: String
    var token = Constant.token
}

class LectureQuestionsDeleteBottomPopUpVCDataManager {
    
    func postRemoveExpertConsult(param: LectureQuestionsDeleteBottomPopUpInput, viewController: LectureQuestionsDeleteBottomPopUpVC) {
        
        let id = param.id
        
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(id)".data(using: .utf8)!, withName: "qna_id")
            MultipartFormData.append("\(Constant.token)".data(using: .utf8)!, withName: "token")
            
        }, to: "https://api.gongmanse.com/v/member/myqna").response { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
                viewController.didSuccessPostAPI()
                print(response)
            case.failure:
                print("error")
            }
        }
    }
}
