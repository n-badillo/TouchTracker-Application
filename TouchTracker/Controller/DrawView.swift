//
//  DrawView.swift
//  TouchTracker
//
//  Created by CSUFTitan on 4/5/20.
//  Copyright © 2020 Nancy Badillo. All rights reserved.
//

import UIKit
class DrawView: UIView{
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black{
        didSet{
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red{
        didSet{
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    func stroke(_ line: Line){
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect){
        // Draw finished lines in black
        finishedLineColor.setStroke()
        for line in finishedLines {
            stroke(line)
        }
    
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            stroke(line)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Line stores these points as properties named begin and end; when a touch begins, a Line will be created and set both of its properties to the point where the touch began.  When the touch moves, it will update with there the line ends.
        
        print(#function)
        
        for touch in touches{
        // Getting the location of the touch n view's coordinate system
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location)
            // currentLines = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // let touch = touches.first!
        print(#function)
        
        for touch in touches{
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
            // let location = touch.location(in: self)
            // currentLines?.end = location
        
        }

        setNeedsDisplay()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print (#function)
        
        for touch in touches{
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key]{
            //let location = touch.location(in: self)
                
            line.end = touch.location(in: self)
            
            finishedLines.append(line)
            // Appending the line that was just created to the finishedLines when the touch ends.
            
            currentLines.removeValue(forKey: key)
            // currentLines = nil
            }
            
        }
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?){
        // Enables a touch to be cancelled by the OS in instances such as the user receiving a phone call while the user is touching the screen.  When it is cancelled, it will revert back to a previous state before the user initated the touch.
        
        // Log statement to see the order of events
        print(#function)
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
    
}
