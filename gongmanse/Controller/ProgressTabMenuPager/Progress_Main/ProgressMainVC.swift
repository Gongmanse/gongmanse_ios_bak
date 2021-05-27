//
//  ProgressMainVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit

protocol ProgressPresenterDelegate: class {
    func pushCellVC(indexPath: IndexPath, progressID: String)
}


class ProgressMainVC: UIViewController, ProgressInfinityScroll {
    
    //MARK: - Properties
    
    // 항목이 있다면 -> tableViewCell에 데이터를 보여준다.
    // 항목이 없다면 -> Views > ProgressLearning > EmptyStateView 에 있는 Cell을 보여준다.
    // init 메소드를 활용하여 ProgressLearningVC로부터 받을 예정.
    
    weak var delegate: ProgressPresenterDelegate?
    
    // 학년을 선택하지 않고 단원을 클릭 시, 경고창을 띄우기 위한 Index
    private var chooseGrade: String = "모든 학년"
    
    // 진도학습 목록에 데이터가 있는지 여부를 판단할 Index
    private var isLesson: Bool = true
    private var activity: UIActivityIndicatorView!
    
    
    private let mainCellIdentifier = "ProgressMainCell"
    private let emptyCellIdentifier = "EmptyStateViewCell"
    private var progressBodyDataList: [ProgressBodyModel]?       // 리스트 받아오는 모델 body
    private var progressHeaderData: ProgressHeaderModel?         // 리스트 받아오는 모델 header
    private var getGradeData: SubjectGetDataModel?               // 서버에서 학년 받아오는모델
    
    // 전역변수 사용하기 위한 변수들
    private var localGradeTitle = ""
    private var localGradeNumber = 0
    
    // API 통신 시 고정 값
    private let mainSubjectNumber = 34
    private let mainLimitNumber = 20
    
    var pageIndex: Int!
    var sendChapter: [String] = []
    private let mainViewModel = ProgressMainViewModel()
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var gradeBtn: UIButton!
    @IBOutlet weak var chapterBtn: UIButton!

    // infinity Protocol
    var islistMore: Bool?
    
    var listCount: Int = 0
    
