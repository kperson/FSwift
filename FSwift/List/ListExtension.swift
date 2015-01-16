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
    
    
    func indexOf( f: (T) -> Bool) -> Int? {
        var i = 0
        var final: Int?
        for x in self {
            if f(x)  {
                final = i
            }
            i++
        }
        return final
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
    
    func shuffled() -> [T] {
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    
    func skip(amount: Int) -> [T] {
        var i = amount
        var list: [T] = []
        while i < countElements(self) {
            list.append(self[i])
            i++
        }
        return list
    }
    
    /**
    * @param m A mapping a function
    * @param r a reduce function
    *
    * The mapping function is required to take a T (the type of object in the Array) a map it a value of type B (i.e. the key)
    * The reduction function takes the key(type B) and a list of Ts and reduces to a single C
    * See test case in ListExtensionsTests.swift for an example
    * See http://en.wikipedia.org/wiki/MapReduce for more explanation of map reduce
    *
    * @return a list of C
    *
    */
    func mapReduce<B:Hashable, C>(m: (T) -> B, _ r: (B, [T]) -> C) -> [C]  {
        var dict:Dictionary<B, [T]> = [:]
        for x in self {
            let key = m(x)
            if var l = dict[key] {
                l.append(x)
                dict[key] = l
            }
            else {
                dict[key] = [x]
            }
        }
        var rs:[C] = []
        for (k, v) in dict {
            rs.append(r(k, v))
        }
        return rs
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
