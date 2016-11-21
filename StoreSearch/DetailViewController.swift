//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Chris Huang on 21/11/2016.
//  Copyright © 2016 Chris Huang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: Outlets and Properties
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    
    // MARK: Initializations
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    
    // MARK: ViewController Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 221/255, green: 44/255, blue: 0, alpha: 0.87)
        popupView.layer.cornerRadius = 10
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        if searchResult != nil {
            updateUI()
        }
    }
    
    // MARK: Target Actions
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Functions
    
    func updateUI() {
        nameLabel.text = searchResult.name
        artistNameLabel.text = searchResult.artistName.isEmpty ? "Unknown" : searchResult.artistName
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        if let largeURL = URL(string: searchResult.artworkLargeURL) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
    }
    
    
    // MARK: Navigation
    
    
    // MARK: Deinit
    
    deinit {
        print("deinit: \(self)")
        downloadTask?.cancel()
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

// MARK: UIGestureRecognizerDelegate

extension DetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}

