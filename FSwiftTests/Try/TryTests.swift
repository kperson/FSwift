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
    
    
    class func divide(a: CGFloat, _ b: CGFloat) -> Try<CGFloat>  {
        if(b != 0) {
            let val = a / b
            return Try<CGFloat>(val)
        }
        else {
            return Try<CGFloat>(NSError(domain: "com.math.dividebyzero", code: 5000, userInfo: nil))
        }
    }
    
    func testTrySuccess() {
        let succ = TryTests.divide(CGFloat(3.0), CGFloat(4.0))

        XCTAssertEqual(succ.value!, CGFloat(0.75), "3.0/4.0 must equal 0.75")
        XCTAssertNil(succ.error, "Error must be nil if an value exists")
    }
    
    func testTryFail() {
        let fail = TryTests.divide(CGFloat(3.0), CGFloat(0.0))
        XCTAssertEqual(fail.error!.code, 5000, "Error must exists when dividing by zero")
        XCTAssertNil(fail.value, "Value must be nil if an error exists")
    }
    
}
