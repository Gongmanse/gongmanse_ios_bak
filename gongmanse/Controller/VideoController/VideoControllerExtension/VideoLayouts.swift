import UIKit


// MARK: - Constraint Method
extension VideoController {
    
    /// 세로모드 제약조건 정의
    func setConstraintInPortrait() {
        let ratio = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(0.9) : CGFloat(1.0)
        
        /* VideoContainerView */
        view.addSubview(videoContainerView)
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        // Portrait 제약조건 정의
        videoContainerViewPorTraitWidthConstraint
            = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.width)
        videoContainerViewPorTraitHeightConstraint
            = videoContainerView.heightAnchor.constraint(equalToConstant: view.frame.width * 9 / 16)
        videoContainerViewPorTraitTopConstraint
            = videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        videoContainerViewPorTraitLeftConstraint
            = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        
        // Landscape 제약조건 정의
        videoContainerViewLandscapeWidthConstraint
            = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.width * ratio)
        videoContainerViewLandscapeHeightConstraint
            = videoContainerView.heightAnchor.constraint(equalToConstant: view.frame.width * ratio *  9 / 16)
        videoContainerViewLandscapeTopConstraint
            = videoContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        videoContainerViewLandscapeLeftConstraint
            = videoContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: -5)
        
        // 전체모드 제약조건 정의
        videoContainerViewFullScreenWidthConstraint
            = videoContainerView.widthAnchor.constraint(equalToConstant: view.frame.height)
        videoContainerViewFullScreenHeightConstraint
            = videoContainerView.heightAnchor.constraint(equalToConstant: view.frame.width)
        videoContainerViewFullScreenTopConstraint
            = videoContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        videoContainerViewFullScreenLeftConstraint
            = videoContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        
        
        /* playPauseButton(동영상 클릭 시, 재생 및 일시정지 버튼 */
        view.addSubview(playPauseButton)
        playPauseButton.centerX(inView: videoContainerView)
        playPauseButton.centerY(inView: videoContainerView)
        playPauseButton.setDimensions(height: 50, width: 50)
        
        view.addSubview(replayButton)
        replayButton.centerX(inView: videoContainerView)
        replayButton.centerY(inView: videoContainerView)
        replayButton.setDimensions(height: 50, width: 50)
        
        /* videoForwardTimeButton(동영상 앞으로 가기 버튼) */
        view.addSubview(videoForwardTimeButton)
        videoForwardTimeButton.setDimensions(height: 28, width: 24)
        videoForwardTimeButton.centerY(inView: videoContainerView)
        videoForwardTimeButton.anchor(left: playPauseButton.rightAnchor,
                                      paddingLeft: 60)
        
        /* videoForwardTimeButton(동영상 앞으로 가기 버튼) */
        view.addSubview(videoBackwardTimeButton)
        videoBackwardTimeButton.setDimensions(height: 28, width: 24)
        videoBackwardTimeButton.centerY(inView: videoContainerView)
        videoBackwardTimeButton.anchor(right: playPauseButton.leftAnchor,
                                       paddingRight: 60)
        
        
        // safeArea 에 자막이 겹치지 않도록 여백 추가
        marginView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(marginView)
        marginView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        marginView.anchor(left: view.leftAnchor,
                          bottom: videoContainerView.bottomAnchor,
                          right: view.rightAnchor)
        marginViewHeight = marginView.heightAnchor.constraint(equalToConstant: 0)
        marginViewHeight!.isActive = true
        
        /* subtitleLabel(자막) */
        view.addSubview(subtitleLabel)
        subtitleLabel.anchor(left: videoContainerView.leftAnchor,
                             bottom: marginView.topAnchor,
                             right: videoContainerView.rightAnchor)
        subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
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
        = customMenuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
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
            = lessonInfoView.heightAnchor.constraint(equalToConstant: 0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            teacherInfoUnfoldConstraint
                = lessonInfoView.heightAnchor.constraint(equalToConstant: 190)
            
            if UIWindow.isLandscape {
                teacherInfoUnfoldConstraint?.constant = view.frame.width * 8.1/16
            } else {
                if let height = lessonInfoController.tagsHeight?.constant {
                    teacherInfoUnfoldConstraint?.constant = 160 + height
                } else {
                    teacherInfoUnfoldConstraint?.constant = 190
                }
            }
        } else {
            teacherInfoUnfoldConstraint
                = lessonInfoView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.43)
        }
        
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
            = lessonInfoView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor)
        lessonInfoViewLandscapeRightConstraint
            = lessonInfoView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        
        /* TeacherInfoView (top/bottom)BorderLine */
        // Portrait 제약조건 정의
        lessonInfoView.addSubview(topBorderLine)
        lessonInfoView.addSubview(bottomBorderLine)
        topBorderLine.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderLine.translatesAutoresizingMaskIntoConstraints = false
        topBorderLinePorTraitTopConstraint
            = topBorderLine.topAnchor.constraint(equalTo: lessonInfoView.topAnchor)
        topBorderLinePorTraitCenterXConstraint
            = topBorderLine.centerXAnchor.constraint(equalTo: lessonInfoView.centerXAnchor)
        topBorderLinePorTraitHeightConstraint
            = topBorderLine.heightAnchor.constraint(equalToConstant: 0)
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
        
        // LandScape 제약조건 정의
        topBorderLineLandScapeCenterXConstraint =
            topBorderLine.centerXAnchor.constraint(equalTo: pageController.centerXAnchor)
        topBorderLineLandScapeHeightConstraint =
            topBorderLine.heightAnchor.constraint(equalToConstant: 0)
        topBorderLineLandScapeTopConstraint =
            topBorderLine.topAnchor.constraint(equalTo: customMenuBar.bottomAnchor)
        topBorderLineLandScapeWidthConstraint =
            topBorderLine.widthAnchor.constraint(equalTo: customMenuBar.widthAnchor)
        
        /* pageCollectionView */
        // Portrait 제약조건 정의
        pageCollectionViewPorTraitLeftConstraint
            = pageController.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        pageCollectionViewPorTraitRightConstraint
            = pageController.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        pageCollectionViewPorTraitBottomConstraint
            = pageController.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pageCollectionViewPorTraitBottomConstraint1
            = pageController.bottomAnchor.constraint(equalTo: pipContainerView.topAnchor)
        pageCollectionViewPorTraitTopConstraint
            = pageController.topAnchor.constraint(equalTo: lessonInfoView.bottomAnchor)
        
        // Landscape 제약조건 정의
        pageCollectionViewLandscapeLeftConstraint
            = pageController.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width * ratio - 5)
        pageCollectionViewLandscapeRightConstraint
            = pageController.rightAnchor.constraint(equalTo: view.rightAnchor)
        pageCollectionViewLandscapeBottomConstraint
            = pageController.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pageCollectionViewLandscapeBottomConstraint1
            = pageController.bottomAnchor.constraint(equalTo: pipContainerView.topAnchor)
        pageCollectionViewLandscapeTopConstraint
            = pageController.topAnchor.constraint(equalTo: customMenuBar.bottomAnchor)
        
        /* playerController View */
        self.videoContainerView.addSubview(playerController.view)
        playerController.view.anchor(top: videoContainerView.topAnchor,
                                     left: videoContainerView.leftAnchor,
                                     bottom: videoContainerView.bottomAnchor,
                                     right: videoContainerView.rightAnchor)
        self.videoContainerView.addSubview(playerController1.view)
        playerController1.view.anchor(top: videoContainerView.topAnchor,
                                     left: videoContainerView.leftAnchor,
                                     bottom: videoContainerView.bottomAnchor,
                                     right: videoContainerView.rightAnchor)
    }
    
    ///  화면전환에 따른 Constraint 적용
    func changeConstraintToVideoContainer(isPortraitMode: Bool) {
        
        if !isPortraitMode { // 세로모드인 경우
            print("DEBUG: 세로모드")
            portraitConstraint(true)
            landscapeConstraint(false)
            topBorderLine.alpha = 1
            bottomBorderLine.alpha = 1
            toggleButton.alpha = 1
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                let height = lessonInfoController.tagsHeight!.constant
                teacherInfoUnfoldConstraint?.constant = 160 + height
            }
        } else {            // 가로모드인 경우
            print("DEBUG: 가로모드")
            portraitConstraint(false)
            landscapeConstraint(true)
            topBorderLine.alpha = 0
            bottomBorderLine.alpha = 0
            toggleButton.alpha = 0
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                teacherInfoUnfoldConstraint?.constant = view.frame.width * 8.1/16 // 영상 확대에 맞춰...
            }
        }
    }
    
    func changeFullScreenConstraint(_ isActive: Bool) {
        videoContainerViewFullScreenWidthConstraint?.isActive = isActive
        videoContainerViewFullScreenHeightConstraint?.isActive = isActive
        videoContainerViewFullScreenTopConstraint?.isActive = isActive
        videoContainerViewFullScreenLeftConstraint?.isActive = isActive
        
        // safeArea 에 자막이 겹쳐보이는 것 대응
        marginViewHeight?.constant = (isFullScreenMode ? marginHeight : 0)
    }
    
    /// Portait 제약조건 활성화 메소드
    func portraitConstraint(_ isActive: Bool) {
        
//        pageCollectionView.reloadData()
//        customMenuBar.setNeedsLayout()
        
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
        pageCollectionViewPorTraitTopConstraint?.isActive = isActive
        
        let videoDataManager = VideoDataManager.shared
        let pipIsOn = !videoDataManager.isFirstPlayVideo
        if pipIsOn {
            pageCollectionViewPorTraitBottomConstraint?.isActive = false
            pageCollectionViewPorTraitBottomConstraint1?.isActive = isActive
        } else {
            pageCollectionViewPorTraitBottomConstraint?.isActive = isActive
            pageCollectionViewPorTraitBottomConstraint1?.isActive = false
        }
    }
    
    /// Landscape 제약조건 활성화 메소드
    func landscapeConstraint(_ isActive: Bool) {
        
//        pageCollectionView.reloadData()
//        customMenuBar.setNeedsLayout()
        
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

        let videoDataManager = VideoDataManager.shared
        let pipIsOn = !videoDataManager.isFirstPlayVideo
        if pipIsOn {
            pageCollectionViewLandscapeBottomConstraint?.isActive = false
            pageCollectionViewLandscapeBottomConstraint1?.isActive = isActive
        } else {
            pageCollectionViewLandscapeBottomConstraint?.isActive = isActive
            pageCollectionViewLandscapeBottomConstraint1?.isActive = false
        }
        // TODO: "TeachInfoView" 제약조건
        // TODO: "CollectionView" 제약조건
    }
}
