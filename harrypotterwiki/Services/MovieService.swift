//
//  MovieService.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

protocol MovieServicing {
    func fetchMovies(
        page: Int,
        limit: Int,
        sort: String?
    ) async throws -> MoviesResponse
}

struct MovieService: MovieServicing {
    
    private let apiService: PotterAPIServicing
    
    init(apiService: PotterAPIServicing = PotterAPIService()) {
        self.apiService = apiService
    }
    
    func fetchMovies(page: Int, limit: Int, sort: String?) async throws -> MoviesResponse {
        try await apiService.fetch(
            resource: .movies,
            page: page,
            limit: limit,
            sort: sort
        )
    }
}
