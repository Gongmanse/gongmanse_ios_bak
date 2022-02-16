import UIKit
import BottomPopup
import Alamofire

protocol ExpertConsultTVCDelegate: AnyObject {
    func expertConsultPassSortedIdSettingValue(_ expertConsultSortedIndex: Int)
}

class ExpertConsultTVC: UIViewController, BottomPopupDelegate {
    
    // 전체 삭제 기능
    private var deleteStateList = [Bool]()
    @IBOutlet weak var deleteModeView: UIView!
    @IBOutlet weak var deleteAllSelectBtn: UIButton!
    @IBAction func deleteSelectedItem(_ sender: Any) {
        var currentTrueIndex = [Int]()
        var temp = [ExpertModelData]()
        for (index, selected) in deleteStateList.enumerated() {
            if selected {
                currentTrueIndex.append(index)
            } else {
                temp.append(self.tableViewInputData[index])
            }
        }
        
        // 삭제항목 선택 카운트 체크
        if currentTrueIndex.count > 0 {
            let alert = UIAlertController(title: "삭제", message: "선택하신 \(currentTrueIndex.count)개 항목을 삭제하시겠습니까?", preferredStyle: .alert)
    
            let ok = UIAlertAction(title: "확인", style: .default) { (_) in
                self.actionDelete(currentTrueIndex, temp)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
            alert.addAction(ok)
            alert.addAction(cancel)

            self.present(alert, animated: true, completion: nil)
        } else {
            presentAlert(message: "삭제할 항목을 선택해주세요.")
        }
    }
    private var deleteCount = 0
    private func actionDelete(_ currentTrueIndex: [Int], _ temp: [ExpertModelData]) {
        if currentTrueIndex.count > 1 {
            var ids: String = ""
            for deleteIdx in currentTrueIndex {
                if let id = self.tableViewInputData[deleteIdx].cu_id {
                   ids.append("\(id),")
                }
            }
            
            // sql 에서 IN 명령어 사용으로 변경하여 다중항목 삭제처리는 쉼표로 구분
            let range = ids.startIndex..<ids.index(before: ids.endIndex)
            ExpertConsultTVCDataManager().postRemoveExpertConsult(id: "\(ids[range])", viewController: self)
        } else {
            if let id = self.tableViewInputData[currentTrueIndex[0]].cu_id {
                ExpertConsultTVCDataManager().postRemoveExpertConsult(id: id, viewController: self)
            }
        }
        deleteCount = currentTrueIndex.count
        var remainCnt = (Int(expertConsult?.totalNum ?? "0") ?? 0) - self.deleteCount
        if remainCnt < 0 {
            remainCnt = 0
        }
        expertConsult?.totalNum = "\(remainCnt)"
        
        tableViewInputData = temp
        deleteStateList.removeAll()
        for _ in tableViewInputData.indices {
            deleteStateList.append(deleteAllSelectBtn.isSelected)
        }
        
//        self.tableView.reloadData()
    }
    
    @IBAction func deleteAllSelect(_ sender: Any) {
        deleteAllSelectBtn.isSelected.toggle()
        deleteStateList.removeAll()
        for _ in tableViewInputData.indices {
            deleteStateList.append(deleteAllSelectBtn.isSelected)
        }
        tableView.reloadData()
    }
    
    
//    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var countAll: UILabel!
    @IBOutlet weak var filteringBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollBtn: UIButton!
    @IBAction func scrollToTop(_ sender: Any) {
        let indexPath = NSIndexPath(row: NSNotFound, section: 0)
        tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
    
    var inputSortNum = 4
    
    var isDeleteModeOff: Bool = true {
        didSet {
            deleteAllSelectBtn?.isSelected = false
            tableView?.reloadData()
            deleteModeView?.isHidden = isDeleteModeOff
        }
    }
    
    var pageIndex: Int!
    var expertConsult: ExpertModels?
    var tableViewInputData: [ExpertModelData] = []
    
    private let emptyCellIdentifier = "EmptyTableViewCell"
    
    var sortedId: Int? {
        didSet {
            tableViewInputData.removeAll()
            deleteStateList.removeAll()
//            tableView.reloadData()
            getDataFromJson(offset: 0)
        }
    }
    var isLoading = false
    
    var delegate: ExpertConsultTVCDelegate?
    
    var height: CGFloat = 240
    var presentDuration: Double = 0.2
    var dismissDuration: Double = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
                
        //테이블 뷰 빈칸 숨기기
//        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        //xib 셀 등록
        tableView.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(expertConsultFilterNoti(_:)), name: NSNotification.Name("expertConsultFilterText"), object: nil)
        
        
        // 맨위로 스크롤 기능 추가
        DispatchQueue.main.async {
            self.scrollBtn.applyShadowWithCornerRadius(color: .black, opacity: 1, radius: 5, edge: AIEdge.Bottom, shadowSpace: 3)
        }
        
        // 전체 선택 삭제 기능 추가
        deleteAllSelectBtn.setImage(UIImage(named: "checkTrue"), for: .selected)
        deleteAllSelectBtn.setTitleColor(.black, for: .normal)
        deleteAllSelectBtn.setTitleColor(.black, for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDeleteModeOff = true
        
    }
    
    @objc func expertConsultFilterNoti(_ sender: NotificationCenter) {
        let filterButtonTitle = UserDefaults.standard.object(forKey: "expertConsultFilterText")
        filteringBtn.setTitle(filterButtonTitle as? String, for: .normal)
    }
    
    func getDataFromJson(offset: Int) {
        print("Expert getDataFromJson : \(offset)")
        isLoading = true
        
        switch sortedId {
        case 0:
            inputSortNum = 4
        case 1:
            inputSortNum = 1
        case 2:
            inputSortNum = 2
        case 3:
            inputSortNum = 3
        default:
            inputSortNum = 4
        }
        
        if let url = URL(string: "\(apiBaseURL)/v/member/myconsultation?token=\(Constant.token)&offset=\(offset)&limit=20&sort_id=\(inputSortNum)") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.isLoading = false
                
                guard let data = data else { return }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(ExpertModels.self, from: data) {
//                    print(json.data)
                    DispatchQueue.main.async {
                        for _ in json.data {
                            self.deleteStateList.append(self.deleteAllSelectBtn.isSelected)
                        }
                        
                        self.tableViewInputData.append(contentsOf: json.data)
                        self.expertConsult = json
                        self.textSettings(Int(self.expertConsult?.totalNum ?? "0") ?? 0)
                        
                        self.tableView.reloadData()
                    }
                }
                
            }.resume()
        }
    }
    
    func textSettings(_ totalNum: Int) {
        
        let strCount = String(totalNum).withCommas()
        self.countAll.text = "총 \(strCount)개"
        
        //비디오 총 개수 부분 오렌지 색으로 변경
        let attributedString = NSMutableAttributedString(string: countAll.text!, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: (countAll.text! as NSString).range(of: String(totalNum)))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: (countAll.text! as NSString).range(of: strCount))
        
        self.countAll.attributedText = attributedString
    }
    
    @IBAction func alignment(_ sender: Any) {
        let popupVC = self.storyboard?.instantiateViewController(identifier: "ExpertConsultBottomPopUpVC") as! ExpertConsultBottomPopUpVC
        popupVC.height = height
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.popupDelegate = self
        popupVC.delegate = self
        popupVC.sortedItem = self.sortedId
        present(popupVC, animated: true)
    }
}


