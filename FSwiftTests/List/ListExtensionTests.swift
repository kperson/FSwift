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
    
    func testFirstIndexOf() {
        let list = [1, 2, 3, 4, 2]
        let index = list.firstIndexOf { x in x == 2 }
        let indexNil = list.firstIndexOf { x in x == 10 }

        XCTAssertEqual(index!, 1, "index of must find the correct first index")
        XCTAssertNil(indexNil, "index must be nil if not present")
    }
    
    func tesLastIndexOf() {
        let list = [1, 2, 3, 4, 2]
        let index = list.lastIndexOf { x in x == 2 }
        let indexNil = list.lastIndexOf { x in x == 10 }
        
        XCTAssertEqual(index!, 4, "index of must find the correct last index")
        XCTAssertNil(indexNil, "index must be nil if not present")
    }

    
    func testForeach() {
        var i = 0
        let list = [4, 5, 6, 7, 8]
        
        list.foreach { x in
            XCTAssertEqual(x, list[i], "Values must match per index")
            i += 1
        }
    }
    
    
    func testTail() {
        let list = [1, 2, 3, 4]
        let theTail = Array(list.tail)
        XCTAssertEqual(theTail, [2, 3, 4], "tail should take everything expect for the first item")
        
        let list2:[Int] = []
        let list2Tail = Array(list2.tail)
        XCTAssertEqual(list2Tail, [], "tail should return an empty list if empty")
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
        
        let first = list.findFirst { x in x > 4 }!
        XCTAssert(first == 5, "The first item greater than 4 is 5, findFirst should match this")
        XCTAssert(list.findFirst { x in  x > 100 } == nil, "There are no items greater than 100, findFirst should not match this")
    }
    
    func testRemoveDuplicates() {
        let list = [2, 2, 3, 2, 4, 4]
        XCTAssertEqual(list.unique, [2, 3, 4], "Remove duplicates must remove duplicates")
    }
    
    func testLazyFlatMap() {
        let list = [2, 2, 3, 2, 4, 7]
        let doubleEven = list.lazyFlatMap { x -> Int? in
            if x % 2 == 0 {
                return x * 2
            }
            else {
                return nil
            }
        }
        let doubleEvenList = Array(doubleEven)
        XCTAssertEqual(doubleEvenList, [4, 4, 4, 8], "should flatmap")
    }
    
    func testLazyFilter() {
        let list = [2, 2, 3, 2, 4, 7]
        let even = list.lazyFilter { x in x % 2 == 0 }
        let evenList = Array(even)
        XCTAssertEqual(evenList, [2, 2, 2, 4], "should filter")
    }
    
    func testSkip() {
        let list = [2, 4, 4, 6, 8]
        XCTAssertEqual(Array(list.skip(2)), [4, 6, 8], "Skip must skip elements")
        XCTAssertEqual(Array(list.skip(20)), [], "Skip must skip elements")
    }
    
    func testTake() {
        let list = [2, 4, 4, 6, 8]
        XCTAssertEqual(Array(list.take(2)), [2, 4], "take must take the first n available elements")
        XCTAssertEqual(Array(list.take(20)), [2, 4, 4, 6, 8], "take must take the first n available elements")
    }
    
}
