//
//  Color.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import UIKit

extension UIColor {
    
    public func colorWithPercentBrightnessChange(percent:CGFloat) -> UIColor {
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
    
    func hex() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var rSTring:String = NSString(format:"%2X", Int(r*255))
        var gSTring:String = NSString(format:"%2X", Int(g*255))
        var bSTring:String = NSString(format:"%2X", Int(b*255))
        
        return (rSTring + gSTring + bSTring)
    }
    
    convenience init(hex:String) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.hasPrefix("0X")) {
            cString = (cString as NSString).substringFromIndex(2)
        }
        
        var rString = (cString as NSString).substringToIndex(2)
        var gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        var bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}
