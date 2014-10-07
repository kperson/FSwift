//
//  ListExtensionTests.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import UIKit
import XCTest

class ListExtensionTests: XCTestCase {
    
    func testForeach() {
        var i = 0
        let list:[Int] = [4, 5, 6, 7, 8]
        
        list.foreach { x in
            XCTAssertEqual(x, list[i], "Values must match per index")
            i += 1
        }
    }

}
