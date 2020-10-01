//
//  Date.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import Foundation

public enum DatePrintComponent {
    case fullYear
    case monthNumber
    case day
    case hour24
    case seconds
}

public extension Date {
    
    func stringWithFormat(_ format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func printWithComponent(_ component:DatePrintComponent) -> String {
        switch component {
        case .fullYear:
            return self.stringWithFormat("yyyy")
        case .monthNumber:
            return self.stringWithFormat("MM")
        case .day:
            return self.stringWithFormat("dd")
        case .hour24:
            return self.stringWithFormat("HH")
        case .seconds:
            return self.stringWithFormat("mm")
        }
    }
    
    subscript(component: DatePrintComponent) -> String {
        return printWithComponent(component)
    }
}



public func >= (left: Date, right: Date) -> Bool {
    return left > right || left == right
}

public func <= (left: Date, right: Date) -> Bool {
    return left < right || left == right
}
