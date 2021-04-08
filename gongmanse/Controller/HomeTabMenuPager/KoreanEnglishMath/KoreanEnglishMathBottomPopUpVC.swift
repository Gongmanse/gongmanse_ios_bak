import UIKit
import BottomPopup

class KoreanEnglishMathBottomPopUpVC: BottomPopupViewController {
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    let titleNames = ["전체보기", "시리즈보기", "문제풀이", "노트보기"]

    var tableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
            
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // <---
        tableView.isScrollEnabled = false // <---

        tableView.register(KoreanEnglishMathBottomPopUPTVCell.self, forCellReuseIdentifier: "123")

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(height)
    }
    override var popupHeight: CGFloat {
//        return height ?? CGFloat(300)
        return 500
    }
    
    override var popupTopCornerRadius: CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override var popupPresentDuration: Double {
        return presentDuration ?? 0.2
    }
    
    override var popupDismissDuration: Double {
        return dismissDuration ?? 0.5
    }
    
    override var popupShouldDismissInteractivelty: Bool {
        return shouldDismissInteractivelty ?? true
    }
}

extension KoreanEnglishMathBottomPopUpVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "123")
        cell?.textLabel?.text = titleNames[indexPath.row]
        
        return cell!
    }
    
    
}
