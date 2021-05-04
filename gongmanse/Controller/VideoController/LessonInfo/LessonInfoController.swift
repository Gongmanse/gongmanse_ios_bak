import UIKit

class LessonInfoController: UIViewController {
    
    // MARK: - Properties

    let dataArray = ["#논리철학논고", "#비트겐슈타인", "#논리실증주의", "#루드비히", "#케인즈", "#침묵", "#기호학", "#논리경험주의", "#현대철학"]
    
    private let teachernameLabel = PlainLabel("김우성 선생님", fontSize: 11.5)
    private let lessonnameLabel = PlainLabel("분석명제와 종합명제", fontSize: 17)
    private var sTagsCollectionView: UICollectionView?
    
    private let testButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("TEST", for: .normal)
        button.addTarget(self, action: #selector(presentClickedTagSearchResult), for: .touchUpInside)
        return button
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Actions
    
    // TODO: 정상적으로 Action 메소드가 호출되는지 TEST -> 05.03 OK
    @objc
    func presentClickedTagSearchResult() {
        present(TestSearchController(clickedText: "테스트중"), animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            sTagsCollectionView?.setContentOffset(CGPoint(x: 20,y: 0), animated: false)
        }
    }

    
    // TODO: 태그 클릭 시, 검색결과화면으로 이동하는 메소드
    // TODO: 즐겨찾기 클릭 시, 즐겨칮가 API호출
    // TODO: 평점 클릭 시, 평점 View present (No animation)
    // TODO: 공유 클릭 시, 페이스북 & 카카오톡 View present (No animtaion)
    // TODO: 관련시리즈 클릭 시, 어떤 기준으로 영상리스트를 부르는지는 모르겠으나 영상 리스트 Controller present
    // TODO: 문제풀이는 현재 Zeplin에 업데이트가 안된 상태 -> 안드로이드보고 내용 추가 05.03
    
    
    // MARK: - Helpers

    func configureUI() {
        let sSubjectsUnitContainerView = UIView()
        let paddingConstant = view.frame.height * 0.025
        
        // "DEFAULT" 입력 시, UILabel 자체를 숨김
        let sSubjectLabel = sUnitLabel("DEFAULT", .brown)
        let sUnitLabel01 = sUnitLabel("DEFAULT", .darkGray)
        let sUnitLabel02 = sUnitLabel("DEFAULT", .mainOrange)
        
        // API에서 받아온 값을 레이블에 할당한다.
        sSubjectLabel.labelText = "과목명"
        sUnitLabel01.labelText = "단원명"
        sUnitLabel02.labelText = "챕터명"
        
        // TODO: 정상적으로 view가 보이는지 TEST -> 05.03 OK
        view.backgroundColor = .progressBackgroundColor
        
        // TODO: [UI] 강의 태그 -> 05.04 OK
        view.addSubview(sSubjectsUnitContainerView)
        sSubjectsUnitContainerView.setDimensions(height: 25,
                                                 width: view.frame.width * 0.9)
        sSubjectsUnitContainerView.anchor(top: view.topAnchor,
                                          left: view.leftAnchor,
                                          paddingTop: paddingConstant, paddingLeft: 10)
        
        sSubjectLabel.layer.cornerRadius = 11.5
        sSubjectsUnitContainerView.addSubview(sSubjectLabel)
        sSubjectLabel.anchor(top: sSubjectsUnitContainerView.topAnchor,
                            left: sSubjectsUnitContainerView.leftAnchor,
                            paddingLeft: 2.5,
                            height: 25)
        configuresUnit(sSubjectsUnitContainerView, sSubjectLabel, label: sUnitLabel01)
        configuresUnit(sSubjectsUnitContainerView, sUnitLabel01, label: sUnitLabel02)
                
        // TODO: [UI] 선생님이름 -> 05.04 OK
        sSubjectsUnitContainerView.addSubview(teachernameLabel)
        teachernameLabel.centerY(inView: sSubjectLabel)
        teachernameLabel.anchor(right: sSubjectsUnitContainerView.safeAreaLayoutGuide.rightAnchor,
                                height: 25)
        
        // TODO: [UI] 강의 명 -> 05.04 OK
        sSubjectsUnitContainerView.addSubview(lessonnameLabel)
        lessonnameLabel.anchor(top: sSubjectLabel.bottomAnchor,
                               left: sSubjectLabel.leftAnchor,
                               paddingTop: 10, paddingLeft: 5, height: 20)
        
        // TODO: [UI] 해쉬 태그
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2.5)
        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: 100, height: 20)
        layout.itemSize.height = 20
        sTagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(sTagsCollectionView ?? UICollectionView())
        sTagsCollectionView?.setDimensions(height: 20, width: view.frame.width * 0.9)
        sTagsCollectionView?.anchor(top: lessonnameLabel.bottomAnchor,
                                    left: view.leftAnchor,
                                    paddingTop: 10, paddingLeft: 10)
        configureCollectionView()
        
        
        // TODO: [UI] 즐겨찾기
        
        view.addSubview(testButton)
        testButton.setDimensions(height: 50, width: 100)
        testButton.anchor(left: view.leftAnchor,
                          bottom: view.bottomAnchor)
        
        // TODO: [UI] 평점
        // TODO: [UI] 공유
        // TODO: [UI] 관련 시리즈
        // TODO: [UI] 문제풀이
    }
    
    func configureCollectionView() {
        sTagsCollectionView?.delegate = self
        sTagsCollectionView?.dataSource = self
        sTagsCollectionView?.register(sTagsCell.self, forCellWithReuseIdentifier: "sTagsCell")
        sTagsCollectionView?.backgroundColor = .progressBackgroundColor
        sTagsCollectionView?.isScrollEnabled = true
        sTagsCollectionView?.showsHorizontalScrollIndicator = false
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


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension LessonInfoController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataArray[indexPath.row]
        let cell = sTagsCollectionView?.dequeueReusableCell(withReuseIdentifier: "sTagsCell", for: indexPath) as! sTagsCell
        cell.backgroundColor = .progressBackgroundColor
        cell.cellLabel.text = item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataArray[indexPath.row]
        let itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.appBoldFontWith(size: 10)])
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("DEBUG: 클릭한 셀의 인덱스는 \(indexPath) 입니다.")
    }
}


