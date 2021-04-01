//
//  OneonOneEnquiryViewController.swift
//  gongmanse
//
//  Created by taeuk on 2021/03/30.
//

import UIKit

// TableView Empty 상태
enum EmptyState {
    case show, hide
}

class OneonOneEnquiryViewController: UIViewController {

    
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
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let numName = UINib(nibName: enquiryIdentifier, bundle: nil)
        tableView.register(numName, forCellReuseIdentifier: enquiryIdentifier)
        
//        emptyStateManage(state: false)
        
        view.addSubview(floatingButton)
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

        
    }
    
    @objc func floatingButtonAction(_ sender: UIButton) {
        let enquiryCategoryVC = EnquiryCategoryVC()
        self.navigationController?.pushViewController(enquiryCategoryVC, animated: true)
    }
}

extension OneonOneEnquiryViewController: UITableViewDelegate {
    
}

extension OneonOneEnquiryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: enquiryIdentifier, for: indexPath) as? EnquiryCell else { return UITableViewCell() }
        cell.textLabel?.text = "A"
        return cell
    }
}
