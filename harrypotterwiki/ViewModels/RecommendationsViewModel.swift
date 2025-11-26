//
//  RecommendationsViewModel.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 26/11/25.
//

import Foundation
import SwiftUI

enum RecommendationType {
    case book(Book)
    case character(Char)
    case movie(Movie)
    case potion(Potion)
    case spell(Spell)
}

@MainActor
@Observable
final class RecommendationsViewModel {
    enum FetchState: Equatable {
        case idle
        case loading
        case success
        case failure(message: String)
    }
    
    private let bookService: BookServicing
    private let characterService: CharacterServicing
    private let movieService: MovieServicing
    private let potionService: PotionServicing
    private let spellService: SpellServicing
    
    private(set) var recommendation: RecommendationType?
    private(set) var state: FetchState = .idle
    
    init(
        bookService: BookServicing = BookService(),
        characterService: CharacterServicing = CharacterService(),
        movieService: MovieServicing = MovieService(),
        potionService: PotionServicing = PotionService(),
        spellService: SpellServicing = SpellService()
    ) {
        self.bookService = bookService
        self.characterService = characterService
        self.movieService = movieService
        self.potionService = potionService
        self.spellService = spellService
    }
    
    func loadRandomRecommendation() async {
        guard state != .loading else { return }
        
        state = .loading
        
        do {
            let categories: [RecommendationCategory] = [.book, .character, .movie, .potion, .spell]
            let randomCategory = categories.randomElement()!
            
            let recommendation = try await fetchRandomItem(from: randomCategory)
            self.recommendation = recommendation
            state = .success
        } catch {
            state = .failure(message: error.localizedDescription)
        }
    }
    
    private enum RecommendationCategory {
        case book
        case character
        case movie
        case potion
        case spell
    }
    
    private func fetchRandomItem(from category: RecommendationCategory) async throws -> RecommendationType {
        let limit = 10
        
        switch category {
        case .book:
            let response = try await bookService.fetchBooks(page: 1, limit: limit, sort: nil)
            guard let randomBook = response.data.randomElement() else {
                throw NSError(domain: "RecommendationsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No books available"])
            }
            return .book(randomBook)
            
        case .character:
            let response = try await characterService.fetchCharacters(page: 1, limit: limit, sort: nil)
            guard let randomCharacter = response.data.randomElement() else {
                throw NSError(domain: "RecommendationsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No characters available"])
            }
            return .character(randomCharacter)
            
        case .movie:
            let response = try await movieService.fetchMovies(page: 1, limit: limit, sort: nil)
            guard let randomMovie = response.data.randomElement() else {
                throw NSError(domain: "RecommendationsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No movies available"])
            }
            return .movie(randomMovie)
            
        case .potion:
            let response = try await potionService.fetchPotions(page: 1, limit: limit, sort: nil)
            guard let randomPotion = response.data.randomElement() else {
                throw NSError(domain: "RecommendationsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No potions available"])
            }
            return .potion(randomPotion)
            
        case .spell:
            let response = try await spellService.fetchSpells(page: 1, limit: limit, sort: nil)
            guard let randomSpell = response.data.randomElement() else {
                throw NSError(domain: "RecommendationsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No spells available"])
            }
            return .spell(randomSpell)
        }
    }
}

