//
//  CharactersViewModel.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CharactersViewModel {
    enum FetchState: Equatable {
        case idle
        case loading
        case success
        case failure(message: String)
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case nameAscending
        case nameDescending
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .nameAscending:
                return "Name ↑"
            case .nameDescending:
                return "Name ↓"
            }
        }
        
        var sortQueryValue: String {
            switch self {
            case .nameAscending:
                return "name"
            case .nameDescending:
                return "-name"
            }
        }
    }
    
    private let service: CharacterServicing
    private(set) var characters: [Char] = []
    private(set) var state: FetchState = .idle
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private(set) var sortOption: SortOption = .nameAscending
    
    private let pageLimit: Int
    
    init(
        service: CharacterServicing = CharacterService(),
        pageLimit: Int = 20
    ) {
        self.service = service
        self.pageLimit = pageLimit
    }
    
    func loadCharacters(reset: Bool = false) async {
        guard state != .loading else { return }
        
        if reset {
            currentPage = 1
            characters.removeAll()
            canLoadMore = true
        }
        
        guard canLoadMore else { return }
        
        state = .loading
        
        do {
            let response = try await service.fetchCharacters(
                page: currentPage,
                limit: pageLimit,
                sort: sortOption.sortQueryValue
            )
            let newCharacters = response.data
            
            if reset || currentPage == 1 {
                characters = newCharacters
            } else {
                characters.append(contentsOf: newCharacters)
            }
            
            let pagination = response.meta.pagination
            canLoadMore = pagination.next != nil
            
            if canLoadMore {
                currentPage += 1
            }
            
            state = .success
        } catch {
            state = .failure(message: error.localizedDescription)
        }
    }
    
    func updateSortOption(_ option: SortOption) async {
        guard option != sortOption else { return }
        sortOption = option
        await loadCharacters(reset: true)
    }
}
