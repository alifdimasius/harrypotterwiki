//
//  MoviesViewModel.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 26/11/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class MoviesViewModel {
    enum FetchState: Equatable {
        case idle
        case loading
        case success
        case failure(message: String)
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case titleAscending
        case titleDescending
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .titleAscending:
                return "Title ↑"
            case .titleDescending:
                return "Title ↓"
            }
        }
        
        var sortQueryValue: String {
            switch self {
            case .titleAscending:
                return "title"
            case .titleDescending:
                return "-title"
            }
        }
    }
    
    private let service: MovieServicing
    private(set) var movies: [Movie] = []
    private(set) var state: FetchState = .idle
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private(set) var sortOption: SortOption = .titleAscending
    
    private let pageLimit: Int
    
    init(
        service: MovieServicing = MovieService(),
        pageLimit: Int = 20
    ) {
        self.service = service
        self.pageLimit = pageLimit
    }
    
    func loadMovies(reset: Bool = false) async {
        guard state != .loading else { return }
        
        if reset {
            currentPage = 1
            movies.removeAll()
            canLoadMore = true
        }
        
        guard canLoadMore else { return }
        
        state = .loading
        
        do {
            let response = try await service.fetchMovies(
                page: currentPage,
                limit: pageLimit,
                sort: sortOption.sortQueryValue
            )
            let newMovies = response.data
            
            if reset || currentPage == 1 {
                movies = newMovies
            } else {
                movies.append(contentsOf: newMovies)
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
        await loadMovies(reset: true)
    }
}
