import UIKit
import BottomPopup

protocol ExpertConsultBottomPopUpVCDelegate: class {
    func expertConsultPassSortedIdRow(_ expertConsultSortedIdRowIndex: Int)
}

class ExpertConsultBottomPopUpVC: BottomPopupViewController {
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var sortedItem: Int?
    weak var delegate: ExpertConsultBottomPopUpVCDelegate?
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    private var expertConsultFilterText = ""
    
    var titleNames = ["최신순", "조회순", "답변 완료순"]
    
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

extension ExpertConsultBottomPopUpVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "ExpertConsultBottomPopUpCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) as! ExpertConsultBottomPopUpCell
        
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
        let cell = tableView.cellForRow(at: indexPath) as! ExpertConsultBottomPopUpCell
        
        expertConsultFilterText = titleNames[indexPath.row]
        
        UserDefaults.standard.setValue(expertConsultFilterText, forKey: "expertConsultFilterText")
        
        NotificationCenter.default.post(name: NSNotification.Name("expertConsultFilterText"), object: nil)
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
        delegate?.expertConsultPassSortedIdRow(indexPath.row)
    }
}
