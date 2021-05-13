import UIKit

class LessonInfoController: UIViewController {
    
    // MARK: - Properties
    
    let dataArray = ["#논리철학논고", "#비트겐슈타인", "#논리실증주의", "#루드비히", "#케인즈", "#침묵", "#기호학", "#논리경험주의", "#현대철학"]
    let buttonSize = CGRect(x: 0, y: 0, width: 40, height: 40)
    private let teachernameLabel = PlainLabel("김우성 선생님", fontSize: 11.5)
    private let lessonnameLabel = PlainLabel("분석명제와 종합명제", fontSize: 17)
    private var sTagsCollectionView: UICollectionView?
    private lazy var bookmarkButton = TopImageBottomTitleView(frame: buttonSize,
                                                              title: "즐겨찾기",
                                                              image: UIImage(systemName: "heart.fill")! )
    private lazy var rateLessonButton = TopImageBottomTitleView(frame: buttonSize,
                                                                title: "평점",
                                                                image: UIImage(systemName: "star.fill")! )
    private lazy var shareLessonButton = TopImageBottomTitleView(frame: buttonSize,
                                                                 title: "공유",
                                                                 image: UIImage(systemName: "link")! )
    private lazy var relatedSeriesButton = TopImageBottomTitleView(frame: buttonSize,
                                                                   title: "관련시리즈",
                                                                   image: UIImage(systemName: "tray.full")!)
    private lazy var problemSolvingButton = TopImageBottomTitleView(frame: buttonSize,
                                                                    title: "문제풀이",
                                                                    image: UIImage(systemName: "book.fill")!)
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Actions
    
    // TODO: 정상적으로 Action 메소드가 호출되는지 TEST -> 05.03 OK
    @objc func presentClickedTagSearchResult() {
        present(TestSearchController(clickedText: "테스트중"), animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            sTagsCollectionView?.setContentOffset(CGPoint(x: 20,y: 0), animated: false)
        }
    }
    
    // TODO: tintColor 변경은 추후에 API 호출메소드에서 성공 시, 변경하는 것으로 로직 실행할 예정. 05.04
    @objc func handleBookmarkAction(sender: UIView) { bookmarkButton.viewTintColor = .mainOrange }
    @objc func handleRateLessonAction() { rateLessonButton.viewTintColor = .mainOrange }
    @objc func handleShareLessonAction() { shareLessonButton.viewTintColor = .mainOrange }
    @objc func handleRelatedSeriesAction() { relatedSeriesButton.viewTintColor = .mainOrange }
    @objc func handleProblemSolvingAction() { problemSolvingButton.viewTintColor = .mainOrange }
    
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
        
        // TODO: [UI] 해쉬 태그 -> 05.04 UI 완성
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2.5)
        layout.scrollDirection = .horizontal
        layout.itemSize.height = 20
        sTagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(sTagsCollectionView ?? UICollectionView())
        sTagsCollectionView?.setDimensions(height: 20, width: view.frame.width * 0.9)
        sTagsCollectionView?.anchor(top: lessonnameLabel.bottomAnchor,
                                    left: view.leftAnchor,
                                    paddingTop: 10, paddingLeft: 10)
        configureCollectionView()
        
        // TODO: [UI] 즐겨찾기, 평점, 공유, 관련시리즈, 문제풀이 -> 05.04 UI 완성
        let stack = UIStackView(arrangedSubviews:
                                    [bookmarkButton,rateLessonButton,shareLessonButton,relatedSeriesButton,problemSolvingButton])
        let buttonHeight = view.frame.width * 0.12
        let buttonWidth = view.frame.width * 0.1
        bookmarkButton.setDimensions(height: buttonHeight, width: buttonWidth)
        rateLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
        shareLessonButton.setDimensions(height: buttonHeight, width: buttonWidth)
        relatedSeriesButton.setDimensions(height: buttonHeight, width: buttonWidth)
        problemSolvingButton.setDimensions(height: buttonHeight, width: buttonWidth)
        view.addSubview(stack)
        stack.isUserInteractionEnabled = true
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        stack.spacing = buttonWidth
        stack.alignment = .leading
        stack.centerX(inView: view)
        stack.anchor(top: sTagsCollectionView?.bottomAnchor, paddingTop: 10)
        configureAddActions()
    }
    
    func configureCollectionView() {
        sTagsCollectionView?.delegate = self
        sTagsCollectionView?.dataSource = self
        sTagsCollectionView?.register(sTagsCell.self, forCellWithReuseIdentifier: "sTagsCell")
        sTagsCollectionView?.backgroundColor = .progressBackgroundColor
        sTagsCollectionView?.isScrollEnabled = true
        sTagsCollectionView?.showsHorizontalScrollIndicator = false
    }
    
    func configureAddActions() {
        let bookmarkButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkAction))
        let rateLessonButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleRateLessonAction))
        let shareLessonButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleShareLessonAction))
        let relatedSeriesButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleRelatedSeriesAction))
        let problemSolvingButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleProblemSolvingAction))
        bookmarkButton.addGestureRecognizer(bookmarkButtonGesture)
        rateLessonButton.addGestureRecognizer(rateLessonButtonGesture)
        shareLessonButton.addGestureRecognizer(shareLessonButtonGesture)
        relatedSeriesButton.addGestureRecognizer(relatedSeriesButtonGesture)
        problemSolvingButton.addGestureRecognizer(problemSolvingButtonGesture)
    }
}


// MARK: - Common UI Attribute setting Method

extension LessonInfoController {

    func configuresUnit(_ containerView: UIView, _ leftView: UIView, label: UILabel) {
        containerView.addSubview(label)
        label.anchor(top: containerView.topAnchor, left: leftView.rightAnchor,
                     paddingLeft: 2.5, height: 25)
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
        cell.cellLabel.text = item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataArray[indexPath.row]
        let itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.appBoldFontWith(size: 10)])
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataArray[indexPath.row]
        let vc = TestSearchController(clickedText: data)
        present(vc, animated: true)
    }
}

