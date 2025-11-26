//
//  SpellsViewModel.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 26/11/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class SpellsViewModel {
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
    
    private let service: SpellServicing
    private(set) var spells: [Spell] = []
    private(set) var state: FetchState = .idle
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private(set) var sortOption: SortOption = .nameAscending
    
    private let pageLimit: Int
    
    init(
        service: SpellServicing = SpellService(),
        pageLimit: Int = 20
    ) {
        self.service = service
        self.pageLimit = pageLimit
    }
    
    func loadSpells(reset: Bool = false) async {
        guard state != .loading else { return }
        
        if reset {
            currentPage = 1
            spells.removeAll()
            canLoadMore = true
        }
        
        guard canLoadMore else { return }
        
        state = .loading
        
        do {
            let response = try await service.fetchSpells(
                page: currentPage,
                limit: pageLimit,
                sort: sortOption.sortQueryValue
            )
            let newSpells = response.data
            
            if reset || currentPage == 1 {
                spells = newSpells
            } else {
                spells.append(contentsOf: newSpells)
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
        await loadSpells(reset: true)
    }
}
