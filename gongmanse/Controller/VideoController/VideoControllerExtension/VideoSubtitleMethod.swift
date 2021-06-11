import UIKit

extension VideoController {
    
    /// "subtitleLabel"을 클릭 시, 호출될 콜백메소드
    @objc func didTappedSubtitle(sender: UITapGestureRecognizer) {
        
        // "subtitleLabel"을 클릭할 때만 호출되도록 한다.
        sender.numberOfTapsRequired = 1
        
        // 데이터 정상적으로 저장되었는지 확인하기 위한 Print
        print("DEBUG: 0Rangs is \(keywordRanges[0])")
        print("DEBUG: 1Rangs is \(keywordRanges[1])")
        print("DEBUG: 2Rangs is \(keywordRanges[2])")
        print("DEBUG: 3Rangs is \(keywordRanges[3])")
        print("DEBUG: 4Rangs is \(keywordRanges[4])")
        print("DEBUG: 5Rangs is \(keywordRanges[5])")
        print("DEBUG: 6Rangs is \(keywordRanges[6])")
        print("DEBUG: 7Rangs is \(keywordRanges[7])")
        
        // TODO: 검색결과를 나타낼 "SearchAfterVC"를 생성한다.
 
        
        // PIP를 재생할 수 있게 데이터를 넣어준다.
        let pipDataManager = PIPDataManager.shared
        
        // "sTags" 를 클릭했을 때, 영상 재생시간을 "VideoController"로 부터 가져온다.
        let currentPlaytime = playerItem.currentTime()
        
        // 클릭한 키워드를 입력한다. -> if 절
        
        // 재생중이던 영상을 일시중지한다. 동시에, PIP를 재생한다. -> Delegation 필요 -> 완료
//        player.pause()
        
        
//        guard let videoURL = pipDataManager.currentVideoURL else { return }
//
//
//        let pipVideoData = PIPVideoData(isPlayPIP: true,
//                                        videoURL: videoURL,
//                                        currentVideoTime: pipDataManager.currentVideoTime ?? Float(0.0),
//                                        videoTitle: pipDataManager.previousVideoTitle ?? "",
//                                        teacherName: pipDataManager.previousTeacherName ?? "")
        
        // isPlayPIP 값을 "SearchAfterVC" 에 전달한다. -> 완료
        // 그 값에 따라서 PIP 재생여부를 결정한다.
        
        
        
        // TODO: 검석어를 검색한다. -> if절에서 하고 있다.
        
        // TODO: PIP에 값을 할당한다. -> PIPDataManager에서 하고 있다.
        
        // TODO: 이전 영상을 일시중지시킨다.
        
        // TODO: "SearchAfterVC"로 화면을 전환한다. -> if절에서 하고 있다.
        
        /// 클릭한 위치와 subtitle의 keyword의 Range를 비교
        /// - keyword Range 내 subtitle 클릭 위치가 있다면, true
        /// - keyword Range 내 subtitle 클릭 위치가 없다면, false
        if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[0] ) {
            self.player.pause()
            videoDataManager.isFirstPlayVideo = false
            let vc = SearchAfterVC()
//            vc.pipVideoData = pipVideoData
            vc.isOnPIP = true // PIP 모드를 실행시키기 위한 변수
            vc.searchData.searchText = currentKeywords[0]
//            vc.searchBar.text = currentKeywords[0]
//            let vc = TestSearchController(clickedText: currentKeywords[0])
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        } else if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[2]) {
            self.player.pause()
            videoDataManager.isFirstPlayVideo = false
            let vc = SearchAfterVC()
//            vc.pipVideoData = pipVideoData
            vc.isOnPIP = true // PIP 모드를 실행시키기 위한 변수
            print("DEBUG: \(currentKeywords[2])?")
            vc.searchData.searchText = currentKeywords[2]
//            vc.searchBar.text = currentKeywords[2]
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        } else if gesture.didTapAttributedTextInLabel(label: subtitleLabel, inRange: keywordRanges[4]) {
            self.player.pause()
            videoDataManager.isFirstPlayVideo = false
            let vc = SearchAfterVC()
//            vc.pipVideoData = pipVideoData
            vc.isOnPIP = true // PIP 모드를 실행시키기 위한 변수
            print("DEBUG: \(currentKeywords[4])?")
            vc.searchData.searchText = currentKeywords[4]
//            vc.searchBar.text = currentKeywords[4]
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        } else {
            print("DEBUG: 키워드가 없나요?")
        }
        
    }
    
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
                          value: UIFont.appBoldFontWith(size: 15),
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


