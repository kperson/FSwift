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
    
    func testMapReduce() {
        let times = [10.3, 94.8, 30.3, 10.9, 30.2, 10.67]
        
        // times is a list of finish times for a 100 meters dash
        //I would like to know how many people finished between 10 - 11 seconds, 11 - 12, etc
        //The first function in the map reduce maps an Double (the finish time) to an integer so  10.3 maps to 10
        //The seconds functions maps a key and list of values to a final results (10, [10.3, 10.9]) -> RaceStat)
        
        let raceStats = times.mapReduce (
            { x in Int(x) },
            { (key, list) in RaceStat (timeSlot: key, numInSlot: countElements(list)) }
        )
        
        let desireRaceStats = [
            RaceStat (timeSlot: 10, numInSlot: 3),
            RaceStat (timeSlot: 94, numInSlot: 1),
            RaceStat (timeSlot: 30, numInSlot: 2)
        ]
        XCTAssertEqual(desireRaceStats, raceStats, "Race Stats must manaul computation using map reduce")
    }
    
}
