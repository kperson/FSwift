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
        let calcSum = list.foldRight(1, { accum, curr in
            accum + curr
        })
        
        let append = "10987654"
        let appendedNumbers = list.foldRight("", { (accum, curr) in
            accum + String(curr)
        })
        
        XCTAssertEqual(appendedNumbers, append, "Fold must append strings in append function")
        XCTAssertEqual(sumPlusOne, calcSum, "Fold must calculate sum in sum function")
    }
    
    func testReduceRight() {
        let list = [2, 3, 4, 5]
        let mult = 120
        let productCalc = list.reduceRight { x, y in x * y }
        XCTAssertEqual(mult, productCalc, "Reduce must calculate product")
    }
    
    func testFindFirst() {
        let list = [2, 3, 4, 5, 6, 7]
        XCTAssertEqual(list.findFirst { x in x > 4 }!, 5, "The first item greater than 4 is 5, findFirst should match this")
        XCTAssert(list.findFirst { x in  x > 100 } == nil, "There are no items greater than 100, findFirst should not match this")
    }
    
    func testRemoveDuplicates() {
        let list = [2, 2, 3, 2, 4, 4]
        XCTAssertEqual(removeDuplicates(list), [2, 3, 4], "Remove duplicates must remove duplicates")
    }
    
}
