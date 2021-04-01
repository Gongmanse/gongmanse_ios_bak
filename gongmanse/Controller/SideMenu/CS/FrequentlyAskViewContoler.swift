//
//  FrequentlyAskViewContoler.swift
//  gongmanse
//
//  Created by taeuk on 2021/03/30.
//

import UIKit

class FrequentlyAskViewContoler: UIViewController {

    private let questionIdentifier = "QuestionListCell"
    let testList = "공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요.공만세 알림을 받고 싶지 않아요."
    private var textList = [
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "갑자기 자막이 나오지 않아요.", expandState: false),
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "공만세 알림을 받고 싶지 않아요.", expandState: false),
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "이번 달 데이터가 얼마 안 남았는데, 와이파이로 동영상을 볼 수 있나요?", expandState: false),
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "추천 영상에 올라온 강의들은 어떤 강의들인가요?", expandState: false),
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "회원가입 전에 동영상 강의를 먼저 보고 싶은데 방법이 있나요?", expandState: false),
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "키워드 검색은 어떤 키워드들을 검색하게 되나요?", expandState: false),
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "문제를 먼저 검색해서 볼 수 있나요?", expandState: false),
        CustomerServiceQuestionModel(questionMark: "Q.", questionList: "동영상 강의 재생이 원활하지 않습니다. 어떻게 해결해야 하나요?", expandState: false)
    ]
    private var askList = [
        CustomerServiceAskModel(askMark: "A.", askList: "갑자기 자막이 나오지 않아요."),
        CustomerServiceAskModel(askMark: "A.", askList: "공만세 알림을 받고 싶지 않아요."),
        CustomerServiceAskModel(askMark: "A.", askList: "이번 달 데이터가 얼마 안 남았는데, 와이파이로 동영상을 볼 수 있나요?"),
        CustomerServiceAskModel(askMark: "A.", askList: "추천 영상에 올라온 강의들은 어떤 강의들인가요?"),
        CustomerServiceAskModel(askMark: "A.", askList: "회원가입 전에 동영상 강의를 먼저 보고 싶은데 방법이 있나요?"),
        CustomerServiceAskModel(askMark: "A.", askList: "키워드 검색은 어떤 키워드들을 검색하게 되나요?"),
        CustomerServiceAskModel(askMark: "A.", askList: "문제를 먼저 검색해서 볼 수 있나요?"),
        CustomerServiceAskModel(askMark: "A.", askList: "동영상 강의 재생이 원활하지 않습니다. 어떻게 해결해야 하나요?"),
        CustomerServiceAskModel(askMark: "A.", askList: "문제를 먼저 검색해서 볼 수 있나요?")
    ]
    var pageIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    
        
    var isSeletedCell = false
    /* * 다시 살펴 볼 예정
    let questionMarkLabelSection: UILabel = {
       let label = UILabel()
        label.text = "Q."
        label.font = UIFont(name: "NanumSquareRoundEB", size: 14)
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var questionTextLableSection: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundE", size: 14)
//        label.font = .systemFont(ofSize: 14)
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sectionLabelStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let numName = UINib(nibName: questionIdentifier, bundle: nil)
        tableView.register(numName, forCellReuseIdentifier: questionIdentifier)
        
    }

}

extension FrequentlyAskViewContoler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return textList[indexPath.section].expandState ? UITableView.automaticDimension : 0
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
        // section내에서 선택시 tag로 objc함수와 소통
        isExpandBackButton.tag = section
        
        // Q. 라벨
        let questionMarkLabelSections = UILabel()
        questionMarkLabelSections.text = textList[section].questionMark
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
        questionTextLableSections.text = textList[section].questionList
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
//        let constraint = sectionLabelStacks.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
        
        
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
        textList[sectionNumber].expandState = !textList[sectionNumber].expandState
        
        if textList[sender.tag].expandState {
            
            
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
        return textList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: questionIdentifier, for: indexPath) as? QuestionListCell else { return UITableViewCell() }
        
        cell.askLabel.text = askList[indexPath.section].askList
        cell.askMarkLabel.text = askList[indexPath.section].askMark
        
        return cell
    }
    
}
