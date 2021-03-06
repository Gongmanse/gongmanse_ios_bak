//
//  ProgressSocialVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit


class ProgressSocialVC: UIViewController, ProgressInfinityScroll {
    
    

    //MARK: - Properties
    
    // 항목이 있다면 -> tableViewCell에 데이터를 보여준다.
    // 항목이 없다면 -> Views > ProgressLearning > EmptyStateView 에 있는 Cell을 보여준다.
    // init 메소드를 활용하여 ProgressLearningVC로부터 받을 예정.
    
    weak var delegate: ProgressPresenterDelegate?
    
    // 학년을 선택하지 않고 단원을 클릭 시, 경고창을 띄우기 위한 Index
    private var isChooseGrade: Bool = false
    
    // 진도학습 목록에 데이터가 있는지 여부를 판단할 Index
    private var isLesson: Bool = true
    
    private let mainCellIdentifier = "ProgressMainCell"
    private let emptyCellIdentifier = "EmptyStateViewCell"
    
    var pageIndex: Int!
    var sendChapter: [String] = []
    private let mainViewModel = ProgressMainViewModel()
    
    
    private var socialHeaderDataList: ProgressHeaderModel?
    private var socialBodyDataList: [ProgressBodyModel]?
    var bodycopyDataList: [ProgressBodyModel]?
    private var getGradeData: SubjectGetDataModel?
    
    private var localGradeTitle = ""
    private var localGradeNumber = 0
    
    // API 통신 시 고정 값
    private let socialSubjectNumber = 35
    private let socialLimitNumber = 20
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var gradeBtn: UIButton!
    @IBOutlet weak var chapterBtn: UIButton!
    
     
    var islistMore: Bool?
    
    var listCount: Int = 0
    
    func scrollMethod() {
        listCount += 20
        requestProgressSocialList(subject: socialSubjectNumber,
                            grade: localGradeTitle,
                            gradeNum: localGradeNumber,
                            offset: listCount,
                            limit: socialLimitNumber)
    }
    
    var _selectedGrade: String = "모든 학년"
    var _selectedUnit: String = "모든 단원"
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureButton()
        configureTableView()
        
        // 토큰 있을 때 없을 때
        if Constant.token == "" {
            gradeBtn.setTitle("모든 학년", for: .normal)
            chapterBtn.setTitle("모든 단원", for: .normal)
            
            requestProgressSocialList(subject: socialSubjectNumber,
                                       grade: "모든",
                                       gradeNum: 0,
                                       offset: 0,
                                       limit: socialLimitNumber)
            
        } else {
            // 서버에서 학년 받아오기, 토큰 필요
            let getfilter = getFilteringAPI()
            getfilter.getFilteringData { [weak self] result in
                self?.getGradeData = result
                self?.gradeBtn.setTitle((self?.getGradeData?.sGrade ?? "").isEmpty ? "모든 학년" : self!.getGradeData!.sGrade!, for: .normal)
                self?.chapterBtn.setTitle("모든 단원", for: .normal)
                
                let changeGrade = self?.mainViewModel.transformGrade(string: self?.getGradeData?.sGrade ?? "")
                let changeGradeNumber = self?.mainViewModel.transformGradeNumber(string: self?.getGradeData?.sGrade ?? "")
                
                self?.requestProgressSocialList(subject: self?.socialSubjectNumber ?? 0,
                                          grade: changeGrade ?? "",
                                          gradeNum: changeGradeNumber ?? 0,
                                          offset: 0,
                                          limit: self?.socialLimitNumber ?? 0)
            }

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeGradeTitle(_:)), name: .getGrade, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(acceptChapter(_:)), name: .getSubject, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func acceptChapter(_ sender: Notification) {
        
        
        guard let userinfo = sender.userInfo else { return }
        guard let chapterName: String = userinfo["chapterName"] as? String else { return }
        guard let index: Int = userinfo["chapterNumber"] as? Int else { return }
        guard let body = bodycopyDataList else { return }
        
        _selectedUnit = chapterName
        
        chapterBtn.setTitle(chapterName, for: .normal)
        
        if index == 0 {
            socialBodyDataList = bodycopyDataList
            self.tableview.reloadData()
            return
        }
        
        if body[index - 1].title == chapterName {
            socialBodyDataList = bodycopyDataList?.filter{$0.title == chapterName}
            self.tableview.reloadData()
        }
    }
    
    // 학년 popup에서 선택 시 API불러올 메소드
    @objc func changeGradeTitle(_ sender: Notification) {
        // ex) 모든학년 받아옴
        guard let getGradeTitle: String = sender.userInfo?["grade"] as? String else { return }
        
        _selectedGrade = getGradeTitle
        _selectedUnit = "모든 단원"
        // 모든에 해당하는 강의 나타냄
        let gradeTitle = mainViewModel.transformGrade(string: getGradeTitle)
        let gradeNumber = mainViewModel.transformGradeNumber(string: getGradeTitle)
        
        
        gradeBtn.setTitle(getGradeTitle, for: .normal)
        chapterBtn.setTitle("모든 단원", for: .normal)
        
        requestProgressSocialList(subject: socialSubjectNumber,
                            grade: gradeTitle,
                            gradeNum: gradeNumber,
                            offset: 0,
                            limit: socialLimitNumber)
        
    }
    
