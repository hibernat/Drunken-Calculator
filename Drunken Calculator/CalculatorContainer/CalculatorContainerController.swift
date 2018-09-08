//
//  CalculatorContainerController.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 04/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import UIKit

class CalculatorContainerController: UIViewController {

    
    //MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add calculator as subview
        // have to add also CalculatorViewController as child controller
        let calculatorVC = CalculatorViewController(nibName: nil, bundle: nil)
        self.view.addSubview(calculatorVC.view)
        self.addChildViewController(calculatorVC)
        calculatorVC.didMove(toParentViewController: self)
        
        NSLayoutConstraint.activate([
            calculatorVC.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            calculatorVC.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            calculatorVC.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            calculatorVC.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
    }

}
