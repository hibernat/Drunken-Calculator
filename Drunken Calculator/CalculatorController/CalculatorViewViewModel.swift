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
        case decimalSeparator
        case equals
        case clear
        case add
        case subtract
        case multiply
        case divide
        case plusMinus
        case square
        case squareRoot
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
        formatter.usesGroupingSeparator = false
        
        switch result {
        case .value(let value):
            if abs(value) > 1_000_000_000 { formatter.numberStyle = .scientific }
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
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            let digit = button.rawValue
            model.input(operation: .digit(digit))
        case .decimalSeparator:
            model.input(operation: .comma)
        case .equals:
            model.input(operation: .equals)
        case .clear:
            model.reset()
        case .add:
            model.input(operation: .add)
        case .subtract:
            model.input(operation: .subtract)
        case .multiply:
            model.input(operation: .multiply)
        case .divide:
            model.input(operation: .divide)
        case .plusMinus:
            model.input(operation: .plusMinus)
        case .square:
            model.input(operation: .square)
        case .squareRoot:
            model.input(operation: .squareRoot)
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

