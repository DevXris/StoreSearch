//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Chris Huang on 21/11/2016.
//  Copyright © 2016 Chris Huang. All rights reserved.
//

import UIKit

/* 
 1. not a view controller but control the "presentation" of something
 2. co-work with UIViewControllerTransitioningDelegate closely
*/
class DimmingPresentationController: UIPresentationController {
    
    // MARK: Properties
    
    override var shouldRemovePresentersView: Bool { // keep background view visible
        return false
    }
        
}


