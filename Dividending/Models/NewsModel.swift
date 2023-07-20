//
//  NewsModel.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import Foundation

/// A generic model for news data
struct NewsModel: Codable {
    let data: NewsList
}

struct NewsList: Codable {
    let rows: [NewsDetails]
}

struct NewsDetails: Codable {
    let title: String
    let ago: String
    let publisher: String
    let url: String
    
    /// Formatted URL
    var formattedURL: URL {
        URL(string: "https://www.nasdaq.com\(url)")!
    }
}
