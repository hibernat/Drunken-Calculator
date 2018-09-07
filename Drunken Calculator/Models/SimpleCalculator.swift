//
//  CalculatorCPU.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 10/03/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import Foundation

// this calculator is not of any sophisticated design, rather to be an example
// of potentially complex model with input of enum type
// do NOT use for any other than demo purposes

class SimpleCalculator {
    
    private typealias `Self` = SimpleCalculator
    
    enum Result {
        case error
        case value(Double)
        case input(number: String, fractionDigits: Int?, minusSign: Bool) // fractionDigits means count of digits after comma, comma is NOT in the number
    }
    
    enum Operation {
        case digit(Int)
        case comma
        case plusMinus
        case add
        case subtract
        case multiply
        case divide
        case square
        case squareRoot
        case equals
        case deleteLastDigit
    }
    
    private enum CalculatorError: Error {
        case divisionByZero
        case squareRootOfNegativeNumber
        case invalidNumberOnInput
    }
    
    static let maxLengthOfInput = 9
    
    //MARK: - Properties
    
    
    // ----------------------------------------------------------------------------------------------------------------
    var result: Result {
        if self.isInError { return .error }
        else if let inputNumber = self.inputNumber {
            return .input(number: inputNumber, fractionDigits: self.inputFractionDigits, minusSign: self.inputMinusSign)
        }
        else { return .value(self.registerX) }
    }
    private var registerX: Double = 0
    private var registerY: Double = 0
    private var isInError = false
    private var operationFlag: Operation?
    private var inputNumber: String? {
        didSet {
            if self.inputNumber == nil {
                self.inputFractionDigits = nil
                self.inputMinusSign = false
            }
        }
    }
    private var inputFractionDigits: Int? // how many fraction numbers is entered
    private var inputMinusSign = false
    
    //MARK: - Initializers
    
    
    // ----------------------------------------------------------------------------------------------------------------
    init() {
        
    }
    
    //MARK: - Methods
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// reset of the calculator
    /// equivalent of the C button on real calculator
    func reset() {
        self.registerX = 0
        self.registerY = 0
        self.isInError = false
        self.inputNumber = nil
        self.operationFlag = nil
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// calculator data input - equivalent of pressing buttons on real calculator
    /// - Parameter operation: see Calculator.Operation for available operations
    func input(operation: Operation) {
        
        func inputNumberToRegisterX() throws {
            if let inputNumber = self.inputNumber {
                if let number = Double(inputNumber) {
                    self.registerY = self.registerX // remember the current value in registerY
                    self.registerX = self.inputMinusSign ? -number : number
                    if let fracDigits = self.inputFractionDigits {
                        self.registerX /= pow(Double(10), Double(fracDigits))
                    }
                } else { throw CalculatorError.invalidNumberOnInput }
                self.inputNumber = nil
            }
        }
        
        guard !self.isInError else { return }
        do {
            switch operation {
            case .digit(let digit):
                let inputLength = self.inputNumber?.count ?? 0
                if inputLength < Self.maxLengthOfInput { // only when max count of digits is not reached
                    self.inputNumber = (self.inputNumber ?? "") + String(digit)
                    self.inputFractionDigits? += 1 // when nil, nothing happens
                }
            case .comma:
                self.inputNumber = self.inputNumber ?? String(0)
                self.inputFractionDigits = self.inputFractionDigits ?? 0 // if nil, set 0
            case .plusMinus:
                if self.inputNumber == nil {
                    try process(.plusMinus)
                } else {
                    self.inputMinusSign = !self.inputMinusSign
                }
            case .square, .squareRoot:
                try inputNumberToRegisterX()
                try process(operation)
            case .add, .subtract, .multiply, .divide:
                try inputNumberToRegisterX()
                if let operationFlag = self.operationFlag { try self.process(operationFlag) } // calculate with previously stored operation
                self.operationFlag = operation // store currently entered operation for future processing
            case .equals:
                try inputNumberToRegisterX()
                if let operationFlag = self.operationFlag { try self.process(operationFlag) } // calculate with previously stored operation
                self.operationFlag = nil // there is no operation for the future
            case .deleteLastDigit:
                if self.inputNumber != nil {
                    if self.inputFractionDigits == 0 { // deleted is comma, no digit
                        self.inputFractionDigits = nil
                    } else { // deleted is the last digit
                        self.inputNumber = String(self.inputNumber!.dropLast())
                        self.inputFractionDigits? -= 1 // when nil, nothing happens
                        if self.inputNumber == "" {
                            self.inputNumber = nil
                            self.operationFlag = nil
                        }
                    }
                }
            }
        } catch {
            self.isInError = true
            return
        }
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    /// calculates internally with registerX and registerY
    /// result is back in registerX
    /// - Parameter operation: operation processed
    private func process(_ operation: Operation) throws {
        switch operation {
        case .add: self.registerX = self.registerX + self.registerY
        case .subtract: self.registerX = self.registerY - self.registerX
        case .multiply: self.registerX = self.registerX * self.registerY
        case .divide:
            if self.registerX == 0 { throw CalculatorError.divisionByZero }
            else { self.registerX = self.registerY / self.registerX }
        case .square: self.registerX = self.registerX * self.registerX
        case .squareRoot:
            if self.registerX < 0 { throw CalculatorError.squareRootOfNegativeNumber }
            else { self.registerX = self.registerX.squareRoot() }
        case .plusMinus: self.registerX = -self.registerX
        default: break
        }
    }
    
}

