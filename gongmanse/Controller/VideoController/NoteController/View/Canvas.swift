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
    func passLinePositionDataForLectureNoteController(points: [String])
}


/// 그림을 그릴 UIView의 서브클래스
class Canvas: UIView {
    
    // MARK: - Property
    
    weak var delegate: CanvasDelegate?  // 노트저장 API를 대신 처리해줄 "LectureNoteController" delegate
    public var pointString = [String]() // API request 양식이 독특하여 String으로 변환해야하여 생성했다.
    
    // 이전 노트 데이터를 받아오기 위해 제한자를 "public" 으로 설정했다.
    public var lines = [Line]() {
        didSet {
            setNeedsDisplay() // line에 새로운 값이 추가되었으면 새롭게 그려야하므로 해당 메소드를 호출한다.
        }
    }
    
    fileprivate var strokeColor = UIColor.black
    fileprivate var strokeWidth: Float = 1
    
    
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
        setNeedsDisplay()
    }
    
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func saveNoteTakingData() {
        //        print("DEBUG: 넘겨진데이터 \(self.pointString)")
        delegate?.passLinePositionDataForLectureNoteController(points: pointString)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 줄을 그으면 데이터가 저장된다. 그 데이터들 중에서 가장 최근 데이터를 상수에 할당한다.
        guard let line = self.lines.last else { return }
        var passData = [Point]()
        
        // 데이터들 중 "points"의 데이터만 "passData"에 할당한다.
        for (_, p) in line.points.enumerated() {
            
            passData.append(Point(x: p.x,
                                  y: p.y))
        }
        
        var convertedString = ""
        
        for (_, p) in passData.enumerated() {
            
            convertedString += "{\"x\":\(p.x), \"y\":\(p.y)},"
        }
        self.pointString.append(convertedString)
    }
    
}
