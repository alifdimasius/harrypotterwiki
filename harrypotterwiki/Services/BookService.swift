//
//  BookService.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

protocol BookServicing {
    func fetchBooks(
        page: Int,
        limit: Int,
        sort: String?
    ) async throws -> BooksResponse
}

struct BookService: BookServicing {
    
    private let apiService: PotterAPIServicing
    
    init(apiService: PotterAPIServicing = PotterAPIService()) {
        self.apiService = apiService
    }
    
    func fetchBooks(page: Int, limit: Int, sort: String?) async throws -> BooksResponse {
        try await apiService.fetch(
            resource: .books,
            page: page,
            limit: limit,
            sort: sort
        )
    }
}


