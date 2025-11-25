//
//  Character.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

struct CharactersResponse: Decodable {
    let data: [Char]
    let links: Links
    let meta: Meta
}

struct Links: Decodable {
    let `self`: URL?
    let current: URL?
    let next: URL?
    let last: URL?
}

struct Meta: Decodable {
    let pagination: Pagination
    let copyright: String
    let generatedAt: String
}

struct Pagination: Decodable {
    let current: Int?
    let next: Int?
    let last: Int?
    let records: Int?
}

struct Char: Decodable {
    let id: String
    let type: String
    let attributes: CharAttributes
    let links: CharLinks
}

struct CharAttributes: Decodable {
    let slug: String
    let aliasNames: [String]?
    let animagus: String?
    let bloodStatus: String?
    let boggart: String?
    let born: String?
    let died: String?
    let eyeColor: String?
    let familyMembers: [String]?
    let gender: String?
    let hairColor: String?
    let height: String?
    let house: String?
    let image: String?
    let jobs: [String]?
    let maritalStatus: String?
    let name: String?
    let nationality: String?
    let patronus: String?
    let romances: [String]?
    let skinColor: String?
    let species: String?
    let titles: [String]?
    let wands: [String]?
    let weight: String?
    let wiki: String?
}

struct CharLinks: Decodable {
    let `self`: String?
}
