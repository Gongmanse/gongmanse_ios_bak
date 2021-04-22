//
//  ProgressOthers.swift
//  gongmanse
//
//  Created by 김우성 on 2021/03/08.
//

import UIKit

class ProgressOthers: UIViewController {

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
    
    private var othersDataList: [ProgressBodyModel]?
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var gradeBtn: UIButton!
    @IBOutlet weak var chapterBtn: UIButton!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureButton()
        configureTableView()
        
        let othersProgress = ProgressListAPI(subject: 37, grade: "모든", gradeNum: 0, offset: 20, limit: 20)
        othersProgress.requestProgressDataList { [weak self] result in
            self?.othersDataList = result.body
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
        tableview.register(UINib(nibName: mainCellIdentifier, bundle: nil), forCellReuseIdentifier: mainCellIdentifier)
        tableview.register(UINib(nibName: emptyCellIdentifier, bundle: nil), forCellReuseIdentifier: emptyCellIdentifier)
    }
    
    // Button
    func configureButton() {
        let borderWidth = 2
        let borderColor = #colorLiteral(red: 1, green: 0.5102320482, blue: 0.1604259853, alpha: 1)
        
        gradeBtn.layer.borderWidth = CGFloat(borderWidth)
        chapterBtn.layer.borderWidth = CGFloat(borderWidth)
        
        gradeBtn.layer.borderColor = borderColor.cgColor
        chapterBtn.layer.borderColor = borderColor.cgColor
        
        gradeBtn.layer.cornerRadius = 13
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

extension ProgressOthers: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLesson {
            return othersDataList?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLesson {
            let cell = tableView.dequeueReusableCell(withIdentifier: mainCellIdentifier, for: indexPath) as! ProgressMainCell
            cell.selectionStyle = .none
            cell.totalRows.text = othersDataList?[indexPath.row].totalLecture
            cell.gradeTitle.text = othersDataList?[indexPath.row].title
            cell.gradeLabel.textColor = UIColor(hex: othersDataList?[indexPath.row].subjectColor ?? "")
            cell.subjectLabel.text = othersDataList?[indexPath.row].subject
            cell.subjectColor.backgroundColor = UIColor(hex: othersDataList?[indexPath.row].subjectColor ?? "")
            
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
            let indexID = othersDataList?[indexPath.row].progressId ?? ""

            
            self.delegate?.pushCellVC(indexPath: indexPath, progressID: indexID)
        } else {
            print("DEBUG: 빈 페이지 클릭중")
        }
    }
}
