//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Chris Huang on 21/11/2016.
//  Copyright © 2016 Chris Huang. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    // MARK: Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 255/255, green: 88/255, blue: 85/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    // MARK: Outlets and Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?
    
    // MARK: Functions
    
    func configure(for searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Unknown artistNameLabel")
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.kindForDisplay())
        }
        artworkImageView.image = #imageLiteral(resourceName: "Placeholder")
        if let smallURL = URL(string: searchResult.artworkSmallURL) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }    
}
