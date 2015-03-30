//
//  Segue.swift
//  FSwift
//
//  Created by Maxime Ollivier on 1/27/15.
//  Copyright (c) 2015 Kelton. All rights reserved.
//

import UIKit

extension UIStoryboardSegue {
    
    var topDestinationViewController:AnyObject {
        return (destinationViewController as? UINavigationController)?.topViewController ?? destinationViewController
    }
    
}