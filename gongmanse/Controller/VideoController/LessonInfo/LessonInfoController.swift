//
//  LessonInfoController.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/03.
//

import UIKit

private let sSubjectsUnitCellID = "sSubjectsUnitCell"

class LessonInfoController: UIViewController {
    
    // MARK: - Properties


    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    // MARK: - Actions
    
    // TODO: 정상적으로 Action 메소드가 호출되는지 TEST -> 05.03 OK
    @objc
    func presentClickedTagSearchResult() {
        print("DEBUG: 클릭하였습니다.")
        present(TestSearchController(clickedText: "테스트중"), animated: true)
    }

    
    // TODO: 태그 클릭 시, 검색결과화면으로 이동하는 메소드
    // TODO: 즐겨찾기 클릭 시, 즐겨칮가 API호출
    // TODO: 평점 클릭 시, 평점 View present (No animation)
    // TODO: 공유 클릭 시, 페이스북 & 카카오톡 View present (No animtaion)
    // TODO: 관련시리즈 클릭 시, 어떤 기준으로 영상리스트를 부르는지는 모르겠으나 영상 리스트 Controller present
    // TODO: 문제풀이는 현재 Zeplin에 업데이트가 안된 상태 -> 안드로이드보고 내용 추가 05.03
    
    
    // MARK: - Helpers

    
    func configureUI() {

        
        /// "sSubject" 과 "sUint" 레이블을 담을 컨테이너 뷰
        let sSubjectsUnitContainerView = UIView()
        let sSubjectLabel = sUnitLabel("DEFAULT", .brown)
        let sUnitLabel01 = sUnitLabel("DEFAULT", .darkGray)
        let sUnitLabel02 = sUnitLabel("DEFAULT", .blue)
        
        // API에서 받아온 값을 레이블에 할당한다. 없는 경우 "DEFAULT" 넣는다.
        sSubjectLabel.labelText = "과목명"
        sUnitLabel01.labelText = "단원명"
        sUnitLabel02.labelText = "챕터명"
        
        // TODO: 정상적으로 view가 보이는지 TEST -> 05.03 OK
        view.backgroundColor = .progressBackgroundColor
        
        // TODO: [UI] 강의 태그
        view.addSubview(sSubjectsUnitContainerView)
        sSubjectsUnitContainerView.setDimensions(height: 25,
                                                 width: view.frame.width * 0.9)
        sSubjectsUnitContainerView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                          paddingTop: 10, paddingLeft: 10)
        
        sSubjectLabel.layer.cornerRadius = 11.5
        sSubjectsUnitContainerView.addSubview(sSubjectLabel)
        sSubjectLabel.anchor(top: sSubjectsUnitContainerView.topAnchor,
                            left: sSubjectsUnitContainerView.leftAnchor,
                            paddingLeft: 2.5,
                            height: 25)
//        sUnitLabel02.setNeedsDisplay()
//        sUnitLabel02.layoutIfNeeded()
        configuresUnit(sSubjectsUnitContainerView, sSubjectLabel, label: sUnitLabel01)
        configuresUnit(sSubjectsUnitContainerView, sUnitLabel01, label: sUnitLabel02)
                
        // TODO: [UI] 선생님이름
        // TODO: [UI] 강의 명
        // TODO: [UI] 해쉬 태그
        // TODO: [UI] 즐겨찾기
        // TODO: [UI] 평점
        // TODO: [UI] 공유
        // TODO: [UI] 관련 시리즈
        // TODO: [UI] 문제풀이
    }
    

}



// MARK: - Common UI Attribute setting Method

extension LessonInfoController {
    
    func configuresUnit(_ containerView: UIView, _ leftView: UIView, label: UILabel) {
        
        containerView.addSubview(label)
        label.anchor(top: containerView.topAnchor,
                           left: leftView.rightAnchor,
                           paddingLeft: 2.5,
                           height: 25)
    }
}
