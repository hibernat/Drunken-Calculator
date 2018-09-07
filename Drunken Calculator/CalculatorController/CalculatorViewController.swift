//
//  CalculatorViewController.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 01/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

protocol CalculatorViewControllerDelegate {
    func buttonAnimationStarted(rotated: [Int], shuffled: [Int]) // parameters are tags of animated buttons
}

class CalculatorViewController: UIViewController {
    
    private typealias `Self` = CalculatorViewController
    
    static let maxCountOfButtonsForShuffle = 5
    static let maxCountOfButtonsForRotation = 5
    
    // going from top-left corner down by rows
    // index in array: button as created in the CalculatorViewController - CalculatorViewViewModel.Button(rawValue: i)
    // value in array at index: position where placed in the view, starting top-left corner, going down by rows
    static let initialButtonLayoutPortrait = [16, 12, 13, 14, 8, 9, 10, 4, 5, 6, 17, 18, 3, 19, 15, 11, 7, 0, 1, 2]
    static let initialButtonLayoutLandscape = [16, 11, 12, 13, 6, 7, 8, 1, 2, 3, 17, 18, 0, 19, 14, 9, 4, 5, 10, 15]
    static let buttonCount = 20 // how many buttons the calculator has
    
    
    // MARK: - Properties
    
    // ----------------------------------------------------------------------------------------------------------------
    var viewModel = CalculatorViewViewModel()
    var calculatorView: CalculatorView { return self.view as! CalculatorView }
    var calculatorDelegate: CalculatorViewControllerDelegate?
    
    private var labelDisplay: UILabel!
    private var tagsOfAnimatedButtons = Set<Int>() // animated means shuffled or rotated
   
