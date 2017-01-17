//
//  Color.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import UIKit

extension UIColor {
    
    public func colorWithPercentBrightnessChange(_ percent:CGFloat) -> UIColor {
        var h:CGFloat = 0
        var s:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor(hue: h,
            saturation: s,
            brightness: b * (1 + percent),
            alpha: a)
    }
    
    public func darkerColor() -> UIColor {
        return colorWithPercentBrightnessChange(-0.25)
    }
    
    public func brighterColor() -> UIColor {
        return colorWithPercentBrightnessChange(0.25)
    }
    
    public var hex:String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rSTring:String = String(format:"%2X", Int(r*255))
        let gSTring:String = String(format:"%2X", Int(g*255))
        let bSTring:String = String(format:"%2X", Int(b*255))
        
        return (rSTring + gSTring + bSTring)
    }
    
    public convenience init(hex:String) {
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespaces).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.hasPrefix("0X")) {
            cString = (cString as NSString).substring(from: 2)
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

public extension Int {
    
    public var colorHex:CGFloat { return CGFloat(self) / 255.0 }
    
}
