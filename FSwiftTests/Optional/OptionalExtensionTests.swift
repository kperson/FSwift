//
//  OptionalExtensionTests.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import UIKit
import XCTest

class OptionalExtensionTests: XCTestCase {

    func testGetOrElse() {
        let nilString: String? = nil
        let nonNilString: String? = "hello"
        let defaultValue = "world"
        
        XCTAssertEqual(nilString.getOrElse(defaultValue), defaultValue, "geOrElse must select 'else value' if value is nil")
        XCTAssertEqual(nonNilString.getOrElse(defaultValue), nonNilString!, "geOrElse must select 'value' if value is non nil")
    }

}
