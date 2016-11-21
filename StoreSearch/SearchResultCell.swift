//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Chris Huang on 21/11/2016.
//  Copyright © 2016 Chris Huang. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 255/255, green: 88/255, blue: 85/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
}
