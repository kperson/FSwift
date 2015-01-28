//
//  RectTest.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import XCTest
import UIKit

class RectTest: XCTestCase {
    
    func testInitWithCenterAndSize() {
        let center = CGPoint(x: 10, y: 10)
        let size = CGSize(width: 10, height: 10)
        let rect = CGRect(center:center,size:size)
        
        XCTAssertEqual(rect.size,size, "Rect wrong size")
        XCTAssertEqual(rect.center,center, "Rect wrong center")
    }
    
}