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
    
    var selectedLineIndex: Int?
    
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
        
        if let index = selectedLineIndex{
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }
    }
    
    func indexOfLine(at point: CGPoint) -> Int?{
        // Find the line closest to the point
        for (index, line) in finishedLines.enumerated(){
            let begin = line.begin
            let end = line.end
            
            // Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05){
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If the tapped point is within 20 points, then return the line
                if hypot(x - point.x, y-point.y) < 20.0{
                    return index
                }
            }
        }
        // If nothing is found; then we do not select a line
        return nil
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
    
    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
    doubleTapRecognizer.numberOfTapsRequired = 2
    doubleTapRecognizer.delaysTouchesBegan = true
    addGestureRecognizer(doubleTapRecognizer)
    
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
            // Has to make sure that the double tap fails before declaring it as a single tap.
        addGestureRecognizer(tapRecognizer)
    }
}

// MARK: - UIGestreRecognizerDelegate
extension DrawView: UIGestureRecognizerDelegate{
    
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer){
        print("Recognized a double tap")
          
        selectedLineIndex = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
      }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer){
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        setNeedsDisplay()
    }
}
