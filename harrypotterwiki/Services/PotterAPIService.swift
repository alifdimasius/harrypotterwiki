//
//  PotterAPIService.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

enum PotterResource: String {
    case characters
    case books
    case potions
    case movies
    case spells
}

protocol PotterAPIServicing {
    func fetch<T: Decodable>(
        resource: PotterResource,
        page: Int,
        limit: Int,
        sort: String?
    ) async throws -> T
}

enum PotterAPIServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unknownError(code: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .unknownError(code: let code):
            return "Request Failed with code: \(code)"
        }
    }
}

struct PotterAPIService: PotterAPIServicing {
    
    private let session: URLSession
    private let baseURL = URL(string: "https://api.potterdb.com/v1")
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(
        resource: PotterResource,
        page: Int,
        limit: Int,
        sort: String?
    ) async throws -> T {
        guard let baseURL else {
            throw PotterAPIServiceError.invalidURL
        }
        
        let resourceURL = baseURL.appendingPathComponent(resource.rawValue)
        
        guard var components = URLComponents(url: resourceURL, resolvingAgainstBaseURL: false) else {
            throw PotterAPIServiceError.invalidURL
        }
        
        var queryItems = [
            URLQueryItem(name: "page[number]", value: "\(page)"),
            URLQueryItem(name: "page[size]", value: "\(limit)")
        ]
        
        if let sort {
            queryItems.append(URLQueryItem(name: "sort", value: sort))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw PotterAPIServiceError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PotterAPIServiceError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw PotterAPIServiceError.unknownError(code: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }
}


