//
//  Bindable.swift
//  Drunken Calculator
//
//  Created by Michael Bernat on 03/09/2018.
//  Copyright © 2018 Michael Bernat. All rights reserved.
//

class Bindable<T> {
    
    typealias Listener = ((T)->Void)
    
    var listener: Listener?
    var value: T {
        didSet { self.listener?(value) }
    }
    
    
    //MARK: - Initializers
    // ----------------------------------------------------------------------------------------------------------------
    init(_ value: T) {
        self.value = value
    }
    
    
    //MARK: - Methods
    // ----------------------------------------------------------------------------------------------------------------
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    
    // ----------------------------------------------------------------------------------------------------------------
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        self.listener?(self.value)
    }
}

