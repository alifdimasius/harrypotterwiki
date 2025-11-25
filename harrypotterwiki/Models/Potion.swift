//
//  Potion.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

struct PotionsResponse: Decodable {
    let data: [Potion]
    let meta: Meta
    let links: Links
}

struct Potion: Decodable {
    let id: String
    let type: String
    let attributes: PotionAttributes
    let links: PotionLinks
}

struct PotionAttributes: Decodable {
    let slug: String?
    let characteristics: String?
    let difficulty: String?
    let effect: String?
    let image: String?
    let inventors: String?
    let ingredients: String?
    let manufacturers: String?
    let name: String?
    let sideEffects: String?
    let time: String?
    let wiki: String?

    private enum CodingKeys: String, CodingKey {
        case slug
        case characteristics
        case difficulty
        case effect
        case image
        case inventors
        case ingredients
        case manufacturers
        case name
        case sideEffects = "side_effects"
        case time
        case wiki
    }
}

struct PotionLinks: Decodable {
    let `self`: String?
}
