//
//  ListExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

public extension Array {
    
    public func foreach( f: (T) -> Void) {
        for x in self {
            f(x)
        }
    }
    
    public func foreachWithIndex( f: (T, Int) -> Void) {
        var i = 0
        for x in self {
            f(x, i)
            i += 1
        }
    }
    
    public var everythingButFirst: [T]  {
        if(self.count <= 1) {
            return []
        }
        else {
            return Array(self[1...self.count - 1])
        }
    }
    
    public func foldRight<B>(initialValue: B, _ f: (T, B) -> B) -> B {
        if(self.isEmpty) {
            return initialValue
        }
        else {
            return f(self.first!, self.everythingButFirst.foldRight(initialValue, f))
        }
    }
    
    public func foldLeft<B>(initialValue: B, _ f: (T, B) -> B) -> B {
        return self.reverse().foldRight(initialValue, f)
    }
    
    
    public func reduceRight(f: (T, T) -> T) -> T {
        if(self.count == 1) {
            return self.first!
        }
        else {
            return f(self.first!, self.everythingButFirst.reduceRight(f))
        }
    }
    
    public func reduceLeft(f: (T, T) -> T) -> T {
        return self.reverse().reduceRight(f)
    }

    
}