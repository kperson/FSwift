//
//  Seq.swift
//  FSwift
//
//  Created by Kelton Person on 4/14/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public class Seq {
    
    /**
    Iterates through a sequence
    
    e.x.
    list = [1, 2, 3]
    Seq.foreach(list) { i in println(i * 2) }
    
    - parameter seq: - a seq to iteratee through
    - parameter f: - function to execute for each item in the sequence
    */
    public class func foreach<T : Sequence>(_ seq: T, _ f: (T.Iterator.Element) -> Void) {
        for x in seq {
            f(x)
        }
    }
    
    /**
    Iterates through a sequence providing an index as it goes
    
    e.x.
    list = [1, 2, 3]
    Seq.foreach(list) { (num, index) in println(num * index) }
    
    - parameter seq: - a seq to iteratee through
    - parameter f: - a function to execute for each item in the sequence
    */
    public class func foreachWithIndex<T : Sequence>(_ seq: T, _ f: (T.Iterator.Element, Int) -> Void) {
        var i = 0
        for x in seq {
            f(x, i)
            i += 1
        }
    }
    
    /**
    Finds the first index fulfilling the search criteria
    
    e.x.
    list = [1, 2, 3]
    Seq.firstIndexOf(list) { x in x == 2 } //returns 1
    
    - parameter seq: - a sequence to search
    - parameter f: - search criteria
    
    - returns: the index of fullfilling the criteria, nil if not found
    */
    public class func firstIndexOf<T : Sequence>(_ seq: T, _ f: (T.Iterator.Element) -> Bool) -> Int? {
        var i = 0
        for x in seq {
            if f(x)  {
                return i
            }
            i += 1
        }
        return nil;
    }
    
    /**
    Finds the last index fulfilling the search criteria
    
    e.x.
    list = [1, 2, 3, 2]
    Seq.firstIndexOf(list) { x in x == 2 } //returns 3
    
    - parameter seq: - a sequence to search
    - parameter f: - search criteria
    
    - returns: the index of fullfilling the criteria, nil if not found
    */
    public class func lastIndexOf<T : Sequence>(_ seq: T, _ f: (T.Iterator.Element) -> Bool) -> Int? {
        var i = 0
        var final: Int?
        for x in seq {
            if f(x)  {
                final = i
            }
            i += 1
        }
        return final
    }
    
    
    /**
    Generates the tail of a list (i.e. every item except the first), if the list has no tail, an empty array is returned
    
    e.x.
    Seq.tail([1, 2, 3]) //returns [2, 3]
    
    - parameter seq: - a sequence
    
    - returns: a new array representing the tail of the sequence
    */
    public class func tail<T : Sequence>(_ seq: T) -> [T.Iterator.Element] {
        var list:[T.Iterator.Element] = []
        var i = 0
        for x in seq {
            if i != 0 {
                list.append(x)
            }
            i += 1
        }
        return list
    }
    
    
    public class func foldRight<T : Collection, B>(_ seq: T, _ initialValue: B, _ f: (B, T.Iterator.Element) -> B) -> B {
        if seq.count == 0 {
            return initialValue
        }
        else {
            let t = Seq.tail(seq)
            return f(t.foldRight(initialValue, f), seq.first!)
        }
    }
    
    public class func findFirst<T : Collection>(_ seq: T, _ f: (T.Iterator.Element) -> Bool) -> T.Iterator.Element? {
        if seq.count == 0 {
            return nil
        }
        if f(seq.first!)  {
            return seq.first!
        }
        else {
            return Seq.findFirst(Seq.tail(seq), f)
        }
    }
    
    
    /**
    Removes duplicates from sequence
    
    - parameter seq: - a sequence to evaluate
    
    - returns: a new array with duplicates removed
    */
    public class func removeDuplicates<S : Sequence where S.Iterator.Element : Equatable>(_ seq: S) -> [S.Iterator.Element] {
        var uniqueList:[S.Iterator.Element] = []
        for x in seq {
            if !uniqueList.contains(x) {
                uniqueList.append(x)
            }
        }
        return uniqueList
    }
    
    /**
    Skips the first n elements of a sequence
    
    e.x.
    Seq.skip([1, 2, 3], 2) //returns [3]
    
    - parameter seq: - a sequence to evaluate
    - parameter amount: the number of elements to skip
    
    - returns: a new array with skip elements
    */
    public class func skip<T : Sequence>(_ seq: T, _ amount: Int) -> [T.Iterator.Element] {
        var i = 0
        var list:[T.Iterator.Element] = []
        for x in seq {
            if i >= amount {
                list.append(x)
            }
            i += 1
        }
        return list
    }
    
    
    
    /**
    Takes the first n elements of a sequence
    
    e.x.
    Seq.take([1, 2, 3], 2) //returns [1, 2]
    
    - parameter seq: - a sequence to evaluate
    - parameter amount: the number of elements to take
    
    - returns: a new array with taken elements
    */
    public class func take<T : Sequence>(_ seq: T, _ amount: Int) -> [T.Iterator.Element] {
        var i = 0
        var list:[T.Iterator.Element] = []
        for x in seq {
            if i < amount {
                list.append(x)
            }
            i += 1
        }
        return list
    }
    
    
    public class func mapReduce<T : Sequence, B:Hashable, C>(_ seq: T, _ m: (T.Iterator.Element) -> B, _ r: (B, [T.Iterator.Element]) -> C) -> [C]  {
        var dict:Dictionary<B, [T.Iterator.Element]> = [:]
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
