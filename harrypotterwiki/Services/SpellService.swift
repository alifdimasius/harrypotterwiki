//
//  SpellService.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

protocol SpellServicing {
    func fetchSpells(
        page: Int,
        limit: Int,
        sort: String?
    ) async throws -> SpellsResponse
}

struct SpellService: SpellServicing {
    
    private let apiService: PotterAPIServicing
    
    init(apiService: PotterAPIServicing = PotterAPIService()) {
        self.apiService = apiService
    }
    
    func fetchSpells(page: Int, limit: Int, sort: String?) async throws -> SpellsResponse {
        try await apiService.fetch(
            resource: .spells,
            page: page,
            limit: limit,
            sort: sort
        )
    }
}
