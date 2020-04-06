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
    
    var selectedLineIndex: Int? {
        didSet{
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    
    var moveRecognizer: UIPanGestureRecognizer!
    
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
        
    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
  
}

// MARK: - UIGestreRecognizerDelegate
extension DrawView: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override var canBecomeFirstResponder: Bool {
          return true
      }
    
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
        
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil{
            becomeFirstResponder()
            
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            menu.menuItems = [deleteItem]
            
            let targetRect = CGRect(x: point.x, y:point.y, width: 2, height: 2)
            menu.setTargetRect(targetRect, in:self)
            menu.setMenuVisible(true, animated: true)
        } else{
            menu.setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
    
    @objc func deleteLine(_ sender: UIMenuController){
        if let index = selectedLineIndex{
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            setNeedsDisplay()
        }
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer){
        print("Recognized a long press")
        
        if gestureRecognizer.state == .began{
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)
            
            if selectedLineIndex != nil{
                currentLines.removeAll()
            }
        } else if gestureRecognizer.state == .ended {
            selectedLineIndex = nil
        }
         setNeedsDisplay()
    }
    
    @objc func moveLine(_ gestureRecognizer: UIPanGestureRecognizer){
        print("Recognized a pan")
        
        // If a line is selected...
        if let index = selectedLineIndex{
            
            // When the pan recognizer changes it's position...
            if gestureRecognizer.state == .changed{
                // Checks to see how far the pan moved
                let translation = gestureRecognizer.translation(in: self)
                
                // Add the translation to the current beginning and end points o the line
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                setNeedsDisplay()
            }
        } else {
            // If no line selected, return and do nothing
            return
        }
    }
}
