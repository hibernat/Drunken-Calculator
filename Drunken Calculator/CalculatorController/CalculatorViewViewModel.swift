//
//  CalculatorViewViewModel.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 02/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import Foundation

struct CalculatorViewViewModel {
    
    enum Button: Int {
        case zero, one, two, three, four, five, six, seven, eight, nine
        case decimalSeparator // 10
        case equals
        case clear
        case add
        case subtract //14
        case multiply
        case divide
        case plusMinus
        case square // 18
        case squareRoot
        case inverse
        case factorial
        case pi // 22
        case euler
    }
    
    
    // MARK: - Properties
    // ----------------------------------------------------------------------------------------------------------------
    var model = SimpleCalculator()
    var displayText: Bindable<String>
    
    
    //MARK: - Initializers
    // ----------------------------------------------------------------------------------------------------------------
    init() {
        self.displayText = Bindable("0")
    }
    
    
    // MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    /// updates displayText property (bound to display in the view)
    /// - Parameter result: value used for updating the displayText
    func updateDisplayText(by result: SimpleCalculator.Result) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 5
        formatter.usesGroupingSeparator = false
        
        switch result {
        case .value(let value):
            if value != 0 && (abs(value) > 1_000_000_000 || abs(value) < 0.001) { formatter.numberStyle = .scientific }
            self.displayText.value = formatter.string(from: NSNumber(value: value))!
        case.error:
            self.displayText.value = "Error"
        case .input(let number, let decimals, let minusSign):
            var text: String
            if minusSign { text = "-" } else { text = "" }
            if let decimals = decimals {
                let decimalSpeparator = Locale.current.decimalSeparator ?? "."
                text.append(String(number.dropLast(decimals)))
                text.append(decimalSpeparator)
                text.append(String(number.dropFirst(number.count-decimals)))
            } else {
                text.append(number)
            }
            self.displayText.value = text
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// maps input coming from views to model
    /// just an example of possible mapping (otherwise this looks weird)
    /// - Parameter button: button pressed
    func pressed(button: Button) {
        let tagMapping: [Int:SimpleCalculator.Operation] = [10:.comma, 11:.equals, 13:.add, 14:.subtract, 15:.multiply, 16:.divide, 17:.plusMinus,
                                                            18:.square, 19:.squareRoot, 20:.inverse, 21:.factorial, 22:.pi, 23:.euler ]
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            let digit = button.rawValue
            model.input(operation: .digit(digit))
        case .clear:
            model.reset()
        default:
            if let operation = tagMapping[button.rawValue] {
                model.input(operation: operation)
            }
        }
        self.updateDisplayText(by: self.model.result)
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// last digit on display should be deleted
    func deleteLastDigitFromDisplay() {
        model.input(operation: .deleteLastDigit)
         self.updateDisplayText(by: self.model.result)
    }
    
}

