//
//  VideoControllerExtension.swift
//  gongmanse
//
//  Created by 김우성 on 2021/04/28.
//

import UIKit

extension VideoController {
    /// 1,2,....100과 같은 값을 받았을 때, 00:00 의 형식으로 출력해주는 메소드
    func convertTimeToFitText(time: Int) -> String {
        
        // 초와 분을 나눈다.
        let minute = time / 60
        let sec = time % 60
        
        // 1분이 넘는 경우
        if minute > 0 {
            return "\(minute):\(sec < 10 ? "0\(sec)" : "\(sec)")"
            
            // 1 분이 넘지 않는 경우
        } else {
            return "0:\(sec < 10 ? "0\(sec)" : "\(sec)")"
        }
    }
}
// MARK: - Subtitles Methond
/// 동영상 자막 keyword 색상 변경 및 클릭 시 호출을 위한 커스텀 메소드
extension VideoController {
    
    func setUpAttributeString(_ attributedString: NSMutableAttributedString,
                              text: String,
                              array: [String],
                              arrayIndex aIndex: Int,
                              label: UILabel) {
        
        // "keyword"에 해당하는 텍스트에 텍스트 색상과 폰트를 설정한다.
        attributedString
            .addAttribute(NSAttributedString.Key.font,
                          value: UIFont.systemFont(ofSize: 16),
                          range: (text as NSString).range(of: ("\(array[aIndex])")))
        attributedString
            .addAttribute(NSAttributedString.Key.foregroundColor,
                          value: UIColor.orange,
                          range: (text as NSString).range(of: ("\(array[aIndex])")))
        
        // 설정한 값을 UILabel에 추가한다.
        label.attributedText = attributedString
    }
    
    
    func sliceSubtitleText(slicedText: [String.SubSequence], arrayIndex index: Int) -> String {
        
        /// "<" 기준으로 슬라이싱한 array[i]를 입력받을 프로퍼티
        var textArray = [String?]()
        
        /// "textArray"의 옵셔널 해제한 element를 입력받을 프로퍼티
        var optionalUnwrappingArray = [String]()
        
        for i in 0...index {
            /// ">" 기준으로 슬라이싱한 array[i]를 입력한 scanner
            let scanner = Scanner(string: String(slicedText[i]))
            
            /// "textArray"의 옵셔널 해제한 element를 입력받을 프로퍼티
            textArray.append(scanner.scanUpToString("<"))
        }
        
        for j in 0...index {
            if let element = textArray[j] {
                optionalUnwrappingArray.append(element)
            }
        }
        
        let result = optionalUnwrappingArray.joined()
        return result
    }
    
    func detectSTagsAndChangeColor(text: String, sTagsArray: [String], j: Int, i: Int) {
        
        // (클래스의 전역변수에 해당하는)"keywordRanges"로 클릭된 텍스트위 range 값을 전달한다.
        let keywordRangeInstance = (text as NSString).range(of: ("\(sTagsArray[j])"))
        print("DEBUG: keywordRangeInstance \(keywordRangeInstance)")
        
        // keyword의 위치를 Range로 캐스팅한다. 이를 통해 어떤 키워드를 클릭했는지 유효성판단을 한다.(didTappedSubtitle메소드에서)
        if let rangeOfKeywordTapped = Range(keywordRangeInstance) {
            self.sTagsRanges[i] = rangeOfKeywordTapped
        }
        // keywordRanges의 index가 "i"인 이유는 2나 4 모두를 포함하기위해서 i로 코드를 줄였다.
        self.keywordRanges[i] = keywordRangeInstance
    }
    
    func detectKeywrodAndTapRange(subtitleArray: [String.SubSequence],
                                  i: Int,
                                  sTagsArray: [String],
                                  keywordAttriString: NSMutableAttributedString,
                                  subtitleFinal: String,
                                  label: UILabel) {
        
        // "#" 가 있는 인덱스는 무조건 "2"와 "4" 이므로 "2"와 "4"일 때만 제한을 둔다.
        /// `#` 를 가지고 있는 텍스트
        let textAfterHashtag = subtitleArray[i]
        // 그 인덱스 값을 String으로 캐스팅 후, Scanner에 입력한다.
        /// `#` 를 가지고 있는 텍스트를 입력받은 Scanner
        let scanner = Scanner(string: String(textAfterHashtag))
        // "<" 이전까지의 값을 가져온다. 이 때 그 값은 keyword가 된다.
        /// `#` 이후 keyword를 추출한 텍스트
        let keyword = scanner.scanUpToString("<")
        
        // #keyword 와 일치하는 값이 sTags 중 있는지 확인한다.
        for j in 0...sTagsArray.count-1 {
            
            /* #이후에 있는 단어와 API로부터 받은 sTags와 동일한 경우 */
            if ("#" + keyword!) == sTagsArray[j] {
                // "Stags" 글자색 변경 및 폰트를 변경한다.
                setUpAttributeString(keywordAttriString,
                                     text: subtitleFinal,
                                     array: sTagsArray,
                                     arrayIndex: j,
                                     label: label)
                
                if let keyword = keyword {
                    self.currentKeywords[i] = keyword
                }
                
                detectSTagsAndChangeColor(text: subtitleFinal,
                                          sTagsArray: sTagsArray,
                                          j: j,
                                          i: i)
            }
        }
    }
    
