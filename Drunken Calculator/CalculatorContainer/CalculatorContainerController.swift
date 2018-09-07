//
//  CalculatorContainerController.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 04/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

class CalculatorContainerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calculatorVC = CalculatorViewController(nibName: nil, bundle: nil)
        
        
        calculatorVC.view.frame = CGRect(x: 0, y: 0, width: 280, height: 400)
        let buttonLayout = CalculatorView.ButtonLayout(buttonsInRow: 4, tagToPosition: [16, 12, 13, 14, 8, 9, 10, 4, 5, 6, 17, 18, 3, 19, 15, 11, 7, 0, 1, 2])
        calculatorVC.calculatorView.buttonLayout = buttonLayout
        self.view.addSubview(calculatorVC.view)
        self.addChildViewController(calculatorVC)
        calculatorVC.didMove(toParentViewController: self)
        
    }

}
