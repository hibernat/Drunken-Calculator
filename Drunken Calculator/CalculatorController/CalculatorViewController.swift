//
//  CalculatorViewController.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 01/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private typealias `Self` = CalculatorViewController
    
    static let maxCountOfButtonsForShuffle = 6
    static let maxCountOfButtonsForRotation = 6
   
    
    // MARK: - Properties
    // ----------------------------------------------------------------------------------------------------------------
    var viewModel = CalculatorViewViewModel()
    var calculatorView: CalculatorView { return self.view as! CalculatorView }
    
    private var labelDisplay: UILabel!
    private var tagsOfAnimatedButtons = Set<Int>() // animated means shuffled or rotated
   
    
    //MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    // view and subviews are set up
    // layout is done in CalculatorView.layoutSubviews and workaroud here in viewDidLayout
    override func loadView() {
        // view
        let view = CalculatorView(frame: .zero)
        self.view = view
        // subview - display
        let display = CalculatorDisplay()
        view.addSubview(display)
        self.labelDisplay = display
        // subview - buttons
        for i in 0..<CalculatorView.buttonCount {
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
            case .add, .subtract, .multiply, .divide, .plusMinus, .square, .squareRoot, .inverse, .factorial, .pi, .euler:
                let buttonFaces = ["+", "-", "×", "÷", "\u{207A}\u{2215}\u{208B}", "x\u{00B2}", "√", "1\u{2215}x", "n!", "\u{03C0}", "\u{212F}"]
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
        self.view.backgroundColor = .white
        self.view.tag = 1000 // not to be in conflict with button tags
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = false
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.contentMode = .redraw
        self.calculatorView.buttonAction = { [weak self] (tag) in self?.buttonPressed(buttonTag: tag) }
        self.labelDisplay.tag = 1001 // not to be in conflict with button tags
        self.bindViewModel()
        // gesture recognizer for deletion of the last digit
        let grLastDigit = UISwipeGestureRecognizer(target: self, action: #selector(deleteLastDigit))
        grLastDigit.direction = .right
        grLastDigit.numberOfTouchesRequired = 1
        self.labelDisplay.addGestureRecognizer(grLastDigit)
        // gesture recognizer for buttons to initial positions
        let grInitialPositions = UISwipeGestureRecognizer(target: self, action: #selector(buttonsToInitialPositions))
        grInitialPositions.direction = .left
        grInitialPositions.numberOfTouchesRequired = 1
        self.labelDisplay.addGestureRecognizer(grInitialPositions)
        self.calculatorView.buttonLayout = self.calculatorView.initialLayout(forViewSize: UIScreen.main.bounds.size)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// this is a workaround
    /// all the application was designed (intentionally) without autolayout,
    /// BUT I am using UILabel and Safe Area layout guides
    /// As a sideeffect, UILabel automatically creates constraints from intrinsic content size
    /// and display is not properly laid out. This is a fix.
    override func viewDidLayoutSubviews() {
        let safeArea = self.view.safeAreaLayoutGuide.layoutFrame
        let width = safeArea.width * (1 - CalculatorView.layoutMarginLeftRight * 2)
        let height = safeArea.height * CalculatorView.layoutDisplayHeight
        let x = safeArea.width * CalculatorView.layoutMarginLeftRight + safeArea.origin.x
        let y = safeArea.height * CalculatorView.layoutMarginTop + safeArea.origin.y
        self.labelDisplay.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let newLayout = self.calculatorView.initialLayout(forViewSize: size)
        self.calculatorView.buttonLayout = CalculatorView.ButtonLayout(buttonsInRow: newLayout.buttonsInRow,
                                                                       buttonCount: newLayout.buttonCount,
                                                                       tagToPosition: newLayout.tagToPosition )
        self.view.setNeedsLayout()
        super.viewWillTransition(to: size, with: coordinator)
        // when transition is completed, rotate all buttons to normal position
        coordinator.animate(alongsideTransition: { context in
            for tag in 0..<CalculatorView.buttonCount {
                if let button = context.containerView.viewWithTag(tag) {
                    button.transform = CGAffineTransform.identity
                }
            }
        })
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    // Performs animation of calculator buttons
    /// - Parameters:
    ///   - rotated: tags of buttons to be rotated
    ///   - shuffled: tags of buttons to be shuffled
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
                // these buttons are again available for animations
                self.tagsOfAnimatedButtons.subtract(rotated)
                self.tagsOfAnimatedButtons.subtract(shuffled)
            }
        }
        // these buttons are not available for other animation, until this animation is completed
        self.tagsOfAnimatedButtons.formUnion(rotated)
        self.tagsOfAnimatedButtons.formUnion(shuffled)
        animator.startAnimation()
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// Sets buttons to positions set by the layout in parameter
    /// Also sets the layout in the parameter to the CalculatorView as the new layout
    /// - Parameter layout: new layout of calculator buttons
    private func animateAllButtonsToLayout(_ layout: CalculatorView.ButtonLayout) {
        self.calculatorView.buttonLayout = layout
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
        animator.addAnimations {
            for tag in layout.tagToPosition {
                if let button = self.view.viewWithTag(tag) {
                    button.transform = CGAffineTransform.identity
                    if let newFrame = self.calculatorView.frameForButton(withTag: tag) {
                        button.frame = newFrame
                    }
                }
            }
        }
        animator.addCompletion { [weak self] (_) in
            if let `self` = self {
                // all buttons are available for animations again
                self.tagsOfAnimatedButtons.subtract(0..<CalculatorView.buttonCount)
            }
        }
        // no buton is available for other animation, until this animation is completed
        self.tagsOfAnimatedButtons = Set<Int>(0..<CalculatorView.buttonCount)
        animator.startAnimation()
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
        let buttonTagsAvailableForAnimation = Array<Int>(Set<Int>(0..<CalculatorView.buttonCount).subtracting(self.tagsOfAnimatedButtons))
        let count = min(buttonTagsAvailableForAnimation.count, random(maxCount) + 1)
        for _ in 0..<count {
            result.insert(buttonTagsAvailableForAnimation[random(buttonTagsAvailableForAnimation.count)])
        }
        return Array<Int>(result)
    }
}

extension CalculatorViewController {
    
    // ----------------------------------------------------------------------------------------------------------------
    @objc func deleteLastDigit() {
        self.viewModel.deleteLastDigitFromDisplay()
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    @objc func buttonsToInitialPositions() {
        let initialLayout = self.calculatorView.initialLayout(forViewSize: self.view.bounds.size)
        self.animateAllButtonsToLayout(initialLayout)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    func buttonPressed(buttonTag: Int) {
        // do the calculation
        guard let button = CalculatorViewViewModel.Button(rawValue: buttonTag) else { return }
        self.viewModel.pressed(button: button )
        // animate buttons
        let rotation = self.buttonTagsForAnimation(maxCount: Self.maxCountOfButtonsForRotation)
        let shuffle = self.buttonTagsForAnimation(maxCount: Self.maxCountOfButtonsForShuffle)
        self.animateButtons(tagsRotated: rotation, tagsShuffled: shuffle)
    }
}
