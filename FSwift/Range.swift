//
//  Range.swift
//  FSwift
//
//  Created by Maxime Ollivier on 2/3/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
        let startIndex = advance(string.startIndex, self.location)
        let endIndex = advance(startIndex, self.length)
        return startIndex..<endIndex
    }
}