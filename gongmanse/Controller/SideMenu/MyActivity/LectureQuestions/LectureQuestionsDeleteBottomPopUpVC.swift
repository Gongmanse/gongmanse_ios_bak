import UIKit
import BottomPopup

class LectureQuestionsDeleteBottomPopUpVC: BottomPopupViewController {

    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var lectureTitle: PaddingLabel!
    @IBOutlet weak var allCountView: UIView!
    @IBOutlet weak var countLabel: PaddingLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allSelectButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allCountView.layer.addBorder([.top], color: #colorLiteral(red: 0.9294117647, green: 0.462745098, blue: 0, alpha: 1), width: 3.0)
        allSelectButton.layer.addBorder([.top, .left, .right, .bottom], color: .systemGray, width: 0.7)
        deleteButton.layer.addBorder([.top, .right, .bottom], color: .systemGray, width: 0.7)
        
    }

    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func allSelectButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LectureQuestionsDeleteBottomPopUpCell", for: indexPath) as? LectureQuestionsDeleteBottomPopUpCell else { return UITableViewCell() }
        
        return cell
    }
    
    
}
