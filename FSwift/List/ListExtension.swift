//
//  ListExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/6/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation

extension Array {
    
    func foreach(f: (T) -> Void) {
        for x in self {
            f(x)
        }
    }
    
    func foreachWithIndex( f: (T, Int) -> Void) {
        var i = 0
        for x in self {
            f(x, i)
            i += 1
        }
    }
    
    var everythingButFirst: [T]  {
        if self.count <= 1 {
            return []
        }
        else {
            return Array(self[1...self.count - 1])
        }
    }
    
    func foldRight<B>(initialValue: B, _ f: (B, T) -> B) -> B {
        if self.isEmpty  {
            return initialValue
        }
        else {
            return f(self.everythingButFirst.foldRight(initialValue, f), self.first!)
        }
    }
    
    func foldLeft<B>(initialValue: B, _ f: (B, T) -> B) -> B {
        return self.reverse().foldRight(initialValue, f)
    }
    
    
    func reduceRight(f: (T, T) -> T) -> T {
        if self.count == 1 {
            return self.first!
        }
        else {
            return f(self.first!, self.everythingButFirst.reduceRight(f))
        }
    }
    
    func reduceLeft(f: (T, T) -> T) -> T {
        return self.reverse().reduceRight(f)
    }
    
    func findFirst(f: (T) -> Bool) -> T? {
        if self.isEmpty {
            return nil
        }
        if(f(self.first!)) {
            return self.first!
        }
        else {
            return self.everythingButFirst.findFirst(f)
        }
    }
    
    func flatMap<S>(f: T -> S?) -> [S] {
        var list = [S]()
        for x in self {
            if let val = f(x) {
                list.append(val)
            }
        }
        return list
    }
    
    func take(amount: Int) -> [T] {
        var i = 0
        var list:[T] = []
        while i < countElements(self) && i < amount {
            list.append(self[i])
            i++
        }
        return list
    }


}


public func removeDuplicates<S : Equatable>(seq: [S]) -> [S] {
    var uniqueList = [S]()
    for x in seq {
        if !contains(uniqueList, x) {
            uniqueList.append(x)
        }
    }
    return uniqueList
}
