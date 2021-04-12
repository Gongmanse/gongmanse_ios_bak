//
//  Subtitles.swift
//  Subtitles
//
//  Created by mhergon on 23/12/15.
//  Copyright © 2015 mhergon. All rights reserved.
//

import ObjectiveC   // 왜 import 했지?
import MediaPlayer  // 왜 import 했지?
import CoreMedia    // 왜 import 했지?
import AVKit


private struct AssociatedKeys {
    static var FontKey = "FontKey"
    static var ColorKey = "FontKey"
    static var SubtitleKey = "SubtitleKey"
    static var SubtitleHeightKey = "SubtitleHeightKey"
    static var PayloadKey = "PayloadKey"
}

@objc public class Subtitles : NSObject {

    // MARK: - Properties
    fileprivate var parsedPayload: NSDictionary?
    
    
    // MARK: - Public methods
    public init(file filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        // Get string
        let string = try! String(contentsOf: filePath, encoding: encoding)
        
        // Parse string
        parsedPayload = Subtitles.parseSubRip(string)
        
    }
    
 @objc public init(subtitles string: String) {
        
        // Parse string
        parsedPayload = Subtitles.parseSubRip(string)
        
    }
    
    /// Search subtitles at time
    ///
    /// - Parameter time: Time
    /// - Returns: String if exists
 @objc public func searchSubtitles(at time: TimeInterval) -> String? {
        
        return Subtitles.searchSubtitles(parsedPayload, time)
        
    }
    
    // MARK: - Private methods
    
    /// Subtitle parser
    ///
    /// - Parameter payload: Input string
    /// - Returns: NSDictionary
    // MARK: 입력받은 데이터 정규표현식으로 연산
    fileprivate static func parseSubRip(_ payload: String) -> NSDictionary? {
        
        do {
            
            // Prepare payload
            var payload = payload.replacingOccurrences(of: "\n\r\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\r\n", with: "\n")
            
            // Parsed dict
            let parsed = NSMutableDictionary()
            
            // Get groups
            let regexStr = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
            let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            let matches = regex.matches(in: payload, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, payload.count))
            for m in matches {
                
                let group = (payload as NSString).substring(with: m.range)
                
                // Get index
                var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
                var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard let i = match.first else {
                    continue
                }
                let index = (group as NSString).substring(with: i.range)
                
                // MARK: 자막시간추출
                // Get "from" & "to" time
                regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2}[,.]\\d{1,3}", options: .caseInsensitive)
                match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard match.count == 2 else {
                    continue
                }
                guard let from = match.first, let to = match.last else {
                    continue
                }
                
                var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0
                
                var fromStr = (group as NSString).substring(with: from.range)   // String의 맨 앞에서 부터 시작
                
                // MARK: - 자막 시간 부분 String Slicing 리팩토링(이유: 기존 방법인 "scanDouble(&x)"가 is deprecated 됨.)
                // 1) h 값 입력
                let hScanner = Scanner(string: fromStr)
                let hString = hScanner.scanUpToString(":")                       // scanner에 입력된 텍스트 에서 ":"를 만나면 거기까지 끊고 그 전 텍스트를 hString에 입력
                if hString != nil {                                              // hString이 nil이 아니라면, h에 typeCasting한 후 값을 입력
                    h = Double(hString!)!                                        // Result: 12
                }
                
                // 2) m 값 입력
                fromStr = String(fromStr.dropFirst(hString!.count + 1))          // 12가 아니라 더 길어질 수도 있으므로 .count 사용하고 ":"까지 drop하기위해 +1
                                                                                 // fromStr의 값은 34:56 이 된 상태
                let mScanner = Scanner(string: fromStr)                          // "34:56" 을 Scanner에 입력
                let mString = mScanner.scanUpToString(":")                       // "h"로직과 동일하게 :를 만나면 만나기 전 String까지 출력
                if mString != nil {                                              // mString이 nil이 아니라면, m에 typeCasting한 후 값을 입력
                    m = Double(mString!)!                                        // Result: 34
                }
                
                // 3) s 값 입력
                s = Double(fromStr.dropFirst(mString!.count + 1))!               // "34:56" 중 "34:"를 drop 연산 후, 나머지 출력
                                                                                 // Result: 56
                /* deprecated 될 기존코드 */
                var scanner = Scanner(string: fromStr)                          // Scanner에 String을 입력
//                scanner.scanDouble(&h)
//                scanner.scanString(":", into: nil)
//                scanner.scanDouble(&m)
//                scanner.scanString(":", into: nil)
//                scanner.scanDouble(&s)
//                scanner.scanString(",", into: nil)
//                scanner.scanDouble(&c)
                let fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)

