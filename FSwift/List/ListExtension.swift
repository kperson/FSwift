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
        Seq.foreach(self, f)
    }
    
    func foreachWithIndex( f: (T, Int) -> Void) {
        Seq.foreachWithIndex(self, f)
    }
    
    
    func indexOf( f: (T) -> Bool) -> Int? {
        return Seq.indexOf(self, f)
    }
    
    var tail: [T]  {
        return Seq.tail(self)
    }
    
    func foldRight<B>(initialValue: B, _ f: (B, T) -> B) -> B {
        return Seq.foldRight(self, initialValue, f)
    }
    
    func foldLeft<B>(initialValue: B, _ f: (B, T) -> B) -> B {
        return self.reverse().foldRight(initialValue, f)
    }
    
    
    func reduceRight(f: (T, T) -> T) -> T {
        if self.count == 1 {
            return self.first!
        }
        else {
            return f(self.first!, self.tail.reduceRight(f))
        }
    }
    
    func reduceLeft(f: (T, T) -> T) -> T {
        return self.reverse().reduceRight(f)
    }
    
    func findFirst(f: (T) -> Bool) -> T? {
        return Seq.findFirst(self, f)
    }
    
    func flatMap<S>(f: T -> S?) -> [S] {
        return Seq.flatMap(self, f)
    }
    
    func take(amount: Int) -> [T] {
        return Seq.take(self, amount)
    }
    
    func skip(amount: Int) -> [T] {
        return Seq.skip(self, amount)
    }
    
    /**
    * :param m A mapping a function
    * :param r a reduce function
    *
    * The mapping function is required to take a T (the type of object in the Array) a map it a value of type B (i.e. the key)
    * The reduction function takes the key(type B) and a list of Ts and reduces to a single C
    * See test case in ListExtensionsTests.swift for an example
    * See http://en.wikipedia.org/wiki/MapReduce for more explanation of map reduce
    *
    * :returns a list of C
    *
    */
    func mapReduce<B:Hashable, C>(m: (T) -> B, _ r: (B, [T]) -> C) -> [C]  {
        return Seq.mapReduce(self, m, r)
    }


}


public class Seq {
    
    public class func foreach<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Void) {
        for x in seq {
            f(x)
        }
    }
    
    public class func foreachWithIndex<T : SequenceType>(seq: T, _ f: (T.Generator.Element, Int) -> Void) {
        var i = 0
        for x in seq {
            f(x, i)
            i += 1
        }
    }
    
    public class func indexOf<T : SequenceType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> Int? {
        var i = 0
        var final: Int?
        for x in seq {
            if f(x)  {
                final = i
            }
            i++
        }
        return final
    }
    
     public class func flatMap<T : SequenceType, S>(seq: T, _ f: T.Generator.Element -> S?) -> [S] {
        var list = [S]()
        for x in seq {
            if let val = f(x) {
                list.append(val)
            }
        }
        return list
    }
    
    public class func tail<T : SequenceType>(seq: T) -> [T.Generator.Element] {
        var list:[T.Generator.Element] = []
        var i = 0
        for x in seq {
            if i != 0 {
                list.append(x)
            }
            i++
        }
        return list
    }

    
    public class func foldRight<T : CollectionType, B>(seq: T, _ initialValue: B, _ f: (B, T.Generator.Element) -> B) -> B {
        let x = []
        if count(seq) == 0 {
            return initialValue
        }
        else {
            let t = Seq.tail(seq)
            return f(t.foldRight(initialValue, f), first(seq)!)
        }
    }
    
    public class func findFirst<T : CollectionType>(seq: T, _ f: (T.Generator.Element) -> Bool) -> T.Generator.Element? {
        if count(seq) == 0 {
            return nil
        }
        if f(first(seq)!)  {
            return first(seq)!
        }
        else {
            return Seq.findFirst(Seq.tail(seq), f)
        }
    }
    
    public class func removeDuplicates<S : Equatable>(seq: [S]) -> [S] {
        var uniqueList = [S]()
        for x in seq {
            if !contains(uniqueList, x) {
                uniqueList.append(x)
            }
        }
        return uniqueList
    }
    
    public class func skip<T : SequenceType>(seq: T, _ amount: Int) -> [T.Generator.Element] {
        var i = 0
        var list:[T.Generator.Element] = []
        for x in seq {
            if i >= amount {
                list.append(x)
            }
            i++
        }
        return list
    }
    
    
    public class func take<T : SequenceType>(seq: T, _ amount: Int) -> [T.Generator.Element] {
        var i = 0
        var list:[T.Generator.Element] = []
        for x in seq {
            if i < amount {
                list.append(x)
            }
            i++
        }
        return list
    }
    
    public class func mapReduce<T : SequenceType, B:Hashable, C>(seq: T, _ m: (T.Generator.Element) -> B, _ r: (B, [T.Generator.Element]) -> C) -> [C]  {
        var dict:Dictionary<B, [T.Generator.Element]> = [:]
        for x in seq {
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
