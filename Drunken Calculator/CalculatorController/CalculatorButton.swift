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
    
    
    //MARK: - Properties
    // ----------------------------------------------------------------------------------------------------------------
    var text: String?
    var buttonType: ButtonType
    
    
    //MARK: - Initializers
    // ----------------------------------------------------------------------------------------------------------------
    init(buttonType: ButtonType) {
        self.buttonType = buttonType
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .redraw
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    required init?(coder aDecoder: NSCoder) {
        fatalError("CalculatorButton.init?(coder) is not implemented")
    }
    
    
    //MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    override func draw(_ rect: CGRect) {
        var colorText: UIColor
        var colorTop: CGColor
        var colorBottom: CGColor
        var colorBorder: CGColor
        
        switch buttonType {
        case .digit:
            colorTop = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1).cgColor
            colorBottom = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1).cgColor
            colorBorder = UIColor.black.cgColor
            colorText = .white
        case .operation:
            colorTop = UIColor(red: 255/255, green: 225/255, blue: 82/255, alpha: 1).cgColor
            colorBottom = UIColor(red: 255/255, green: 210/255, blue: 0/255, alpha: 1).cgColor
            colorBorder = UIColor(red: 80/255, green: 66/255, blue: 0/255, alpha: 1).cgColor
            colorText = .black
        case .clear:
            colorTop = UIColor(red: 255/255, green: 183/255, blue: 81/255, alpha: 1).cgColor   // lighter orange
            colorBottom = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1).cgColor // orange
            colorBorder = UIColor(red: 254/255, green: 78/255, blue: 0/255, alpha: 1).cgColor // darker orange
            colorText = .black
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        // rounded outer rect used ac clip region for gradient
        let pathBorder = CGMutablePath()
        pathBorder.addRoundedRect(in: rect, cornerWidth: 6, cornerHeight: 6)
        context.addPath(pathBorder)
        context.clip()
        // set and draw gradient
        let colorComponents = [colorTop.components!, colorBottom.components!].flatMap {$0}
        let locations: [CGFloat] = [0.0, 1.0]
        let grad = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(),
                              colorComponents: colorComponents, locations: locations, count: 2)!
        context.drawLinearGradient(grad, start: CGPoint(x: rect.midX, y: rect.minY), end: CGPoint(x: rect.midX, y: rect.maxY), options:[])
        // stroke border
        context.addPath(pathBorder)
        context.setStrokeColor(colorBorder)
        context.setLineWidth(2)
        context.strokePath()
        context.restoreGState()
        // draw text
        guard let text = self.text else { return }
        let insetRect = self.bounds.insetBy(dx: 0, dy: self.bounds.height*0.2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        let fontSize = ((99*insetRect.height/115) - 1).rounded()
        let font = UIFont.systemFont(ofSize: fontSize)
        let attrString = NSMutableAttributedString(string: text,
                                                   attributes: [.font:font,
                                                                .foregroundColor: colorText])
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, 1))
        attrString.draw(in: insetRect)
    }
    
}
