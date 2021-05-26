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
    
    weak var delegate: CanvasDelegate?
    public var pointString = [String]()
    
    fileprivate var lines = [Line]()
    fileprivate var strokeColor = UIColor.black
    fileprivate var strokeWidth: Float = 1
    
    // public function
    
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
    
    
    override func draw(_ rect: CGRect) {
        // custom drawing
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
//        print("DEBUG: passData \(self.passData)")
        
        var convertedString = ""
        
        for (_, p) in passData.enumerated() {
            
            convertedString += "{\"x\":\(p.x), \"y\":\(p.y)},"
        }
        self.pointString.append(convertedString)
//        print("DEBUG: convertedString = \"points\":[\(convertedString)]")
    }
}
