//
//  DecoderTests.swift
//  FSwift
//
//  Created by Kelton Person on 3/30/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import XCTest

class DecoderTests: XCTestCase {
   
    
    func testArrayCreation() {
        let d: Decoder = ["hello", "world"]
        XCTAssertEqual("hello", d[0].string!, "list indices must match")
        XCTAssertEqual("world", d[1].string!, "list indices must match")

    }
    
    func testNestedArrayCreation() {
        let d: Decoder = ["item1" :  ["hello", "world"]]
        XCTAssertEqual("hello", d["item1"][0].string!, "nested list indices must match")
        XCTAssertEqual("world", d["item1"][1].string!, "nested list indices must match")
    }
    
    func testDictionaryCreation() {
        let d: Decoder = ["hello" : "world"]
        XCTAssertEqual("world", d.dict?.items["hello"] as! String, "dictionary indices must match")
    }
    
    func testNestedDictionaryCreation() {
        let d: Decoder = ["item1" :  ["hello" : "world"]]
        XCTAssertEqual("world", d["item1"]["hello"].string!, "nested dictionary indices must match")
    }
    
}
