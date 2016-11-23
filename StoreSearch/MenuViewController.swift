//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Chris Huang on 23/11/2016.
//  Copyright © 2016 Chris Huang. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class {
    func menuViewControllerSendSupportEmail(_ controller: MenuViewController)
}

class MenuViewController: UITableViewController {

    // MARK: Outlets and Properties
    
    weak var delegate: MenuViewControllerDelegate?
    
    // MARK: Initializations
    
    
    
    // MARK: ViewController Life Cycles
    
    override func viewDidLoad() {
        
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendSupportEmail(self)
        }
    }
    
}