                var toStr = (group as NSString).substring(with: to.range)   // 스트링의 맨 뒤에서부터 시작
                
                // 1) h 값 입력
                let hToScanner = Scanner(string: toStr)
                let hToString = hToScanner.scanUpToString(":")                       // scanner에 입력된 텍스트 에서 ":"를 만나면 거기까지 끊고 그 전 텍스트를 hString에 입력
                if hToString != nil {                                              // hString이 nil이 아니라면, h에 typeCasting한 후 값을 입력
                    h = Double(hToString!)!                                        // Result: 12
                }
                
                // 2) m 값 입력e
                toStr = String(toStr.dropFirst(hToString!.count + 1))          // 12가 아니라 더 길어질 수도 있으므로 .count 사용하고 ":"까지 drop하기위해 +1
                                                                                 // fromStr의 값은 34:56 이 된 상태
                let toMScanner = Scanner(string: toStr)                          // "34:56" 을 Scanner에 입력
                let toMString = toMScanner.scanUpToString(":")                       // "h"로직과 동일하게 :를 만나면 만나기 전 String까지 출력
                if toMString != nil {                                              // mString이 nil이 아니라면, m에 typeCasting한 후 값을 입력
                    m = Double(toMString!)!                                        // Result: 34
                }
                
                // 3) s 값 입력
                s = Double(toStr.dropFirst(toMString!.count + 1))!               // "34:56" 중 "34:"를 drop 연산 후, 나머지 출력
                                                                                 // Result: 56
                /* deprecated 될 기존코드 */
//                scanner = Scanner(string: toStr)
//                scanner.scanDouble(&h)
//                scanner.scanString(":", into: nil)
//                scanner.scanDouble(&m)
//                scanner.scanString(":", into: nil)
//                scanner.scanDouble(&s)
//                scanner.scanString(",", into: nil)
//                scanner.scanDouble(&c)
                let toTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
                // MARK: 자막텍스트 추출
                // Get text & check if empty
                let range = NSMakeRange(0, to.range.location + to.range.length + 1)
                guard (group as NSString).length - range.length > 0 else {
                    continue
                }
                let text = (group as NSString).replacingCharacters(in: range, with: "")
                
                // TODO: 코드 흐름을 본 결과, 이곳에서 <Font ....> </font> 를 정규표현식으로 필터링해주면 될 것 같다는 판단
                // 1. text에서 <Font> 위치 출력
                // 2. 그 위치부터 몇 글자까지 attributedString 을 통해 색상 부여
                // 3. final["text"] 에 값 입력
                
                
                // MARK: 정규표현식 결과 데이터 입력
                // Create final object
                let final = NSMutableDictionary()
                final["from"] = fromTime
                final["to"] = toTime
                final["text"] = text
                parsed[index] = final
            }
            return parsed
            
        } catch {
            
            return nil
            
        }
        
    }
    
    /// Search subtitle on time
    ///
    /// - Parameters:
    ///   - payload: Inout payload
    ///   - time: Time
    /// - Returns: String
    fileprivate static func searchSubtitles(_ payload: NSDictionary?, _ time: TimeInterval) -> String? {
        
        let predicate = NSPredicate(format: "(%f >= %K) AND (%f <= %K)", time, "from", time, "to")
        
        guard let values = payload?.allValues, let result = (values as NSArray).filtered(using: predicate).first as? NSDictionary else {
            return nil
        }
        
        guard let text = result.value(forKey: "text") as? String else {
            return nil
        }
        
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
}


// MARK: - AVPlayerViewController

