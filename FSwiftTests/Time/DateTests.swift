//
//  DateTests.swift
//  FSwift
//
//  Created by Kelton Person on 1/17/17.
//  Copyright © 2017 Kelton. All rights reserved.
//

import XCTest

class DateTest: XCTestCase {

    let small = Date(timeIntervalSince1970: 0)
    let big = Date(timeIntervalSince1970: 10)
    let equalSmall = Date(timeIntervalSince1970: 0)
    let equalBig = Date(timeIntervalSince1970: 10)
    
    func greaterThanOrEqual() {
        XCTAssert(big >= small)
        XCTAssert(big >= equalBig)
    }
    
    func lessThanOrEqualEqual() {
        XCTAssert(small <= big)
        XCTAssert(small <= equalSmall)
    }
    

}
