//
//  SearchResults.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import Foundation

/// A generic model for search results
struct SearchResults: Codable {
    let data: [SearchResultModel]
}

/// Search result model
struct SearchResultModel: Codable {
    let name: String
    let symbol: String
    let asset: String
}