public extension AVPlayerViewController {
    // MARK: - Public properties
    var subtitleLabel: UILabel? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleKey) as? UILabel }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Private properties
    fileprivate var subtitleLabelHeightConstraint: NSLayoutConstraint? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey) as? NSLayoutConstraint }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    fileprivate var parsedPayload: NSDictionary? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.PayloadKey) as? NSDictionary }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.PayloadKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // keyword 에 Response 데이터 중에서 "sTags"를 이곳에 입력
    var keyword: String? {
        get { return "자전" }
    }
    
    
    
    
    // MARK: - Public methods
    func addSubtitles(controller: UIViewController) -> Self {
        
        // Create label
        addSubtitleLabel(controller: controller)
        
        return self
        
    }
    
    func open(fileFromLocal filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        let contents = try! String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        
        subtitleLabel?.text = "..."
        URLSession.shared.dataTask(with: filePath, completionHandler: { (data, response, error) -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                //Check status code
                if statusCode != 200 {
                    NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
                    return
                }
            }
            // Update UI elements on main thread
            DispatchQueue.main.async(execute: {
                self.subtitleLabel?.text = ""
                
                if let checkData = data as Data? {
                    if let contents = String(data: checkData, encoding: encoding) {
                        self.show(subtitles: contents)
                    }
                }
                
            })
        }).resume()
    }
    
    
    
    func show(subtitles string: String) {
        // Parse
        parsedPayload = Subtitles.parseSubRip(string)
        addPeriodicNotification(parsedPayload: parsedPayload!)
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        
        // Add Dictionary content direct to Payload
        parsedPayload = dictionaryContent
        addPeriodicNotification(parsedPayload: parsedPayload!)
    }

    func addPeriodicNotification(parsedPayload: NSDictionary) {
        
//         let keyword: [String?] // Parameter로 array를 입력받은 후, addAttributedString에 입력(공만세프로젝트)
        // Add periodic notifications
        self.player?.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 60),
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                
                guard let strongSelf = self else { return }
                guard let label = strongSelf.subtitleLabel else { return }
                
                // Search && show subtitles
                // MARK: 텍스트를 받아서 실시간으로 텍스트를 출력
                if let subtitleText = Subtitles.searchSubtitles(strongSelf.parsedPayload, time.seconds) {
                    label.text = subtitleText   // Label에 String을 입력
//                    print("DEBUG: \(String(describing: subtitleText))")
                    
                    let underlineAttriString = NSMutableAttributedString(string: subtitleText)
                    let range1 = (subtitleText as NSString).range(of: (self?.keyword!)!)
//                    underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
                    underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: range1)
                    underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.mainOrange, range: range1)
                    label.attributedText = underlineAttriString
                    label.isUserInteractionEnabled = true
                    
                }
                // MARK: 레이블 사이즈 조절 1
                let baseSize = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
                let rect = label.sizeThatFits(baseSize)
                if label.text != nil {
                    strongSelf.subtitleLabelHeightConstraint?.constant = rect.height + 5.0
                } else {
                    strongSelf.subtitleLabelHeightConstraint?.constant = rect.height
                }
        })
    }

    
    @objc func handleBtn() {
        print("DEBUG: clicked Button!!!")
    }
    
    fileprivate func addSubtitleLabel(controller: UIViewController) {

        guard let _ = subtitleLabel else {
            // MARK: 레이블 사이즈 조절 2
            // Label
            subtitleLabel = UILabel()
            subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel?.backgroundColor = UIColor.rgb(red: 0, green: 0, blue: 0).withAlphaComponent(0.3)
            subtitleLabel?.textAlignment = .center
            subtitleLabel?.font = UIFont.appBoldFontWith(size: 15)
            subtitleLabel?.textColor = UIColor.white
            subtitleLabel?.numberOfLines = 0
            subtitleLabel?.layer.shouldRasterize = true
            subtitleLabel?.layer.rasterizationScale = UIScreen.main.scale
            subtitleLabel?.lineBreakMode = .byWordWrapping
            contentOverlayView?.addSubview(subtitleLabel!)
            
            
            // Position
            
//            subtitleLabel?.setDimensions(height: 50, width: 500)
            subtitleLabel?.centerX(inView: contentOverlayView!)
            subtitleLabel?.anchor(bottom: contentOverlayView!.bottomAnchor, width: 500)
//            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[l]-(20)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
//            contentOverlayView?.addConstraints(constraints)
//            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[l]-(30)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
//            contentOverlayView?.addConstraints(constraints)
//            subtitleLabelHeightConstraint = NSLayoutConstraint(item: subtitleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 30.0)
//            contentOverlayView?.addConstraint(subtitleLabelHeightConstraint!)
            
            return
            
        }
        
    }
    
    
    
}
