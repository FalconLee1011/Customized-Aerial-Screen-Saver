//
//  TVIdleScreenEntries.swift
//  Customized Areal Screen Saver
//
//  Created by falcon on 2023/10/7.
//

import Foundation

struct TVIdleScreenEntry: Codable{
    let localizationVersion: String
    let initialAssetCount: Int
    var assets: Array<TVIdleScreenEntryAsset>
    var categories: Array<TVIdleScreenEntryCategory>
    let version: Int
}

struct TVIdleScreenEntryAsset: Codable{
    let localizedNameKey: String
    let shotID: String
    let showInTopLevel: Bool
    let preferredOrder: Int
    let pointsOfInterest: Dictionary<String, String>
    let previewImage: String
    let accessibilityLabel: String
    let id: String
    let includeInShuffle: Bool
    var subcategories: Array<String>
    let categories: Array<String>

    let url4KSDR240FPS: String
    enum CodingKeys: String, CodingKey {
        case url4KSDR240FPS = "url-4K-SDR-240FPS"
        case localizedNameKey
        case shotID
        case showInTopLevel
        case preferredOrder
        case pointsOfInterest
        case previewImage
        case accessibilityLabel
        case id
        case includeInShuffle
        case subcategories
        case categories
    }
}

struct TVIdleScreenEntryCategory: Codable{
    let id: String
    let preferredOrder: Int
    let previewImage: String
    let localizedNameKey: String
    let representativeAssetID: String
    let localizedDescriptionKey: String
    var subcategories: Array<TVIdleScreenEntryCategorySubcategory>
}

struct TVIdleScreenEntryCategorySubcategory: Codable, Identifiable{
    var previewImage: String
    let preferredOrder: Int
    var representativeAssetID: String
    var id: String
    var localizedNameKey: String
    var localizedDescriptionKey: String
}
