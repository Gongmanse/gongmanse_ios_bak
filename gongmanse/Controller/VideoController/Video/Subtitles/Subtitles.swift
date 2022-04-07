import ObjectiveC
import MediaPlayer
import CoreMedia
import AVKit

private struct AssociatedKeys {
    static var FontKey = "FontKey"
    static var ColorKey = "FontKey"
    static var SubtitleKey = "SubtitleKey"
    static var SubtitleHeightKey = "SubtitleHeightKey"
    static var PayloadKey = "PayloadKey"
}

public class Subtitles : NSObject {
    
    // MARK: - Properties
    var parsedPayload: NSDictionary?
    
    
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
    static func parseSubRip(_ payload: String) -> NSDictionary? {
        
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
                let fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
                var toStr = (group as NSString).substring(with: to.range)        // 스트링의 맨 뒤에서부터 시작
                
                // 1) h 값 입력
                let hToScanner = Scanner(string: toStr)
                let hToString = hToScanner.scanUpToString(":")                   // scanner에 입력된 텍스트 에서 ":"를 만나면 거기까지 끊고 그 전 텍스트를 hString에 입력
                if hToString != nil {                                            // hString이 nil이 아니라면, h에 typeCasting한 후 값을 입력
                    h = Double(hToString!)!                                      // Result: 12
                }
                
                // 2) m 값 입력
                toStr = String(toStr.dropFirst(hToString!.count + 1))            // 12가 아니라 더 길어질 수도 있으므로 .count 사용하고 ":"까지 drop하기위해 +1
                // fromStr의 값은 34:56 이 된 상태
                let toMScanner = Scanner(string: toStr)                          // "34:56" 을 Scanner에 입력
                let toMString = toMScanner.scanUpToString(":")                   // "h"로직과 동일하게 :를 만나면 만나기 전 String까지 출력
                if toMString != nil {                                            // mString이 nil이 아니라면, m에 typeCasting한 후 값을 입력
                    m = Double(toMString!)!                                      // Result: 34
                }
                
                // 3) s 값 입력
                s = Double(toStr.dropFirst(toMString!.count + 1))!               // "34:56" 중 "34:"를 drop 연산 후, 나머지 출력
                
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

    static var currentText = ""
    static func searchSubtitles(_ payload: NSDictionary?, _ time: TimeInterval) -> String? {
        
        let predicate = NSPredicate(format: "(%f >= %K) AND (%f <= %K)", time, "from", time, "to")
        
        guard let values = payload?.allValues, let result = (values as NSArray).filtered(using: predicate).first as? NSDictionary else {
            return nil
        }
        
        guard let text = result.value(forKey: "text") as? String else {
            return nil
        }
        
        guard currentText != text else {
            return nil
        }
//        print("set new subtitle text")
        currentText = text
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
    }
}
