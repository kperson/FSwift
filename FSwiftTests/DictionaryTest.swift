//
//  DictionaryTest.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import XCTest

class DictionaryTest: XCTestCase {
    
    func testAppendNilWithNewKey() {
        var dict = ["1":1,"2":2]
        dict.addOptional(nil, forKey: "3")
        XCTAssertNil(dict["3"])
    }
    
    func testAppendNilWithExistingKey() {
        var dict = ["1":1,"2":2]
        dict.addOptional(nil, forKey: "2")
        let x = dict["2"]
        
        XCTAssertNotNil(x)
        XCTAssertEqual(x!,2)
    }
    
    func testAppendSomeWithNewKey() {
        var dict = ["1":1,"2":2]
        dict.addOptional(3, forKey: "3")
        let x = dict["3"]
        
        XCTAssertNotNil(x)
        XCTAssertEqual(x!,3)
    }
    
    func testAppendSomeWithExistingKey() {
        var dict = ["1":1,"2":2]
        dict.addOptional(3, forKey: "2")
        let x = dict["2"]
        
        XCTAssertNotNil(x)
        XCTAssertEqual(x!,3)
    }
    
    
    
    
    
    
}