//MARK: - tableView delegate
extension ExpertConsultTVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = self.expertConsult else { return 0 }
        if value.totalNum == "0" {
            return 1
        } else {
            return tableViewInputData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let value = self.expertConsult else { return UITableViewCell() }
        
        if value.totalNum == "0" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as! EmptyTableViewCell
            cell.emptyLabel.text = "상담 목록이 없습니다."
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertConsultTVCell") as! ExpertConsultTVCell
            
            guard let _ = self.expertConsult else { return cell }
            
            let indexData = tableViewInputData[indexPath.row]
            let defaultLink = fileBaseURL
            let thumbnailImageURL = indexData.sFilepaths ?? ""
            let thumbnailURL = URL(string: defaultLink + "/" + thumbnailImageURL)
            let profileImageURL = indexData.sProfile ?? ""
            let profileURL = URL(string: fileBaseURL + "/" + profileImageURL)
            
            cell.consultTitle.text = indexData.sQuestion
            cell.nickName.text = indexData.sNickname
            cell.profileImage.contentMode = .scaleAspectFill
            cell.upLoadDate.text = indexData.dtRegister
            
            if indexData.iAnswer == "1" {
                cell.answerStatus.backgroundColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
                cell.answerStatus.text = "답변 완료 >"
            } else {
                cell.answerStatus.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                cell.answerStatus.text = "대기중 >"
            }
            
            DispatchQueue.main.async {
                if profileImageURL == ""{
                    cell.profileImage.image = UIImage(named: "extraSmallUserDefault")
                }else {
                    cell.profileImage.sd_setImage(with: profileURL)
                }
                
                if indexData.sFilepaths == nil {
                    cell.consultThumbnail.contentMode = .scaleAspectFit
                    cell.consultThumbnail.image = UIImage(named: "app_icon")
                } else {
                    cell.consultThumbnail.contentMode = .scaleAspectFill
                    cell.consultThumbnail.sd_setImage(with: thumbnailURL) { img, err, type, URL in
                        if img == nil {
                            cell.consultThumbnail.contentMode = .scaleAspectFit
                            cell.consultThumbnail.image = UIImage(named: "app_icon")
                        }
                    }
                }
            }
            
            cell.deleteButton.isHidden = isDeleteModeOff
            cell.deleteView.isHidden = isDeleteModeOff
            cell.deleteButton.tag = indexPath.row
            
            cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
            
            cell.deleteButton.isSelected = deleteStateList[indexPath.row]
            return cell
        }
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        guard let json = self.expertConsult else { return }
        guard let _ = json.data[sender.tag].cu_id else { return }

        sender.isSelected.toggle()
