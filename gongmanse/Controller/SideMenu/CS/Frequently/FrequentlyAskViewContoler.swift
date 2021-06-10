//
//  FrequentlyAskViewContoler.swift
//  gongmanse
//
//  Created by taeuk on 2021/03/30.
//

import UIKit

class FrequentlyAskViewContoler: UIViewController {

    private let questionIdentifier = "AskListCell"
    
    var pageIndex = 0
    //받아오는 곳
    private var questionAsk: [QuestionList] = []
    //questionAsk를 넣고 component 추가해서 나타낼 곳
    private var datamodel: [FrequentlyQnA] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let numName = UINib(nibName: questionIdentifier, bundle: nil)
        tableView.register(numName, forCellReuseIdentifier: questionIdentifier)
        
        let requestAPI = requestQuestionListAPI()
        requestAPI.requestQuetionList { [weak self] result in
            
            self?.questionAsk = result
            
            DispatchQueue.main.async {
                self?.configureList()
                self?.tableView.reloadData()
            }
        }
    }

    func configureList() {
        let modelCount = questionAsk.count
        for i in 0..<modelCount {
            let successQnA = FrequentlyQnA(id: questionAsk[i].id, question: questionAsk[i].sQuestion, Ask: questionAsk[i].sAnswer, expanState: false)
            datamodel.append(successQnA)
        }
        
    }
}

extension FrequentlyAskViewContoler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return datamodel[indexPath.section].expanState ? UITableView.automaticDimension : 0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
        let isExpandBackButton = UIButton(type: .custom)
        isExpandBackButton.backgroundColor = .clear
        isExpandBackButton.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
        isExpandBackButton.addTarget(self, action: #selector(tapExpandCell(_:)), for: .touchUpInside)
        // section내에서 선택시 tag로 objc tapExpandCell 함수와 소통
        isExpandBackButton.tag = section
        
        // Q. 라벨
        let questionMarkLabelSections = UILabel()
        questionMarkLabelSections.text = datamodel[section].questionMark
        
        questionMarkLabelSections.font = UIFont(name: "NanumSquareRoundEB", size: 14)
        questionMarkLabelSections.sizeToFit()
        questionMarkLabelSections.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        questionMarkLabelSections.translatesAutoresizingMaskIntoConstraints = false
        questionMarkLabelSections.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        questionMarkLabelSections.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        // 질문 리스트 라벨
        let questionTextLableSections = UILabel()
        questionTextLableSections.font = UIFont(name: "NanumSquareRoundB", size: 14)
        questionTextLableSections.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        questionTextLableSections.numberOfLines = 0
        questionTextLableSections.sizeToFit()
        questionTextLableSections.translatesAutoresizingMaskIntoConstraints = false
        questionTextLableSections.text = datamodel[section].question
        questionTextLableSections.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true

        // expand 버튼
        let expandAllowImage = UIImageView()

        expandAllowImage.image = UIImage(named: "noticeShow")
        
        
        // Q라벨과 질문리스트 담을 스택뷰
        let sectionLabelStacks = UIStackView()
        sectionLabelStacks.axis = .horizontal
        sectionLabelStacks.spacing = 3
        sectionLabelStacks.alignment = .top
        sectionLabelStacks.distribution = .fillProportionally
        sectionLabelStacks.translatesAutoresizingMaskIntoConstraints = false
        sectionLabelStacks.heightAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
        
        sectionLabelStacks.addArrangedSubview(questionMarkLabelSections)
        sectionLabelStacks.addArrangedSubview(questionTextLableSections)
        
        
        headerView.addSubview(expandAllowImage)
        headerView.addSubview(sectionLabelStacks)
        headerView.addSubview(isExpandBackButton)
        
        sectionLabelStacks.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10).isActive = true
        sectionLabelStacks.trailingAnchor.constraint(equalTo: expandAllowImage.leadingAnchor, constant: -12).isActive = true
        sectionLabelStacks.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        sectionLabelStacks.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true
        
        
        expandAllowImage.translatesAutoresizingMaskIntoConstraints = false
        expandAllowImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        expandAllowImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        expandAllowImage.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        expandAllowImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        isExpandBackButton.translatesAutoresizingMaskIntoConstraints = false
        isExpandBackButton.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        isExpandBackButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        isExpandBackButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        isExpandBackButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        
        return headerView
    }
    // 수정 전
    @objc func tapExpandCell(_ sender: UIButton) {
        
        let sectionNumber = sender.tag
        datamodel[sectionNumber].expanState = !datamodel[sectionNumber].expanState
        
        if datamodel[sectionNumber].expanState {
            
            tableView.reloadSections(IndexSet(sectionNumber...sectionNumber), with: .automatic)
        }
        tableView.reloadSections(IndexSet(sectionNumber...sectionNumber), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        footerView.backgroundColor = UIColor.rgb(red: 237, green: 237, blue: 237)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
    
}

extension FrequentlyAskViewContoler: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return questionAsk.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: questionIdentifier, for: indexPath) as? AskListCell else { return UITableViewCell() }
        
        cell.askTextLabel.text = datamodel[indexPath.section].Ask
        cell.askMarkLabel.text = datamodel[indexPath.section].AskMark
        
        return cell
    }
    
}
