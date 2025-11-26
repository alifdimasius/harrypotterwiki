//
//  Movie.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

struct MoviesResponse: Decodable {
    let data: [Movie]
    let links: Links
    let meta: Meta
}

struct Movie: Decodable {
    let id: String
    let type: String
    let attributes: MovieAttributes
    let links: MovieLinks
}

struct MovieAttributes: Decodable {
    let slug: String
    let boxOffice: String?
    let budget: String?
    let cinematographers: [String]?
    let directors: [String]?
    let distributors: [String]?
    let editors: [String]?
    let musicComposers: [String]?
    let poster: String?
    let producers: [String]?
    let rating: String?
    let releaseDate: String?
    let runningTime: String?
    let screenwriters: [String]?
    let summary: String?
    let title: String?
    let trailer: String?
    let wiki: String?
    
//    private enum CodingKeys: String, CodingKey {
//        case slug
//        case boxOffice = "box_office"
//        case budget
//        case cinematographers
//        case directors
//        case distributors
//        case editors
//        case musicComposers = "music_composers"
//        case poster
//        case producers
//        case rating
//        case releaseDate = "release_date"
//        case runningTime = "running_time"
//        case screenwriters
//        case summary
//        case title
//        case trailer
//        case wiki
//    }
}

struct MovieLinks: Decodable {
    let `self`: String?
}

