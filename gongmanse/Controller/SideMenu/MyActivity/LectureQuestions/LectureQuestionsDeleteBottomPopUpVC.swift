import UIKit
import BottomPopup

class LectureQuestionsDeleteBottomPopUpVC: BottomPopupViewController {

    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var lectureTitle: PaddingLabel!
    @IBOutlet weak var allCountView: UIView!
    @IBOutlet weak var countLabel: PaddingLabel!
    @IBOutlet weak var tableView: UITableView!
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func allSelect(_ sender: Any) {
        
    }
    
    @IBAction func deleteButton(_ sender: Any) {
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LectureQuestionsDeleteBottomPopUpCell", for: indexPath) as? LectureQuestionsDeleteBottomPopUpCell else { return UITableViewCell() }
        
        return cell
    }
    
    
}
