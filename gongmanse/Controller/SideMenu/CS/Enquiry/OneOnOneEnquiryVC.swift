//
//  OneOnOneEnquiryVC.swift
//  gongmanse
//
//  Created by taeuk on 2021/03/30.
//

import UIKit

// TableView Empty 상태
enum EmptyState {
    case show, hide
}

class OneOnOneEnquiryVC: UIViewController, EnquiryListState {
    
    var emptyList: EmptyState = .hide{
        didSet{
            switch emptyList {
            case .hide:
                emptyStateManage(state: false)
                
            case .show:
                emptyStateManage(state: true)
            }
        }
    }
    
    
    private let enquiryIdentifier = "EnquiryCell"
    private let emptyImage: UIImageView = {
        var image = UIImageView()
        image.image = UIImage(named: "alert")
        image.sizeToFit()
        image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 110, height: 18)
        label.text = "목록이 없습니다."
        label.font = UIFont(name: "NanumSquareRoundB", size: 16)
        label.textColor = UIColor.rgb(red: 164, green: 164, blue: 164)
        
        return label
    }()
    
    private let emptyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 10
        return stack
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        button.setImage(UIImage(named: "floatingBtn"), for: .normal)
        button.addTarget(self, action: #selector(floatingButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    var pageIndex = 0
    
    var oneOneViewModel: OneOneViewModel? = OneOneViewModel()
        
    var canEnquiryList: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        oneOneViewModel?.reqiestOneOneList(completionHandler: {
            self.emptyStateManage(state: self.canEnquiryList)
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        oneOneViewModel?.delegateTable = self
        oneOneViewModel?.delegateState = self
        
        configuration()
        constraints()
    }

    // 상태관리
    func emptyStateManage(state: Bool) {
        
        tableView.isHidden = !state
        emptyStackView.isHidden = state
        
        emptyStackView.addArrangedSubview(emptyImage)
        emptyStackView.addArrangedSubview(emptyLabel)
        
        view.addSubview(emptyStackView)
        
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                                        
            NSLayoutConstraint(item: emptyStackView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0),
                                             
            NSLayoutConstraint(item: emptyStackView,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerY,
                               multiplier: 0.75,
                               constant: 0)])

        self.tableView.reloadData()
    }
    
    @objc func floatingButtonAction(_ sender: UIButton) {
        
        if Constant.isLogin && Constant.remainPremiumDateInt != nil {
            let enquiryCategoryVC = EnquiryCategoryVC()
            enquiryCategoryVC.enquiryState = .create
            self.navigationController?.pushViewController(enquiryCategoryVC, animated: true)
        } else if Constant.remainPremiumDateInt == nil {
            presentAlert(message: "이용권을 구매해주세요")
        } else {
            presentAlert(message: "로그인 상태와 이용권 구매여부를 확인해주세요.")
        }
    }
}

extension OneOnOneEnquiryVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension OneOnOneEnquiryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oneOneViewModel?.oneOneList?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: enquiryIdentifier, for: indexPath) as? EnquiryCell else { return UITableViewCell() }
        
        if let dataList = oneOneViewModel?.oneOneList?.data[indexPath.row] {
            cell.setList(type: dataList)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let enquiryVC = EnquiryUpdateDeleteVC()
        enquiryVC.oneoneViewModel = oneOneViewModel
        enquiryVC.oneoneModel = oneOneViewModel?.oneOneList?.data[indexPath.row]
        enquiryVC.oneoneListID = oneOneViewModel?.oneOneList?.data[indexPath.row].id
        self.navigationController?.pushViewController(enquiryVC, animated: true)
    }
}

extension OneOnOneEnquiryVC {
    
    func configuration() {
        
        view.addSubview(floatingButton)
        
        let numName = UINib(nibName: enquiryIdentifier, bundle: nil)
        tableView.register(numName, forCellReuseIdentifier: enquiryIdentifier)

        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    func constraints() {
        
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                                        
            NSLayoutConstraint(item: floatingButton,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .trailing,
                               multiplier: 1,
                               constant: -20),
                                             
            NSLayoutConstraint(item: floatingButton,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .bottom,
                               multiplier: 0.85,
                               constant: 0)])
    }
}

extension OneOnOneEnquiryVC: TableReloadData {
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension UICollectionViewCell {
    func presentAlert(message: String) {
        
        let alertSuperView = UIView()
        alertSuperView.backgroundColor
            = UIColor.black.withAlphaComponent(0.77)
        alertSuperView.layer.cornerRadius = 17
        alertSuperView.isHidden = true
        
        let alertLabel = UILabel()
        alertLabel.font = UIFont.appBoldFontWith(size: 12)
        alertLabel.textColor = .white
        
        self.contentView.addSubview(alertSuperView)
        alertSuperView.centerX(inView: self.contentView)
        alertSuperView.anchor(bottom: self.contentView.safeAreaLayoutGuide.bottomAnchor,
                              paddingBottom: 50,
                              width: self.contentView.frame.width * 0.89,
                              height: 37)
        
        alertSuperView.addSubview(alertLabel)
        alertLabel.centerY(inView: alertSuperView)
        alertLabel.centerX(inView: alertSuperView)
        alertLabel.setDimensions(height: 37,
                                 width: self.contentView.frame.width * 0.83)
        alertLabel.textAlignment = .center
        alertLabel.numberOfLines = 0
        
        alertLabel.text = message
        alertSuperView.alpha = 1.0
        alertSuperView.isHidden = false
        UIView.animate(withDuration: 2.0,
                       delay: 1.0,
                       options: .curveEaseIn,
                       animations: { alertSuperView.alpha = 0 },
                       completion: { _ in
                        alertSuperView.removeFromSuperview()
                       })
    }
}
