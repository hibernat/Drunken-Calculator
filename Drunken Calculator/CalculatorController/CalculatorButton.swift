//
//  CalculatorButton.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 05/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

class CalculatorButton: UIView {

    private typealias `Self` = CalculatorButton
    
    enum ButtonType {
        case digit
        case operation
        case clear
    }
    
    static let backgroundColorDigit = UIColor(white: 0.20, alpha: 1)
    static let backgroundColorOperation = UIColor(red: 249/255, green: 216/255, blue: 61/255, alpha: 1)
    static let backgroundColorClear = UIColor.orange
    
    
    //MARK: - Properties
    // ----------------------------------------------------------------------------------------------------------------
    var text: String?
    var textColor: UIColor?
    
    
    //MARK: - Initializers
    // ----------------------------------------------------------------------------------------------------------------
    init(buttonType: ButtonType) {
        super.init(frame: .zero)
        switch buttonType {
        case .digit:
            self.backgroundColor = Self.backgroundColorDigit
            self.textColor = .white
        case .operation:
            self.backgroundColor = Self.backgroundColorOperation
            self.textColor = .black
        case .clear:
            self.backgroundColor = Self.backgroundColorClear
            self.textColor = .black
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.contentMode = .redraw
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    required init?(coder aDecoder: NSCoder) {
        fatalError("CalculatorButton.init?(coder) is not implemented")
    }
    
    
    //MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    override func draw(_ rect: CGRect) {
        guard let text = self.text, let color = self.textColor else { return }
        let contextRect = self.bounds.insetBy(dx: 0, dy: self.bounds.height*0.2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        let fontSize = ((99*contextRect.height/115) - 1).rounded()
        let font = UIFont.systemFont(ofSize: fontSize)
        let attrString = NSMutableAttributedString(string: text,
                                                   attributes: [.font:font,
                                                                .foregroundColor:color])
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, 1))
        attrString.draw(in: contextRect)
    }
    
}