    //MARK: - Methods
    
    
    // ----------------------------------------------------------------------------------------------------------------
    // this is the only place where calculator view and subviews are set
    // layout is done in CalculatorView.layoutSubviews
    override func loadView() {
        // view
        let view = CalculatorView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 0.7, alpha: 1)
        view.tag = 1000 // not to be in conflict with button tags
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = false
        view.buttonAction = { [weak self] (tag) in self?.buttonPressed(buttonTag: tag) }
        self.view = view
        // subview - display
        let display = CalculatorDisplay()
        display.tag = 1001 // not to be in conflict with button tags
        display.textAlignment = .right
        display.numberOfLines = 1
        display.minimumScaleFactor = 0.4
        display.adjustsFontSizeToFitWidth = true
        display.isUserInteractionEnabled = true
        view.addSubview(display)
        self.labelDisplay = display
        // subview - buttons
        for i in 0..<Self.buttonCount {
            let button: CalculatorButton
            switch CalculatorViewViewModel.Button(rawValue: i)! {
            case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
                button = CalculatorButton(buttonType: .digit)
                button.text = String(i)
            case .decimalSeparator:
                button = CalculatorButton(buttonType: .digit)
                button.text = Locale.current.decimalSeparator ?? "."
            case .equals:
                button = CalculatorButton(buttonType: .operation)
                button.text = "="
            case .clear:
                button = CalculatorButton(buttonType: .clear)
                button.text = "C"
            case .add, .subtract, .multiply, .divide, .plusMinus, .square, .squareRoot:
                let buttonFaces = ["+", "-", "×", "÷", "\u{207A}\u{2215}\u{208B}" /* +/- */, "x\u{00B2}" /* x2 */, "√"]
                button = CalculatorButton(buttonType: .operation)
                button.text = buttonFaces[i - CalculatorViewViewModel.Button.add.rawValue]
            }
            button.tag = i
            self.view.addSubview(button)
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        // gesture recognizer for deletion of the last digit
        let grLastDigit = UISwipeGestureRecognizer(target: self, action: #selector(deleteLastDigit))
        grLastDigit.direction = .right
        grLastDigit.numberOfTouchesRequired = 1
        self.labelDisplay.addGestureRecognizer(grLastDigit)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    func buttonPressed(buttonTag: Int) {
        // do the calculation
        guard let button = CalculatorViewViewModel.Button(rawValue: buttonTag) else { return }
        UIDevice.current.playInputClick()
        self.viewModel.pressed(button: button )
        // animate buttons
        let rotation = self.buttonTagsForAnimation(maxCount: Self.maxCountOfButtonsForRotation)
        let shuffle = self.buttonTagsForAnimation(maxCount: Self.maxCountOfButtonsForShuffle)
        self.animateButtons(tagsRotated: rotation, tagsShuffled: shuffle)
    }

    // ----------------------------------------------------------------------------------------------------------------
    func animateButtons(tagsRotated rotated: [Int], tagsShuffled shuffled: [Int]) {
        func bringForward(tags: [Int]) {
            for tag in tags {
                if let button = self.view.viewWithTag(tag) {
                    self.view.bringSubview(toFront: button)
                }
            }
        }
        // move all rotated buttons forward
        bringForward(tags: rotated)
        // move all shuffled buttons forward (so they are in front of rotated buttons
        bringForward(tags: shuffled)
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
        animator.addAnimations { // rotation animation
            for tag in rotated {
                if let button = self.view.viewWithTag(tag) {
                    if button.transform.b == 0 {   // not yet rotated
                        button.transform = CGAffineTransform(rotationAngle: .pi)
                    } else { // already rotated
                        button.transform = CGAffineTransform.identity
                    }
                }
            }
        }
        if shuffled.count > 1 {
            animator.addAnimations { // shuffle animation
                let shuffledLayout = self.calculatorView.buttonLayoutShuffled(forButtonsWithTags: shuffled)
                self.calculatorView.buttonLayout = shuffledLayout
                // update frames for the animation
                for tag in shuffled {
                    if let button = self.view.viewWithTag(tag) {
                        if let newFrame = self.calculatorView.frameForButton(withTag: tag) {
                            button.frame = newFrame
                        }
                    }
                }
            }
        }
        animator.addCompletion { [weak self] (_) in
            if let `self` = self {
                self.tagsOfAnimatedButtons.subtract(rotated)
                self.tagsOfAnimatedButtons.subtract(shuffled)
            }
        }
        self.tagsOfAnimatedButtons.formUnion(rotated)
        self.tagsOfAnimatedButtons.formUnion(shuffled)
        animator.startAnimation()
        self.calculatorDelegate?.buttonAnimationStarted(rotated: rotated, shuffled: shuffled)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    @objc func deleteLastDigit() {
        self.viewModel.deleteLastDigitFromDisplay()
    }
    
    // ----------------------------------------------------------------------------------------------------------------
    @objc func animateButtonsToInitialLayoutPositions() {
        
    }
    
    // ----------------------------------------------------------------------------------------------------------------
    /// binds view with viewModel
    private func bindViewModel() {
        self.viewModel.displayText.bindAndFire() { [weak self] in self?.labelDisplay.text = $0 }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// randomly selects button tags for animation from available buttons (not being currently animated)
    /// - Parameter maxCount: maximum number of tags in result
    /// - Returns: array of button tags that can be animated (are not currently animated)
    private func buttonTagsForAnimation(maxCount: Int) -> [Int] {
        func random(_ upTo: Int) -> Int {
            return Int(arc4random_uniform(UInt32(upTo)))
        }
        var result = Set<Int>()
        let buttonTagsAvailableForAnimation = Array<Int>(Set<Int>(0..<Self.buttonCount).subtracting(self.tagsOfAnimatedButtons))
        let count = min(buttonTagsAvailableForAnimation.count, random(maxCount) + 1)
        for _ in 0..<count {
            result.insert(buttonTagsAvailableForAnimation[random(buttonTagsAvailableForAnimation.count)])
        }
        return Array<Int>(result)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// sets buttons to initial positions
    private func resetButtonsToLayout(_ layout: [Int]) {
        
    }
    
}

