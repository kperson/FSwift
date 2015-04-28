//
//  ColorTest.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/28/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import XCTest
import UIKit

class ColorTest: XCTestCase {
    
    let color = UIColor(red: 132.0/255.0, green: 172.0/255.0, blue: 153.0/255.0, alpha: 1)
    let hex = "84AC99"
    
    func testColorWithPercentBrightnessChange() {
        let initialBrightness:CGFloat = 0.5
        let initalColor = UIColor(hue: 0.5, saturation: 0.5, brightness: initialBrightness, alpha: 0.5)
        
        let percent:CGFloat = 0.1
        let finalBrightness:CGFloat = initialBrightness * (1 + percent)
        let finalColor = initalColor.colorWithPercentBrightnessChange(percent)
        
        var b:CGFloat = 0
        finalColor.getHue(nil, saturation: nil, brightness: &b, alpha: nil)
        
        XCTAssertEqual(b,finalBrightness, "colorWithPercentBrightnessChange wrong brightness")
    }
    
    func testColorToHex() {
        let calculatedHex = color.hex()
        XCTAssertEqual(calculatedHex,hex, "Wrong hex string from UIColor")
    }
    
    func testHexToColor() {
        let calculatedColor = UIColor(hex: hex)
        XCTAssertEqual(calculatedColor,color, "Wrong color from hex string")
    }

}