//
//  Spell.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

struct SpellsResponse: Decodable {
    let data: [Spell]
    let links: Links
    let meta: Meta
}

struct Spell: Decodable {
    let id: String
    let type: String
    let attributes: SpellAttributes
    let links: SpellLinks
}

struct SpellAttributes: Decodable {
    let slug: String?
    let category: String?
    let creator: String?
    let effect: String?
    let hand: String?
    let image: String?
    let incantation: String?
    let light: String?
    let name: String?
    let wiki: String?
}

struct SpellLinks: Decodable {
    let `self`: String?
}
