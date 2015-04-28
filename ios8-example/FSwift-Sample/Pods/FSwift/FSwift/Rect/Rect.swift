//
//  Rect.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import UIKit

extension CGRect {
    
    init(center:CGPoint, size:CGSize) {
        self.init(x: center.x - (size.width/2.0), y: center.y - (size.height/2.0), width: size.width, height: size.height)
    }
    
    var center:CGPoint {
        return CGPoint(x: origin.x + (size.width / 2.0), y: origin.y + (size.height / 2.0))
    }
    
}