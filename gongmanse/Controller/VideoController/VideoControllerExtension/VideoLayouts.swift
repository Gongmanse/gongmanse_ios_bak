import UIKit


// MARK: - Constraint Method
extension VideoController {
    
    /// 세로모드 제약조건 정의
    func setConstraintInPortrait() {
        
        /* VideoContainerView */
        view.addSubview(videoContainerView)
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        // Portrait 제약조건 정의
        videoContainerViewPorTraitWidthConstraint
            = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.width)
        videoContainerViewPorTraitHeightConstraint
            = videoContainerView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.57)
        videoContainerViewPorTraitTopConstraint
            = videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        videoContainerViewPorTraitLeftConstraint
            = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        // Landscape 제약조건 정의
        videoContainerViewLandscapeWidthConstraint
            = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.width)
        videoContainerViewLandscapeHeightConstraint
            = videoContainerView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.57)
        videoContainerViewLandscapeTopConstraint
            = videoContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        videoContainerViewLandscapeLeftConstraint
            = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        
        /* playPauseButton(동영상 클릭 시, 재생 및 일시정지 버튼 */
        view.addSubview(playPauseButton)
        playPauseButton.centerX(inView: videoContainerView)
        playPauseButton.centerY(inView: videoContainerView)
        playPauseButton.setDimensions(height: 150, width: 150)
        
        /* videoForwardTimeButton(동영상 앞으로 가기 버튼) */
        view.addSubview(videoForwardTimeButton)
        videoForwardTimeButton.setDimensions(height: 20, width: 20)
        videoForwardTimeButton.centerY(inView: videoContainerView)
        videoForwardTimeButton.anchor(left: playPauseButton.rightAnchor,
                                      paddingLeft: 10)
        
        /* videoForwardTimeButton(동영상 앞으로 가기 버튼) */
        view.addSubview(videoBackwardTimeButton)
        videoBackwardTimeButton.setDimensions(height: 20, width: 20)
        videoBackwardTimeButton.centerY(inView: videoContainerView)
        videoBackwardTimeButton.anchor(right: playPauseButton.leftAnchor,
                                       paddingRight: 10)
        
        /* subtitleLabel(자막) */
        view.addSubview(subtitleLabel)
        subtitleLabel.anchor(left: videoContainerView.leftAnchor,
                             bottom: videoContainerView.bottomAnchor,
                             width: view.frame.width)
        
        /* CustomTabBar */
        view.addSubview(customMenuBar)
        customMenuBar.delegate = self
        customMenuBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Portrait 제약조건 정의
        customMenuBarPorTraitLeftConstraint
            = customMenuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        customMenuBarPorTraitRightConstraint
            = customMenuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        customMenuBarPorTraitTopConstraint
            = customMenuBar.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        customMenuBarPorTraitHeightConstraint
            //            = customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06)
            = customMenuBar.heightAnchor.constraint(equalToConstant: 44)
        customMenuBarPorTraitWidthConstraint
            = customMenuBar.widthAnchor.constraint(equalToConstant: view.frame.width)
        
        // Landscape 제약조건 정의
        customMenuBarLandscapeTopConstraint
            = customMenuBar.topAnchor.constraint(equalTo: view.topAnchor)
        customMenuBarLandscapeRightConstraint
            = customMenuBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        customMenuBarLandscapeLeftConstraint
            = customMenuBar.leadingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        customMenuBarLandscapeHeightConstraint
            //            = customMenuBar.heightAnchor.constraint(equalToConstant: view.frame.height * 0.06)
            = customMenuBar.heightAnchor.constraint(equalToConstant: 44)
        
        /* TeacherInfoView */
        view.addSubview(lessonInfoView)
        lessonInfoView.translatesAutoresizingMaskIntoConstraints = false
        teacherInfoFoldConstraint?.priority = UILayoutPriority(rawValue: 999)
        teacherInfoUnfoldConstraint?.priority = UILayoutPriority(rawValue: 999)
        teacherInfoFoldConstraint
            = lessonInfoView.heightAnchor.constraint(equalToConstant: 5)
        teacherInfoUnfoldConstraint
            = lessonInfoView.heightAnchor.constraint(equalToConstant: 180)
        
        // Portrait 제약조건 정의
        lessonInfoViewPorTraitTopConstraint
            = lessonInfoView.topAnchor.constraint(equalTo: customMenuBar.bottomAnchor)
        lessonInfoViewPorTraitCenterXConstraint
            = lessonInfoView.centerXAnchor.constraint(equalTo: customMenuBar.centerXAnchor)
        lessonInfoViewPorTraitWidthConstraint
            = lessonInfoView.widthAnchor.constraint(equalTo: view.widthAnchor)
        
        // Landscape 제약조건 정의
        lessonInfoViewLandscapeTopConstraint
            = lessonInfoView.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        lessonInfoViewLandscapeLeftConstraint
            = lessonInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        lessonInfoViewLandscapeRightConstraint
            = lessonInfoView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        
        /* TeacherInfoView (top/bottom)BorderLine */
        lessonInfoView.addSubview(topBorderLine)
        lessonInfoView.addSubview(bottomBorderLine)
        topBorderLine.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderLine.translatesAutoresizingMaskIntoConstraints = false
        topBorderLinePorTraitTopConstraint
            = topBorderLine.topAnchor.constraint(equalTo: lessonInfoView.topAnchor)
        topBorderLinePorTraitCenterXConstraint
            = topBorderLine.centerXAnchor.constraint(equalTo: lessonInfoView.centerXAnchor)
        topBorderLinePorTraitHeightConstraint
            = topBorderLine.heightAnchor.constraint(equalToConstant: 5)
        topBorderLinePorTraitWidthConstraint
            = topBorderLine.widthAnchor.constraint(equalTo: lessonInfoView.widthAnchor)
        bottomBorderLinePorTraitBottomConstraint
            = bottomBorderLine.bottomAnchor.constraint(equalTo: lessonInfoView.bottomAnchor)
        bottomBorderLinePorTraitCenterXConstraint
            = bottomBorderLine.centerXAnchor.constraint(equalTo: lessonInfoView.centerXAnchor)
        bottomBorderLinePorTraitHeightConstraint
            = bottomBorderLine.heightAnchor.constraint(equalToConstant: 5)
        bottomBorderLinePorTraitWidthConstraint
            = bottomBorderLine.widthAnchor.constraint(equalTo: lessonInfoView.widthAnchor)
        
        /* pageCollectionView */
        // Portrait 제약조건 정의
        pageCollectionViewPorTraitLeftConstraint
            = pageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        pageCollectionViewPorTraitRightConstraint
            = pageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        pageCollectionViewPorTraitBottomConstraint
            = pageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pageCollectionViewPorTraitTopConstraint
            = pageCollectionView.topAnchor.constraint(equalTo: lessonInfoView.bottomAnchor)
        
        // Landscape 제약조건 정의
        pageCollectionViewLandscapeLeftConstraint
            = pageCollectionView.leadingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        pageCollectionViewLandscapeRightConstraint
            = pageCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        pageCollectionViewLandscapeBottomConstraint
            = pageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pageCollectionViewLandscapeTopConstraint
            = pageCollectionView.topAnchor.constraint(equalTo: customMenuBar.bottomAnchor)
        
        /* playerController View */
        self.videoContainerView.addSubview(playerController.view)
        playerController.view.anchor(top: videoContainerView.topAnchor,
                                     left: videoContainerView.leftAnchor)
    }
    
    ///  화면전환에 따른 Constraint 적용
    func changeConstraintToVideoContainer(isPortraitMode: Bool) {
        
        if !isPortraitMode { // 세로모드인 경우
            print("DEBUG: 세로모드")
            portraitConstraint(true)
            landscapeConstraint(false)
            topBorderLine.alpha = 1
            bottomBorderLine.alpha = 1
        } else {            // 가로모드인 경우
            print("DEBUG: 가로모드")
            portraitConstraint(false)
            landscapeConstraint(true)
            topBorderLine.alpha = 0
            bottomBorderLine.alpha = 0
        }
    }
    
    /// Portait 제약조건 활성화 메소드
    func portraitConstraint(_ isActive: Bool) {
        
        pageCollectionView.reloadData()
        customMenuBar.setNeedsLayout()
        
        // "videoContainerView" 제약조건
        videoContainerViewPorTraitWidthConstraint?.isActive = isActive
        videoContainerViewPorTraitHeightConstraint?.isActive = isActive
        videoContainerViewPorTraitTopConstraint?.isActive = isActive
        videoContainerViewPorTraitLeftConstraint?.isActive = isActive
        
        // "customTabBar" 제약조건
        customMenuBarPorTraitLeftConstraint?.isActive = isActive
        customMenuBarPorTraitRightConstraint?.isActive = isActive
        customMenuBarPorTraitTopConstraint?.isActive = isActive
        customMenuBarPorTraitHeightConstraint?.isActive = isActive
        
        // "teacherInfoView" 제약조건
        lessonInfoViewPorTraitTopConstraint?.isActive = isActive
        lessonInfoViewPorTraitCenterXConstraint?.isActive = isActive
        lessonInfoViewPorTraitWidthConstraint?.isActive = isActive
        teacherInfoUnfoldConstraint?.isActive = !isActive
        teacherInfoFoldConstraint?.isActive = isActive
        
        // "topBorderLine" 제약조건
        // "bottomBorderLine" 제약조건
        topBorderLinePorTraitTopConstraint?.isActive = isActive
        topBorderLinePorTraitCenterXConstraint?.isActive = isActive
        topBorderLinePorTraitHeightConstraint?.isActive = isActive
        topBorderLinePorTraitWidthConstraint?.isActive = isActive
        bottomBorderLinePorTraitBottomConstraint?.isActive = isActive
        bottomBorderLinePorTraitCenterXConstraint?.isActive = isActive
        bottomBorderLinePorTraitHeightConstraint?.isActive = isActive
        bottomBorderLinePorTraitWidthConstraint?.isActive = isActive
        
        // "pageCollectionView" 제약조건
        pageCollectionViewPorTraitLeftConstraint?.isActive = isActive
        pageCollectionViewPorTraitRightConstraint?.isActive = isActive
        pageCollectionViewPorTraitBottomConstraint?.isActive = isActive
        pageCollectionViewPorTraitTopConstraint?.isActive = isActive
    }
    
    /// Landscape 제약조건 활성화 메소드
    func landscapeConstraint(_ isActive: Bool) {
        
        pageCollectionView.reloadData()
        customMenuBar.setNeedsLayout()
        
        // "videoContainerView" 제약조건
        videoContainerViewLandscapeWidthConstraint?.isActive = isActive
        videoContainerViewLandscapeHeightConstraint?.isActive = isActive
        videoContainerViewLandscapeTopConstraint?.isActive = isActive
        videoContainerViewLandscapeLeftConstraint?.isActive = isActive
        
        // "customTabBar" 제약조건
        customMenuBarLandscapeRightConstraint?.isActive = isActive
        customMenuBarLandscapeTopConstraint?.isActive = isActive
        customMenuBarLandscapeLeftConstraint?.isActive = isActive
        customMenuBarLandscapeHeightConstraint?.isActive = isActive
        customMenuBar.videoMenuBarTabBarCollectionView.reloadData()
        
        // "teacherInfoView" 제약조건
        teacherInfoUnfoldConstraint?.isActive = isActive
        teacherInfoFoldConstraint?.isActive = !isActive
        lessonInfoViewLandscapeTopConstraint?.isActive = isActive
        lessonInfoViewLandscapeLeftConstraint?.isActive = isActive
        lessonInfoViewLandscapeRightConstraint?.isActive = isActive
        
        // TODO: ToggleButton 제약조건
        
        // "pageCollectionView" 제약조건
        pageCollectionViewLandscapeLeftConstraint?.isActive = isActive
        pageCollectionViewLandscapeRightConstraint?.isActive = isActive
        pageCollectionViewLandscapeBottomConstraint?.isActive = isActive
        pageCollectionViewLandscapeTopConstraint?.isActive = isActive
        
        
        // TODO: "TeachInfoView" 제약조건
        // TODO: "CollectionView" 제약조건
    }
}
