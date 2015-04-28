//
//  UIControlExtension.swift
//  FSwift
//
//  Created by Kelton Person on 10/24/14.
//  Copyright (c) 2014 Kelton. All rights reserved.
//

import Foundation
import UIKit

public class ControlAction: NSObject {
    
    let f: (UIControl) -> ()
    let contol: UIControl
    let controlEvents: UIControlEvents
    
    public init(f: (UIControl) -> (), control: UIControl, controlEvents: UIControlEvents) {
        self.f = f
        self.contol = control
        self.controlEvents = controlEvents
        super.init()
        self.contol.addTarget(self, action: Selector("selectionAction"), forControlEvents: self.controlEvents)
    }
    
    func selectionAction(){
        self.f(self.contol)
    }
    
    public func removeAction() {
        self.contol.removeTarget(self, action: Selector("selectionAction"), forControlEvents: self.controlEvents)
    }
    
}

extension UIControl {
    
    func addTargetAction(controlEvents: UIControlEvents,  _ f: (UIControl) -> ()) -> ControlAction {
        return ControlAction(f: f, control: self, controlEvents: controlEvents)
    }
    
}