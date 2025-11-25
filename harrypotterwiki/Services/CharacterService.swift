//
//  CharacterService.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

protocol CharacterServicing {
    func fetchCharacters(
        page: Int,
        limit: Int,
        sort: String?
    ) async throws -> CharactersResponse
}

struct CharacterService: CharacterServicing {
    
    private let apiService: PotterAPIServicing
    
    init(apiService: PotterAPIServicing = PotterAPIService()) {
        self.apiService = apiService
    }
    
    func fetchCharacters(page: Int, limit: Int, sort: String?) async throws -> CharactersResponse {
        try await apiService.fetch(
            resource: .characters,
            page: page,
            limit: limit,
            sort: sort
        )
    }
}


