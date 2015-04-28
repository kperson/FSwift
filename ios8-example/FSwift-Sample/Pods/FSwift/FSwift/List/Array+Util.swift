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
    
    
    func firstIndexOf( f: (T) -> Bool) -> Int? {
        return Seq.firstIndexOf(self, f)
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