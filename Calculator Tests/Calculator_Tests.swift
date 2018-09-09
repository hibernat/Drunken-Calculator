//
//  Calculator_Tests.swift
//  Calculator Tests
//
//  Created by Michael Bernat on 04/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

import XCTest

class Calculator_Tests: XCTestCase {
    
    var calculator: SimpleCalculator!
    
    override func setUp() {
        super.setUp()
        self.calculator = SimpleCalculator()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1() {
        calculator.reset()
        calculator.input(operation: .digit(1))
        calculator.input(operation: .digit(7))
        calculator.input(operation: .add)
        calculator.input(operation: .digit(2))
        calculator.input(operation: .digit(5))
        calculator.input(operation: .squareRoot)
        calculator.input(operation: .equals)
        if case .value(let result) = calculator.result {
            XCTAssertEqual(result, 22)
        } else { XCTFail() }
    }
    
    func test2() {
        calculator.reset()
        calculator.input(operation: .digit(1))
        calculator.input(operation: .digit(7))
        calculator.input(operation: .add)
        calculator.input(operation: .digit(2))
        calculator.input(operation: .digit(5))
        calculator.input(operation: .digit(5))
        calculator.input(operation: .deleteLastDigit)
        calculator.input(operation: .squareRoot)
        calculator.input(operation: .plusMinus)
        calculator.input(operation: .equals)
        if case .value(let result) = calculator.result {
            XCTAssertEqual(result, 12)
        } else { XCTFail() }
    }
   
    func test3() {
        calculator.reset()
        calculator.input(operation: .digit(0))
        calculator.input(operation: .digit(0))
        calculator.input(operation: .comma)
        calculator.input(operation: .digit(0))
        calculator.input(operation: .digit(0))
        calculator.input(operation: .comma)
        calculator.input(operation: .digit(2))
        calculator.input(operation: .square)
        calculator.input(operation: .subtract)
        if case .value(let result) = calculator.result {
            XCTAssertEqual(result, 0.000004)
        } else { XCTFail() }
    }
    
    func test4() {
        calculator.reset()
        calculator.input(operation: .digit(4))
        calculator.input(operation: .factorial)
        if case .value(let result) = calculator.result {
            XCTAssertEqual(result, 99)
        } else { XCTFail() }
    }

}
