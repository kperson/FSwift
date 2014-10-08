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
        let list = [4, 5, 6, 7, 8]
        
        list.foreach { x in
            XCTAssertEqual(x, list[i], "Values must match per index")
            i += 1
        }
    }

    func testForeachIndexWithIndex() {
        var i = 0
        let list = [4, 5, 6, 7, 8]
        
        list.foreachWithIndex { (val, index) in
            XCTAssertEqual(val, list[i], "Values must match per index")
            XCTAssertEqual(i, index, "Indicies must match for each item")
            i += 1
        }
    }
    
    func testFoldRight() {
        let list = [4, 5, 6, 7, 8, 9, 10]
        let sumPlusOne = 50
        let calcSum = list.foldRight(1, { (accum, curr) -> Int in
            return accum + curr
        })
        
        XCTAssertEqual(sumPlusOne, calcSum, "Fold must calculate sum")
    }
    
    func testReduceRight() {
        let list = [2, 3, 4, 5]
        let mult = 120
        let multCalc = list.reduceRight { x, y in x * y }
        XCTAssertEqual(mult, multCalc, "Fold must calculate sum")
    }

}
