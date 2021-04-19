//
//  ProgressMainVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit

protocol ProgressMainVCDelegate: class {
    func pushCellVC(indexPath: IndexPath)
}


class ProgressMainVC: UIViewController {
    
    //MARK: - Properties
    
    // 항목이 있다면 -> tableViewCell에 데이터를 보여준다.
    // 항목이 없다면 -> Views > ProgressLearning > EmptyStateView 에 있는 Cell을 보여준다.
    // init 메소드를 활용하여 ProgressLearningVC로부터 받을 예정.
    
    weak var delegate: ProgressMainVCDelegate?
    
    // 학년을 선택하지 않고 단원을 클릭 시, 경고창을 띄우기 위한 Index
    var isChooseGrade: Bool = false
    
    // 진도학습 목록에 데이터가 있는지 여부를 판단할 Index
    var isLesson: Bool = true
    
    private var progressDataList: [ProgressBodyModel]?      // 리스트 받아오는 모델
    private var getGradeData: SubjectGetDataModel?          // 서버에서 학년 받아오는모델
    
    var pageIndex: Int!
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
            // 버튼 타이틀 데이터
            self?.configureButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureTableView()
        
        let requestProgress = ProgressListAPI(subject: 34, grade: "모든", gradeNum: 0, offset: 0, limit: 20)
        requestProgress.requestProgressDataList { [weak self] result in
            self?.progressDataList = result
            DispatchQueue.main.async {
                self?.tableview.reloadData()
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
        tableview.register(UINib(nibName: "ProgressMainCell", bundle: nil), forCellReuseIdentifier: "ProgressMainCell")
        tableview.register(UINib(nibName: "EmptyStateViewCell", bundle: nil), forCellReuseIdentifier: "EmptyStateViewCell")
    }
    
    // Button
    func configureButton() {
        let borderWidth = 2
        let borderColor = #colorLiteral(red: 1, green: 0.5102320482, blue: 0.1604259853, alpha: 1)
        
        gradeBtn.layer.borderWidth = CGFloat(borderWidth)
        gradeBtn.setTitle(getGradeData?.sGrade, for: .normal)
        gradeBtn.titleLabel?.font = .appBoldFontWith(size: 12)
        gradeBtn.layer.borderColor = borderColor.cgColor
        gradeBtn.layer.cornerRadius = 13
        
        chapterBtn.layer.borderWidth = CGFloat(borderWidth)
        chapterBtn.layer.borderColor = borderColor.cgColor
        chapterBtn.titleLabel?.font = .appBoldFontWith(size: 12)
        chapterBtn.layer.cornerRadius = 13
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
            return progressDataList?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLesson {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressMainCell", for: indexPath) as? ProgressMainCell else { return UITableViewCell() }
            
            
            
            cell.selectionStyle = .none
            cell.gradeTitle.text = progressDataList?[indexPath.row].title
            cell.totalRows.text = progressDataList?[indexPath.row].totalLecture
            
            cell.gradeLabel.textColor = UIColor(hex: progressDataList?[indexPath.row].subjectColor ?? "")
            cell.subjectLabel.text = progressDataList?[indexPath.row].subject
            cell.subjectColor.backgroundColor = UIColor(hex: progressDataList?[indexPath.row].subjectColor ?? "")
            
            // 리팩토링 예정
            if progressDataList?[indexPath.row].grade == "초등" {
                cell.gradeLabel.text = "초"
            }else if progressDataList?[indexPath.row].grade == "중등" {
                cell.gradeLabel.text = "중"
            }else if progressDataList?[indexPath.row].grade == "고등" {
                cell.gradeLabel.text = "고"
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyStateViewCell", for: indexPath) as! EmptyStateViewCell
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
            self.delegate?.pushCellVC(indexPath: indexPath)
        } else {
            print("DEBUG: 빈 페이지 클릭중")
        }
    }
}
