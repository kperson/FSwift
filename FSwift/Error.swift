//
//  NSError.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/30/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import UIKit

extension NSError {
    public var message:String {
        return ((userInfo?["message"]) as? String) ?? localizedDescription
    }
}