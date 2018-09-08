//
//  CalculatorView.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 31/08/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

class CalculatorView: UIView {
    
    private typealias `Self` = CalculatorView
    typealias ButtonAction = ((Int)->Void) // when calculator button is pressed (see touchesEnded) this function is called, button tag is the parameter
    
    struct ButtonLayout {
        var buttonsInRow: Int
        var buttonCount: Int
        var tagToPosition: Array<Int>
    }
    
    static let layoutMargin: CGFloat = 0.06
    static let layoutDisplayHeight: CGFloat = 0.13
    static let layoutSpacingBelowDisplay: CGFloat = 0.06
    static let layoutButtonSpacing: CGFloat = 0.03
    
    //MARK: - Properties
    // ----------------------------------------------------------------------------------------------------------------
    var buttonLayout: ButtonLayout?
    var buttonAction: ButtonAction?
    
    
    //MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    override func layoutSubviews() {
        for subview in self.subviews {
            if subview is CalculatorButton {
                if let frame = self.frameForButton(withTag: subview.tag) {
                    subview.frame = frame
                }
            } else if subview is CalculatorDisplay {
                subview.frame.origin = CGPoint(x: self.bounds.origin.x + Self.layoutMargin * self.bounds.size.width,
                                               y: self.bounds.origin.y + Self.layoutMargin * self.bounds.size.height )
                subview.frame.size = CGSize(width: self.bounds.size.width * (1 - 2 * Self.layoutMargin),
                                            height: self.bounds.size.height * Self.layoutDisplayHeight )
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if let button = self.hitTest(point, with: event) as? CalculatorButton {
            self.animateButtonHighlight(for: button)
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if let button = self.hitTest(point, with: event) as? CalculatorButton {
            self.animateButtonHighlight(for: button)
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateButtonHighlightRemoval()
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateButtonHighlightRemoval()
        guard let point = touches.first?.location(in: self) else { return }
        if let button = self.hitTest(point, with: event) as? CalculatorButton {
            self.buttonAction?(button.tag)  // button is "pressed", calling appropriate action
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// calculates frame of the subview with given tag
    /// - Parameter tag: tag identifying the button
    /// - Returns: frame of the button
    func frameForButton(withTag tag: Int) -> CGRect? {
        guard let buttonLayout = self.buttonLayout,
            tag >= 0 && tag < buttonLayout.tagToPosition.count else { return nil }
        let buttonsInRow = CGFloat(buttonLayout.buttonsInRow)
        let buttonsInColumn = CGFloat(buttonLayout.buttonCount) / buttonsInRow
        let buttonWidth: CGFloat = (1 - 2 * Self.layoutMargin - (buttonsInRow - 1) * Self.layoutButtonSpacing) / buttonsInRow
        let buttonHeight: CGFloat = (1 - 2 * Self.layoutMargin - (buttonsInColumn - 1) * Self.layoutButtonSpacing -
            Self.layoutDisplayHeight - Self.layoutSpacingBelowDisplay) / buttonsInColumn
        
        // calculate position of the button in the layout
        let buttonPosition = buttonLayout.tagToPosition[tag]
        let row = buttonPosition / buttonLayout.buttonsInRow
        let column = buttonPosition % buttonLayout.buttonsInRow
        // finally calculating the frame
        let originX = (Self.layoutMargin + CGFloat(column) * (buttonWidth + Self.layoutButtonSpacing)) * self.bounds.size.width
        let originY = (Self.layoutMargin + Self.layoutDisplayHeight + Self.layoutSpacingBelowDisplay +
            CGFloat(row) * (buttonHeight + Self.layoutButtonSpacing)) * self.bounds.size.height
        return CGRect(x: originX,
                      y: originY,
                      width: buttonWidth * self.bounds.size.width,
                      height: buttonHeight * self.bounds.size.height)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// performs shuffle of button positions in the buttonLayout
    /// does not invoke any UI updates, just shuffles positions in the buttonLayout.tagToPosition array
    /// - Parameter tagArray: array with button tags that should be shuffled
    /// - Returns: ButtonLayout with tagToPosition array where positions are shuffled
    func buttonLayoutShuffled(forButtonsWithTags tagArray: [Int]) -> ButtonLayout? {
        guard var buttonLayout = self.buttonLayout else { return nil }
        guard tagArray.count > 1 else { return self.buttonLayout }
        var tagA = tagArray.first!
        let positionFirst = buttonLayout.tagToPosition[tagA]
        for tag in tagArray.dropFirst() {
            buttonLayout.tagToPosition[tagA] = buttonLayout.tagToPosition[tag]
            tagA = tag
        }
        buttonLayout.tagToPosition[tagA] = positionFirst
        return buttonLayout
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// returns initial positions of buttons, depending on view size
    /// layouts for portrait and landscape varies
    /// - Parameter size: view size
    func initialLayout(forViewSize size: CGSize) -> ButtonLayout {
        // going from top-left corner down by rows
        // index in array: button tag
        // value in array at index: position where placed in the view, starting top-left corner, going down by rows
        if size.width > size.height {  // landscape
            return CalculatorView.ButtonLayout(buttonsInRow: 5, buttonCount: 20, tagToPosition: [16, 11, 12, 13, 6, 7, 8, 1, 2, 3, 17, 18, 0, 19, 14, 9, 4, 5, 10, 15])
        } else {  // portrait
            return CalculatorView.ButtonLayout(buttonsInRow: 4,  buttonCount: 20, tagToPosition: [16, 12, 13, 14, 8, 9, 10, 4, 5, 6, 17, 18, 3, 19, 15, 11, 7, 0, 1, 2])
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// highlights the button
    /// - Parameter button: UIView that should be highlighted
    private func animateButtonHighlight(for button: UIView) {
        for view in self.subviews where view is CalculatorButton {
            UIView.animate(withDuration: 0.3) {
                view.alpha = (view === button) ? 0.75 : 1
            }
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// all buttons are set not highlighted
    private func animateButtonHighlightRemoval() {
        for view in self.subviews where view is CalculatorButton {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 1
            }
        }
    }
    
}
