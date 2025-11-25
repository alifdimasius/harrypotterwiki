//
//  Book.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

struct BooksResponse: Decodable {
    let data: [Book]
    let links: Links
    let meta: Meta
}

struct Book: Decodable {
    let id: String
    let type: String
    let attributes: BookAttributes
    let relationships: BookRelationships
    let links: BookLinks
}

struct BookAttributes: Decodable {
    let slug: String
    let author: String?
    let cover: String?
    let dedication: String?
    let pages: Int?
    let releaseDate: String?
    let summary: String?
    let title: String?
    let wiki: String?

//    private enum CodingKeys: String, CodingKey {
//        case slug
//        case author
//        case cover
//        case dedication
//        case pages
//        case releaseDate = "release_date"
//        case summary
//        case title
//        case wiki
//    }
}

struct BookRelationships: Decodable {
    let chapters: ChaptersRelationship
}

struct ChaptersRelationship: Decodable {
    let data: [ChapterData]
}

struct ChapterData: Decodable {
    let id: String
    let type: String
}

struct BookLinks: Decodable {
    let `self`: String?
}