    func manageTextInSubtitle(numberOfHasgtags: Int,
                              subtitleArray: [String.SubSequence],
                              sTagsArray: [String],
                              keywordAttriString: NSMutableAttributedString,
                              subtitleFinal: String,
                              label: UILabel) {
        
        for i in 0...(2 * numberOfHasgtags) {
            // "#"가 있는 (subtitleArray의)인덱스는 2와 4 이므로 2와 4일 때만 아래 로직을 실행한다.
            // sTagsRange 저장위치도 2와 4로 통일한다. 같은 for문에서 순회하기 때문이다.
            if i % 2 == 0 && i > 0 {
                detectKeywrodAndTapRange(subtitleArray: subtitleArray,
                                         i: i,
                                         sTagsArray: sTagsArray,
                                         keywordAttriString: keywordAttriString,
                                         subtitleFinal: subtitleFinal,
                                         label: label)
            }
        }
    }
    
}

extension VideoController {
    
    /// .vtt 내용 중 Text만 받아서 font Tag를 제거하는 메소드
    func filteringFontTagInSubtitleText(text: String) -> String {
        
        let text = text
        
        /// 1차 필터링: #에 있는 font tag 제거
        let firstFilteringText = text.replacingOccurrences(of: "<font color=\"#ffff00\">", with: "")
        
        /// 2차 필터링: 이 외 font tag 제거
        let secondFilteringText = firstFilteringText.replacingOccurrences(of: "<font color=\"#ff8000\">", with: "")
        
        /// 3차 필터링: </font> tag 제거
        let thirdFilteringText = secondFilteringText.replacingOccurrences(of: "</font>", with: "")
        
        return thirdFilteringText
    }
}

extension Notification.Name {
    static let detectVideoEnded = Notification.Name("videoEnded")
}

extension UITapGestureRecognizer {
    
    /*
     * "didTapAttributedTexxtInLabel() 메소드의 로직
     * label의 전체 크기만큼 textContainer를 크기를 설정한다.
     * 좌표와 글자크기를 동기화 시켜서 좌표 == 글자 순서로 변환한다.
     */
    func didTapAttributedTextInLabel(label: UILabel,
                                     inRange targetRange: NSRange) -> Bool {
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = 0
        
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset
            = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                      y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer
            = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                      y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter
            = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                           in: textContainer,
                                           fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}


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
        view.addSubview(teacherInfoView)
        teacherInfoView.translatesAutoresizingMaskIntoConstraints = false
        teacherInfoFoldConstraint?.priority = UILayoutPriority(rawValue: 999)
        teacherInfoUnfoldConstraint?.priority = UILayoutPriority(rawValue: 999)
        teacherInfoFoldConstraint
            = teacherInfoView.heightAnchor.constraint(equalToConstant: 5)
        teacherInfoUnfoldConstraint
            = teacherInfoView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.28)
        
        // Portrait 제약조건 정의
        teacherInfoViewPorTraitTopConstraint
            = teacherInfoView.topAnchor.constraint(equalTo: customMenuBar.bottomAnchor)
        teacherInfoViewPorTraitCenterXConstraint
            = teacherInfoView.centerXAnchor.constraint(equalTo: customMenuBar.centerXAnchor)
        teacherInfoViewPorTraitWidthConstraint
            = teacherInfoView.widthAnchor.constraint(equalTo: view.widthAnchor)
        
        // Landscape 제약조건 정의
        teacherInfoViewLandscapeTopConstraint
            = teacherInfoView.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor)
        teacherInfoViewLandscapeLeftConstraint
            = teacherInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        teacherInfoViewLandscapeRightConstraint
            = teacherInfoView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        
        /* TeacherInfoView (top/bottom)BorderLine */
        teacherInfoView.addSubview(topBorderLine)
        teacherInfoView.addSubview(bottomBorderLine)
        topBorderLine.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderLine.translatesAutoresizingMaskIntoConstraints = false
        topBorderLinePorTraitTopConstraint
            = topBorderLine.topAnchor.constraint(equalTo: teacherInfoView.topAnchor)
        topBorderLinePorTraitCenterXConstraint
            = topBorderLine.centerXAnchor.constraint(equalTo: teacherInfoView.centerXAnchor)
        topBorderLinePorTraitHeightConstraint
            = topBorderLine.heightAnchor.constraint(equalToConstant: 5)
        topBorderLinePorTraitWidthConstraint
            = topBorderLine.widthAnchor.constraint(equalTo: teacherInfoView.widthAnchor)
        bottomBorderLinePorTraitBottomConstraint
            = bottomBorderLine.bottomAnchor.constraint(equalTo: teacherInfoView.bottomAnchor)
        bottomBorderLinePorTraitCenterXConstraint
            = bottomBorderLine.centerXAnchor.constraint(equalTo: teacherInfoView.centerXAnchor)
        bottomBorderLinePorTraitHeightConstraint
            = bottomBorderLine.heightAnchor.constraint(equalToConstant: 5)
        bottomBorderLinePorTraitWidthConstraint
            = bottomBorderLine.widthAnchor.constraint(equalTo: teacherInfoView.widthAnchor)
        
        /* pageCollectionView */
        // Portrait 제약조건 정의
        pageCollectionViewPorTraitLeftConstraint
            = pageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        pageCollectionViewPorTraitRightConstraint
            = pageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        pageCollectionViewPorTraitBottomConstraint
            = pageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        pageCollectionViewPorTraitTopConstraint
            = pageCollectionView.topAnchor.constraint(equalTo: teacherInfoView.bottomAnchor)
        
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
        teacherInfoViewPorTraitTopConstraint?.isActive = isActive
        teacherInfoViewPorTraitCenterXConstraint?.isActive = isActive
        teacherInfoViewPorTraitWidthConstraint?.isActive = isActive
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
        teacherInfoViewLandscapeTopConstraint?.isActive = isActive
        teacherInfoViewLandscapeLeftConstraint?.isActive = isActive
        teacherInfoViewLandscapeRightConstraint?.isActive = isActive
        
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
