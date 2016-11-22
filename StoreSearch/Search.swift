//
//  Search.swift
//  StoreSearch
//
//  Created by Chris Huang on 22/11/2016.
//  Copyright © 2016 Chris Huang. All rights reserved.
//

import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    
    // MARK: Properties
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    private(set) var state: State = .notSearchedYet
    
    private var dataTask: URLSessionDataTask? = nil
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var entityName: String {
            switch self {
            case .all : return ""
            case .music : return "musicTrack"
            case .software : return "software"
            case .ebooks : return "ebook"
            }
        }
    }
    
    // MARK: Functions
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            
            dataTask?.cancel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            state = .loading
            
            let url = iTunesURL(searchText: text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                
                self.state = .notSearchedYet
                var success = false
                
                if let error = error as? NSError, error.code == -999 {
                    return // search has cancelled
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                    let jsonData = data, let jsonDictionary = self.parse(json: jsonData) {
                    var searchResults = self.parse(dictionary: jsonDictionary)
                    if searchResults.isEmpty {
                        self.state = .noResults
                    } else {
                        searchResults.sort(by: <)
                        self.state = .results(searchResults)
                    }
                    success = true
                }
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success)
                }
                
            })
            dataTask?.resume()
        }
    }
    
    // Parse JSON from iTunes Store URL
    private func iTunesURL(searchText: String, category: Category) -> URL {
        
        let entityName = category.entityName
        let locale = Locale.autoupdatingCurrent
        let language = locale.identifier
        let countryCode = locale.regionCode ?? "en_US"
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/search"
        let urlQueryItem1 = URLQueryItem(name: "term", value: searchText)
        let urlQueryItem2 = URLQueryItem(name: "limit", value: "200")
        let urlQueryItem3 = URLQueryItem(name: "entity", value: entityName)
        let urlQueryItem4 = URLQueryItem(name: "lang", value: language)
        let urlQueryItem5 = URLQueryItem(name: "country", value: countryCode)
        urlComponents.queryItems = [urlQueryItem1, urlQueryItem2, urlQueryItem3, urlQueryItem4, urlQueryItem5]
        print(urlComponents.url!)
        return urlComponents.url!
        
        /* Alternative approach: excapedSearchText
         let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
         let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
         let url = URL(string: urlString)
         return url!
         */
    }
    
    private func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON error: \(error)")
            return nil
        }
    }
    
    private func parse(dictionary: [String: Any]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [Any] else { return [] }
        var searchResults = [SearchResult]()
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track" : searchResult = parse(track: resultDict)
                    case "audiobook" : searchResult = parse(audiobook: resultDict)
                    case "software" : searchResult = parse(software: resultDict)
                    default : break
                    }
                } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
            
        }
        return searchResults
    }
    
    private func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }
    
    private func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        return searchResult
    }
}
