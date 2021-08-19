//
//  Canvas.swift
//  gongmanse
//
//  Created by 김우성 on 2021/05/20.
//

import Foundation
import UIKit

struct Point {
    
    var x: CGFloat
    var y: CGFloat
}

struct Line {
    
    let strokeWidth: Float
    let color: UIColor
    var points: [CGPoint]
}

protocol CanvasDelegate: AnyObject {
    func passLinePositionDataForLectureNoteController(points: [String], color: [UIColor])
}


/// 그림을 그릴 UIView의 서브클래스
class Canvas: UIView {
    
    // MARK: - Property
    
    weak var delegate: CanvasDelegate?  // 노트저장 API를 대신 처리해줄 "LectureNoteController" delegate
    public var pointString = [String]() // API request 양식이 독특하여 String으로 변환해야하여 생성했다.
    public var colorArr = [UIColor]() // API request 양식이 독특하여 String으로 변환해야하여 생성했다.
    
    // 이전 노트 데이터를 받아오기 위해 제한자를 "public" 으로 설정했다.
    public var lines = [Line]()
    {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setNeedsDisplay()     // line에 새로운 값이 추가되었으면 새롭게 그려야하므로 해당 메소드를 호출한다.
            }
        }
    }
    
    fileprivate var strokeColor = UIColor.redPenColor
    fileprivate var strokeWidth: Float = 2
    
    
    // MARK: - Lifecycle
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper
    
    func setStrokeWidth(width: Float) {
        self.strokeWidth = width
    }
    
    func setStrokeColor(color: UIColor) {
        self.strokeColor = color
    }
    
    func undo() {
        _ = lines.popLast()
        _ = pointString.popLast()
        _ = colorArr.popLast()
        
        setNeedsDisplay()
    }
    
    func clear() {
        lines.removeAll()
        pointString.removeAll()
        colorArr.removeAll()
        
        setNeedsDisplay()
    }
    
    func saveNoteTakingData() {
        // 버그발생: 나는 4 개의 선을 그었는데 8개의 데이터가 "pointString" 에 추가되었다.
//                print("DEBUG: 넘겨진데이터 \(self.pointString)")
        delegate?.passLinePositionDataForLectureNoteController(points: pointString, color: colorArr)
    }
    
    
    // MARK: - CoreGraphic
    
    // 노트좌표를 기준으로 실제로 필기를 그리기 위한 메소드
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { line in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            context.setLineCap(.round)
            
            for (i, p) in line.points.enumerated() {
                
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
            context.strokePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        lines.append(Line.init(strokeWidth: strokeWidth,
                               color: strokeColor,
                               points: []))
    }
    
    // track the finger as we move across screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    
    // 좌표값과 색상정보를 넘겨주는 최초 시점
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 줄을 그으면 데이터가 저장된다. 그 데이터들 중에서 가장 최근 데이터를 상수에 입력한다.
        // 이전 값들을 중복하여 추가할 필요가 없기에, 가장 마지막에 추가된 값만 append 할 예정이다.
        guard let line = self.lines.last else { return }
        
        var passData = [Point]()  // 임시변수
        
        // 마지막에 추가된 line의 좌표값들을 "passData"에 입력한다.
        for (_, p) in line.points.enumerated() {
            
            passData.append(Point(x: p.x,
                                  y: p.y))
        }
        
        var convertedString = ""  // 임시변수
        
        // API의 Request양식에 따라 String으로 좌표값을 입력한다.
        // 형태변환: (x: 00, y:00) -> "{x:00, y:00}"
        for (_, p) in passData.enumerated() {
            // String의 값을 하나로 만들기 위해 String에 덧셈연산을 한다.
            convertedString += "{\"x\":\(p.x), \"y\":\(p.y)},"
        }
        
        // 하나의 x,y좌표값들 -> 하나의 String 으로 변환을 했으며, 이 값을 Array에 추가한다.
        self.pointString.append(convertedString)
        // 하나의 선을 추가했을 당시 색상을 색상Array에 추가한다.
        self.colorArr.append(self.strokeColor)
        
        // 결과
        // (x,y의 좌표값들, color값)
    }
    
    func setLines(_ previousNoteTakingData: [Line]) {
        clear()
        
        lines = previousNoteTakingData
        
        //예전에 그렸던 데이터 추가(안그러면 새로 그린것만 패치가 되서 보관됨, 그래서 이전에 그렸던 라인이 안보이고 사라짐)
        lines.forEach { line in
            var passData = [Point]()
            for (_, p) in line.points.enumerated() {
                passData.append(Point(x: p.x,
                                      y: p.y))
            }
            var convertedString = ""
            for (_, p) in passData.enumerated() {
                convertedString += "{\"x\":\(p.x), \"y\":\(p.y)},"
            }
            self.pointString.append(convertedString)
            self.colorArr.append(line.color)
        }
    }
}
