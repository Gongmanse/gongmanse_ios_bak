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


class ProgressMainVC: UIViewController {
    
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
    private var progressBodyDataList: [ProgressBodyModel]?      // 리스트 받아오는 모델
    private var progressHeaderData: ProgressHeaderModel?
    private var getGradeData: SubjectGetDataModel?          // 서버에서 학년 받아오는모델
    
    var pageIndex: Int!
    var sendChapter: [String] = []
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var gradeBtn: UIButton!
    @IBOutlet weak var chapterBtn: UIButton!
     
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // 서버에서 학년 받아오기
        let getfilter = getFilteringAPI()
        getfilter.getFilteringData { [weak self] result in
            self?.getGradeData = result
            self?.gradeBtn.setTitle(self?.getGradeData?.sGrade, for: .normal)
            
            let changeGrade = self?.changeGrade(string: self?.getGradeData?.sGrade ?? "")
            let changeGradeNumber = self?.changeGradeNumber(string: self?.getGradeData?.sGrade ?? "")
            
            self?.requestProgressList(subject: 34,
                                      grade: changeGrade ?? "",
                                      gradeNum: changeGradeNumber ?? 0,
                                      offset: 0,
                                      limit: 20)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureTableView()
        // 버튼 타이틀 데이터
        configureButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeGradeTitle(_:)), name: NSNotification.Name.getGrade, object: nil)
    }
    
    
    @objc func changeGradeTitle(_ sender: Notification) {
        
        guard let getGradeTitle: String = sender.userInfo?["grade"] as? String else { return }
        let gradeTitle = changeGrade(string: getGradeTitle)
        let gradeNumber = changeGradeNumber(string: getGradeTitle)
        
        
        gradeBtn.setTitle(getGradeTitle, for: .normal)
        requestProgressList(subject: 34, grade: gradeTitle, gradeNum: gradeNumber, offset: 0, limit: 20)

    }
    
    
    func requestProgressList(subject: Int, grade: String, gradeNum: Int, offset: Int, limit: Int) {
        let requestProgress = ProgressListAPI(subject: subject,
                                              grade: grade,
                                              gradeNum: gradeNum,
                                              offset: offset,
                                              limit: limit)
        // 넘겨줄 주소
        
        requestProgress.requestProgressDataList { [weak self] result in
            self?.progressBodyDataList = result.body
            self?.progressHeaderData = result.header
            self?.isLesson = self?.progressHeaderData?.totalRows == "0" ? false : true
            self?.sendChapter.removeAll()
            for i in 0..<(self?.progressBodyDataList!.count)! {
                let tt = self?.progressBodyDataList?[i].title ?? ""
                self?.sendChapter.append(tt)
            }
            
            DispatchQueue.main.async {

                self?.tableview.reloadData()
            }
        }
    }
    
    // ViewModel로 이사 전
    func changeGrade(string: String) -> String {
        var title = ""
        if string.hasPrefix("초등") {
            title = "초등"
        }else if string.hasPrefix("중학") {
            title = "중등"
        }else if string.hasPrefix("고등") {
            title = "고등"
        }else {
            title = "모든"
        }
        return title
    }
    
    func changeGradeNumber(string: String) -> Int {
        var numbers = 0
        let arr = ["1","2","3","4","5","6"]
        for i in arr {
            numbers = Int(string.filter{String($0) == String(i)}) ?? 0
            if numbers != 0 {
                break
            }
        }
        return numbers
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
        let borderColor = #colorLiteral(red: 1, green: 0.5102320482, blue: 0.1604259853, alpha: 1)
        
        gradeBtn.layer.borderWidth = CGFloat(borderWidth)
        gradeBtn.setTitle(getGradeData?.sGrade, for: .normal)
        gradeBtn.titleLabel?.font = .appBoldFontWith(size: 13)
        gradeBtn.layer.borderColor = borderColor.cgColor
        gradeBtn.layer.cornerRadius = 13
        
        chapterBtn.layer.borderWidth = CGFloat(borderWidth)
        chapterBtn.layer.borderColor = borderColor.cgColor
        chapterBtn.titleLabel?.font = .appBoldFontWith(size: 13)
        chapterBtn.layer.cornerRadius = 13
        chapterBtn.setTitle("모든 단원", for: .normal)
    }
    
    
    //MARK: - Actions
    
    // 모든 학년
    @IBAction func selectedGrade(_ sender: Any) {
        let popupVC = ProgressPopupVC()
        popupVC.selectedBtnIndex = .grade
        isChooseGrade = true
        
        // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
        popupVC.view.frame = self.view.bounds
        self.present(popupVC, animated: true, completion: nil)
    }
    
    // 모든 단원
    @IBAction func selectedChapter(_ sender: Any) {
        if isChooseGrade {
            let popupVC = ProgressPopupVC()
            popupVC.selectedBtnIndex = .chapter
            popupVC.chapters = sendChapter
            // 팝업 창이 한쪽으로 쏠려서 view 경계 지정
            popupVC.view.frame = self.view.bounds
            self.present(popupVC, animated: true, completion: nil)
        } else {
            // 경고창
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
            
            // 리팩토링 예정
            if progressBodyDataList?[indexPath.row].grade == "초등" {
                cell.gradeLabel.text = "초"
            }else if progressBodyDataList?[indexPath.row].grade == "중등" {
                cell.gradeLabel.text = "중"
            }else if progressBodyDataList?[indexPath.row].grade == "고등" {
                cell.gradeLabel.text = "고"
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
}
