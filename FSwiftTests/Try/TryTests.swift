//
//  TryTests.swift
//  FSwift
//
//  Created by Kelton Person on 10/2/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import UIKit
import XCTest
import Foundation

class TryTests: XCTestCase {
    
    
    class func divide(a: Double, _ b: Double) -> Try<Double>  {
        if(b != 0) {
            return Try.Success(a / b)
        }
        else {
            return Try.Failure(NSError(domain: "com.math.dividebyzero", code: 200, userInfo: nil))
        }
    }
    
    func testSuccess() {
        let succ = TryTests.divide(3, 4)
        XCTAssertEqual(succ.value!, 0.75, "3.0/4.0 must equal 0.75")
        XCTAssertNil(succ.error, "Error must be nil if an value exists")
    }
    
    func testFailure() {
        let fail = TryTests.divide(3, 0)
        fail.error!.domain
        XCTAssertEqual(fail.error!.domain, "com.math.dividebyzero", "Error must exists when dividing by zero")
        XCTAssertNil(fail.value, "Value must be nil if an error exists")
    }
}