//        let inputData = ExpertConsultInput(id: id)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        deleteStateList[sender.tag] = sender.isSelected
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if !sender.isSelected {
            deleteAllSelectBtn.isSelected = false
        }
        
//        self.tableViewInputData.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
//        ExpertConsultTVCDataManager().postRemoveExpertConsult(param: inputData, viewController: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let value = self.expertConsult else { return 0 }
        
        if value.totalNum == "0" {
            return tableView.frame.height - 70
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = self.expertConsult else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if value.totalNum == "0" {
//            presentAlert(message: "전문가 상담 목록이 없습니다.")
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExpertConsultationDetailVC") as! ExpertConsultationDetailVC
            vc.receiveData = expertConsult?.data[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.frame.height < cell.frame.height * CGFloat(indexPath.row - 1) {// 1번째 셀 hide.
            scrollBtn.isHidden = false
        } else if indexPath.row == 0 {// 1번째 셀 show.
            scrollBtn.isHidden = true
        }
        
        if indexPath.row == self.tableViewInputData.count - 1 && !self.isLoading
            && self.tableViewInputData.count < (Int(self.expertConsult?.totalNum ?? "0") ?? 0) {
            //더보기
            getDataFromJson(offset: self.tableViewInputData.count)
        }
    }
}

extension ExpertConsultTVC: ExpertConsultBottomPopUpVCDelegate {
    func expertConsultPassSortedIdRow(_ expertConsultSortedIdRowIndex: Int) {
        
        if expertConsultSortedIdRowIndex == 0 {          // 1 번째 Cell
            self.sortedId = 0
        } else if expertConsultSortedIdRowIndex == 1 {   // 2 번째 Cell
            self.sortedId = 1
        } else {   // 3 번째 Cell
            self.sortedId = 2
        }
        
        delegate?.expertConsultPassSortedIdSettingValue(self.sortedId!)
    }
}

// MARK: - API

extension ExpertConsultTVC {
    func didSuccessPostAPI() {
        
        tableViewInputData.removeAll()
        tableView.reloadData()
        
        getDataFromJson(offset: 0)
        //self.tableView.reloadData()
//        self.view.layoutIfNeeded()
    }
}


struct ExpertConsultInput: Encodable {
    
    var id: String
    var token = Constant.token
}

class ExpertConsultTVCDataManager {
    
    func postRemoveExpertConsult(id: String, viewController: ExpertConsultTVC) {
        AF.upload(multipartFormData: { MultipartFormData in
            MultipartFormData.append("\(id)".data(using: .utf8)!, withName: "con_id")
            MultipartFormData.append("\(Constant.token)".data(using: .utf8)!, withName: "token")

        }, to: "\(apiBaseURL)/v/member/myconsultation").response { (response) in
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
