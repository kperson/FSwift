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
        return (destination as? UINavigationController)?.topViewController ?? destination
    }
    
}
