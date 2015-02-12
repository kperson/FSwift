//
//  Localize.swift
//  FSwift
//
//  Created by Maxime Ollivier on 2/11/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

extension String {
    
    public var local:String {
        return NSLocalizedString(self, comment: "")
    }
    
}