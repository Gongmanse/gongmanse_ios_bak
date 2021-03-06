import UIKit
import BottomPopup

protocol LectureQuestionsBottomPopUpVCDelegate: class {
    func lectureQuestionsPassSortedIdRow(_ noteListSortedIdRowIndex: Int)
}

class LectureQuestionsBottomPopUpVC: BottomPopupViewController {
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var sortedItem: Int?
    weak var delegate: LectureQuestionsBottomPopUpVCDelegate?
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    private var lectureQuestionsFilterText = ""
    
    var titleNames = ["최신순", "이름순", "과목순", "평점순"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblCategory.text = "정렬"
        categoryView.layer.addBorder([.bottom], color: #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1), width: 3.0)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func closeBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
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

extension LectureQuestionsBottomPopUpVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "LectureQuestionsBottomPopUpCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) as! LectureQuestionsBottomPopUpCell
        
        cell.selectTitle.text = titleNames[indexPath.row]
        cell.checkImage.isHidden = true
        
        if let sortedItem = sortedItem {
            print("\(#function) \(sortedItem)")
            if sortedItem == indexPath.row {
                cell.selectTitle.textColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
                cell.checkImage.isHidden = false
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LectureQuestionsBottomPopUpCell
        
        lectureQuestionsFilterText = titleNames[indexPath.row]
        
        UserDefaults.standard.setValue(lectureQuestionsFilterText, forKey: "lectureQuestionsFilterText")
        
        NotificationCenter.default.post(name: NSNotification.Name("lectureQuestionsFilterText"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            cell.selectTitle.textColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.checkImage.isHidden = false
            self.dismiss(animated: true)
        } else if indexPath.row == 1 {
            cell.selectTitle.textColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.checkImage.isHidden = false
            self.dismiss(animated: true)
        } else if indexPath.row == 2 {
            cell.selectTitle.textColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.checkImage.isHidden = false
            self.dismiss(animated: true)
        } else if indexPath.row == 3 {
            cell.selectTitle.textColor = #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1)
            cell.checkImage.isHidden = false
            self.dismiss(animated: true)
        }
        
        sortedItem = indexPath.row
        delegate?.lectureQuestionsPassSortedIdRow(indexPath.row)
    }
}
