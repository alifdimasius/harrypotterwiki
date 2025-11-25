//
//  PotionService.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation

protocol PotionServicing {
    func fetchPotions(
        page: Int,
        limit: Int,
        sort: String?
    ) async throws -> PotionsResponse
}

struct PotionService: PotionServicing {
    
    private let apiService: PotterAPIServicing
    
    init(apiService: PotterAPIServicing = PotterAPIService()) {
        self.apiService = apiService
    }
    
    func fetchPotions(page: Int, limit: Int, sort: String?) async throws -> PotionsResponse {
        try await apiService.fetch(
            resource: .potions,
            page: page,
            limit: limit,
            sort: sort
        )
    }
}
