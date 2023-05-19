//
//  SearchResultModel.swift
//  Weather
//
//  Created by Pushpendra on on 19/05/23.
//

import Foundation

// Model for search result API
struct SearchResultModel: Codable {
    let name: String?
    let lat: Double?
    let lon: Double?
    let country: String?
    let state: String?
}
