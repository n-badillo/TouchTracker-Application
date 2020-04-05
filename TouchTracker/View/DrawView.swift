//
//  DrawView.swift
//  TouchTracker
//
//  Created by CSUFTitan on 4/5/20.
//  Copyright © 2020 Nancy Badillo. All rights reserved.
//

import UIKit
class DrawView: UIView{
    var currentLine: Line?
    var finishedLines = [Line]()
    
    func stroke(_ line: Line){
        let path = UIBezierPath()
        path.lineWidth = 10
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect){
        // Draw finished lines in black
        UIColor.black.setStroke()
        for line in finishedLines {
            stroke(line)
        }
    
        if let line = currentLine {
            // If there s a line currently being drawn, do it in red
            UIColor.red.setStroke()
            stroke(line)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Line stores these points as properties named begin and end; when a touch begins, a Line will be created and set both of its properties to the point where the touch began.  When the touch moves, it will update with there the line ends.
        
        let touch = touches.first!
        
        // Getting the location of the touch n view's coordinate system
        let location = touch.location(in: self)
        
        currentLine = Line(begin: location, end: location)
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        currentLine?.end = location
        setNeedsDisplay()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if var line = currentLine {
            let touch = touches.first!
            let location = touch.location(in: self)
            line.end = location
            
            finishedLines.append(line)
            // Appending the line that was just created to the finishedLines when the touch ends.
        }
        
        currentLine = nil
        setNeedsDisplay()
    }
    
    
    
}
