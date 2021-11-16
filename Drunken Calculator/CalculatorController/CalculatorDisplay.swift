//
//  CalculatorDisplay.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 05/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

class CalculatorDisplay: UILabel {

    //MARK: - Initializers
    // ----------------------------------------------------------------------------------------------------------------
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.textAlignment = .right
        self.numberOfLines = 1
        self.minimumScaleFactor = 0.4
        self.adjustsFontSizeToFitWidth = true
        self.isUserInteractionEnabled = true
        self.contentMode = .redraw
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    required init?(coder aDecoder: NSCoder) {
        fatalError("CalculatorDisplay.init?(coder) is not implemented")
    }
    

    //MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.font = UIFont.systemFont(ofSize: ((99*self.bounds.height/115) - 1).rounded())
        super.drawText(in: rect.inset(by: insets))
    }

}
