//
//  BooksViewModel.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class BooksViewModel {
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
    
    private let service: BookServicing
    private(set) var books: [Book] = []
    private(set) var state: FetchState = .idle
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private(set) var sortOption: SortOption = .titleAscending
    
    private let pageLimit: Int
    
    init(
        service: BookServicing = BookService(),
        pageLimit: Int = 20
    ) {
        self.service = service
        self.pageLimit = pageLimit
    }
    
    func loadBooks(reset: Bool = false) async {
        guard state != .loading else { return }
        
        if reset {
            currentPage = 1
            books.removeAll()
            canLoadMore = true
        }
        
        guard canLoadMore else { return }
        
        state = .loading
        
        do {
            let response = try await service.fetchBooks(
                page: currentPage,
                limit: pageLimit,
                sort: sortOption.sortQueryValue
            )
            let newBooks = response.data
            
            if reset || currentPage == 1 {
                books = newBooks
            } else {
                books.append(contentsOf: newBooks)
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
        await loadBooks(reset: true)
    }
}