    func requestProgressSocialList(subject: Int, grade: String, gradeNum: Int, offset: Int, limit: Int) {
        
        localGradeTitle = grade
        localGradeNumber = gradeNum
        
        
        let socialProgress = ProgressListAPI(subject: subject,
                                             grade: grade,
                                             gradeNum: gradeNum,
                                             offset: offset,
                                             limit: limit)
        
        socialProgress.requestProgressDataList { [weak self] result in
            self?.socialHeaderDataList = result.header
            // totalRows = 0 이면 빈 화면 출력
            self?.isLesson = self?.socialHeaderDataList?.totalRows == "0" ? false : true
            self?.islistMore = Bool(self?.socialHeaderDataList?.isMore ?? "")
            
            if self?.islistMore == false {
                self?.listCount = 0
            }
            
            
            if offset == 0 {
                self?.socialBodyDataList = result.body
                self?.bodycopyDataList = result.body
                
                self?.sendChapter.removeAll()
                self?.sendChapter.append("모든 단원")
                for i in 0..<(self?.socialBodyDataList?.count ?? 0) {
                    let tt = self?.socialBodyDataList?[i].title ?? ""
                    self?.sendChapter.append(tt)
                }
                self?.reloadData(table: self?.tableview ?? UITableView())

            }else {
                DispatchQueue.global().async {
                    sleep(1)
                    
                    if self?._selectedUnit == "모든 단원" {
                        self?.socialBodyDataList?.append(contentsOf: result.body!)
                    } else {
                        self?.socialBodyDataList?.append(contentsOf: result.body!.filter{$0.title == self?._selectedUnit})
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableview.reloadData()
                        self?.tableview.tableFooterView?.isHidden = true
                    }
                    
                }
            }
        }
    }
    
    //MARK: - Helper functions
    
    // TableView
    func configureTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView() 
        
        // Cell 등록
        tableview.register(UINib(nibName: mainCellIdentifier, bundle: nil), forCellReuseIdentifier: mainCellIdentifier)
        tableview.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
    }
    
    // Button
    func configureButton() {
        
        let borderColor = UIColor.mainOrange
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            gradeBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경_pad"), for: .normal)
        } else {
            gradeBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경"), for: .normal)
        }
//        gradeBtn.layer.borderWidth = 3.5
        gradeBtn.layer.borderColor = borderColor.cgColor
        gradeBtn.layer.cornerRadius = 13
        gradeBtn.titleLabel?.font = .appBoldFontWith(size: 13)
        gradeBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        
        chapterBtn.titleLabel?.font = .appBoldFontWith(size: 13)
        if UIDevice.current.userInterfaceIdiom == .pad {
            chapterBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경_pad"), for: .normal)
        } else {
            chapterBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경"), for: .normal)
        }
//        chapterBtn.layer.borderWidth = 3.5
        chapterBtn.layer.borderColor = borderColor.cgColor
        chapterBtn.layer.cornerRadius = 13
        chapterBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        chapterBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) // 과목 버튼 글자 Inset
    }
    
    
    //MARK: - Actions
    
    // 모든 학년
    @IBAction func selectedGrade(_ sender: Any) {
        let popupVC = ProgressPopupVC()
        popupVC.selectedBtnIndex = .grade
        popupVC._selectedItem = _selectedGrade
        isChooseGrade = true
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
    
    // 모든 단원
    @IBAction func selectedChapter(_ sender: Any) {
        if gradeBtn.titleLabel?.text == "모든 학년" {
            presentAlert(message: "학년을 먼저 선택해 주세요.")
        } else {
            
            let popupVC = ProgressPopupVC()
            popupVC.selectedBtnIndex = .chapter
            popupVC.chapters = sendChapter
            popupVC._selectedItem = _selectedUnit
            // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
            popupVC.view.frame = self.view.bounds
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension ProgressSocialVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLesson {
            return socialBodyDataList?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLesson {
            let cell = tableView.dequeueReusableCell(withIdentifier: mainCellIdentifier, for: indexPath) as! ProgressMainCell
            
            cell.selectionStyle = .none
            cell.totalRows.text = socialBodyDataList?[indexPath.row].totalLecture
            cell.gradeTitle.text = socialBodyDataList?[indexPath.row].title
            cell.gradeLabel.textColor = UIColor(hex: socialBodyDataList?[indexPath.row].subjectColor ?? "")
            cell.subjectLabel.text = socialBodyDataList?[indexPath.row].subject
            cell.subjectColor.backgroundColor = UIColor(hex: socialBodyDataList?[indexPath.row].subjectColor ?? "")
            
            let gradeTitle = socialBodyDataList?[indexPath.row].grade
            
            if gradeTitle == "초등" {
                cell.gradeLabel.text = OneGrade.element.oneWord
            } else if gradeTitle == "중등" {
                cell.gradeLabel.text = OneGrade.middle.oneWord
            }else if gradeTitle == "고등" {
                cell.gradeLabel.text = OneGrade.high.oneWord
            }
            
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            
            if islistMore == true && indexPath.row == totalRows - 1 {
                scrollMethod()
                
            }
            tableView.isScrollEnabled = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as! EmptyStateViewCell
            tableView.isScrollEnabled = false
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLesson {
            return 70
        } else {
            return tableview.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLesson {
            print("DEBUG: 상세페이지 이동")
            
            let indexID = socialBodyDataList?[indexPath.row].progressId ?? ""
            
            self.delegate?.pushCellVC(indexPath: indexPath, progressID: indexID)
        } else {
            print("DEBUG: 빈 페이지 클릭중")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && islistMore == true{
            // print("this is the last cell")
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)

            self.tableview.tableFooterView = spinner
            self.tableview.tableFooterView?.isHidden = false
        }
    }
    
}