    func scrollMethod() {
        listCount += 20
        requestProgressList(subject: mainSubjectNumber,
                            grade: localGradeTitle,
                            gradeNum: localGradeNumber,
                            offset: listCount,
                            limit: mainLimitNumber)
    }
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 토큰 있을 때 없을 때
        if Constant.token == "" {
            gradeBtn.setTitle("모든 학년", for: .normal)
            requestProgressList(subject: mainSubjectNumber, grade: "모든", gradeNum: 0, offset: 0, limit: mainLimitNumber)
            
        } else {
            // 서버에서 학년 받아오기, 토큰 필요
            let getfilter = getFilteringAPI()
            getfilter.getFilteringData { [weak self] result in
                self?.getGradeData = result
                self?.gradeBtn.setTitle(self?.getGradeData?.sGrade, for: .normal)
                
                let changeGrade = self?.mainViewModel.transformGrade(string: self?.getGradeData?.sGrade ?? "")
                let changeGradeNumber = self?.mainViewModel.transformGradeNumber(string: self?.getGradeData?.sGrade ?? "")
                
                self?.requestProgressList(subject: self?.mainSubjectNumber ?? 0,
                                          grade: changeGrade ?? "",
                                          gradeNum: changeGradeNumber ?? 0,
                                          offset: 0,
                                          limit: self?.mainLimitNumber ?? 0)
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureTableView()
        // 버튼 타이틀 데이터
        configureButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeGradeTitle(_:)), name: .getGrade, object: nil)
    }
    
    // 학년 popup에서 선택 시 API불러올 메소드
    @objc func changeGradeTitle(_ sender: Notification) {
        // ex) 모든학년 받아옴
        guard let getGradeTitle: String = sender.userInfo?["grade"] as? String else { return }
        // 모든에 해당하는 강의 나타냄
        let gradeTitle = mainViewModel.transformGrade(string: getGradeTitle)
        let gradeNumber = mainViewModel.transformGradeNumber(string: getGradeTitle)
        
        
        gradeBtn.setTitle(getGradeTitle, for: .normal)
        
        requestProgressList(subject: mainSubjectNumber,
                            grade: gradeTitle,
                            gradeNum: gradeNumber,
                            offset: 0,
                            limit: mainLimitNumber)
        
    }
    
    // 진도학습 목록 API 받아오는 메소드
    func requestProgressList(subject: Int, grade: String, gradeNum: Int, offset: Int, limit: Int) {
        
        localGradeTitle = grade
        localGradeNumber = gradeNum
        
        let requestProgress = ProgressListAPI(subject: subject,
                                              grade: grade,
                                              gradeNum: gradeNum,
                                              offset: offset,
                                              limit: limit)
        // 넘겨줄 주소
        
        requestProgress.requestProgressDataList { [weak self] result in
            
            self?.progressHeaderData = result.header
            // totalRows = 0 이면 빈 화면 출력
            self?.isLesson = self?.progressHeaderData?.totalRows == "0" ? false : true
            self?.islistMore = Bool(self?.progressHeaderData?.isMore ?? "")
            
            if self?.islistMore == false {
                self?.listCount = 0
            }
            
            
            if offset == 0 {
                self?.progressBodyDataList = result.body
                
                
                self?.sendChapter.removeAll()
                for i in 0..<(self?.progressBodyDataList!.count)! {
                    let tt = self?.progressBodyDataList?[i].title ?? ""
                    self?.sendChapter.append(tt)
                }
                self?.reloadData(table: self?.tableview ?? UITableView())

            }else {
                DispatchQueue.global().async {
                    sleep(1)
                    
                    self?.progressBodyDataList?.append(contentsOf: result.body!)
                    
                    DispatchQueue.main.async {
                        self?.tableview.reloadData()
                        self?.tableview.tableFooterView?.isHidden = true
                    }
                    
                }
                
                
//                self?.tableview.beginUpdates()
//                self?.tableview.insertRows(at: [IndexPath(row: 20, section: 0)], with: .automatic)
//                self?.tableview.endUpdates()
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
        let borderWidth = 2
        let borderColor = UIColor.mainOrange
        
        
        gradeBtn.setTitle(getGradeData?.sGrade, for: .normal)
        gradeBtn.titleLabel?.font = .appBoldFontWith(size: 13)
        gradeBtn.layer.borderColor = borderColor.cgColor
        gradeBtn.layer.cornerRadius = 13
        gradeBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경"), for: .normal)
        gradeBtn.layer.borderWidth = 3.5
        
        
        chapterBtn.layer.borderColor = borderColor.cgColor
        chapterBtn.titleLabel?.font = .appBoldFontWith(size: 13)
        chapterBtn.layer.cornerRadius = 13
        chapterBtn.setBackgroundImage(#imageLiteral(resourceName: "검색배경"), for: .normal)
        chapterBtn.layer.borderWidth = 3.5
        chapterBtn.setTitle("모든 단원", for: .normal)
    }
    
    
    //MARK: - Actions
    
    // 모든 학년
    @IBAction func selectedGrade(_ sender: UIButton) {
        let popupVC = ProgressPopupVC()
        popupVC.selectedBtnIndex = .grade
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
    
    // 모든 단원
    @IBAction func selectedChapter(_ sender: UIButton) {
                
        if gradeBtn.titleLabel?.text == "모든 학년" {
            presentAlert(message: "학년을 먼저 선택해 주세요.")
        } else {
            
            let popupVC = ProgressPopupVC()
            popupVC.selectedBtnIndex = .chapter
            popupVC.chapters = sendChapter
            // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
            popupVC.view.frame = self.view.bounds
            self.present(popupVC, animated: true, completion: nil)
        }
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension ProgressMainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLesson {
            return progressBodyDataList?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLesson {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: mainCellIdentifier, for: indexPath) as? ProgressMainCell else { return UITableViewCell() }
            
            
            
            cell.selectionStyle = .none
            cell.gradeTitle.text = progressBodyDataList?[indexPath.row].title
            cell.totalRows.text = progressBodyDataList?[indexPath.row].totalLecture
            
            cell.gradeLabel.textColor = UIColor(hex: progressBodyDataList?[indexPath.row].subjectColor ?? "")
            cell.subjectLabel.text = progressBodyDataList?[indexPath.row].subject
            cell.subjectColor.backgroundColor = UIColor(hex: progressBodyDataList?[indexPath.row].subjectColor ?? "")
            
            
            let gradeTitle = progressBodyDataList?[indexPath.row].grade
            
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
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as! EmptyStateViewCell
            cell.alertMessage.text = "영상 목록이 없습니다."
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
            let indexID = progressBodyDataList?[indexPath.row].progressId ?? ""
            
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
