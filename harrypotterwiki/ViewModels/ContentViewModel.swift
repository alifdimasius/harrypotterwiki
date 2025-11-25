//
//  SwiftUIView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

@Observable
final class ContentViewModel {
    enum Tab: String, CaseIterable, Identifiable {
        case recommendations
        case book
        case character
        case movies
        case potions
        case spells
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .recommendations: return "safari"
            case .book: return "book"
            case .character: return "person.3"
            case .movies: return "cinema"
            case .potions: return "flask"
            case .spells: return "sparkles"
            }
        }
        
        var title: String {
            switch self {
            case .recommendations: return "Recommendations"
            case .book: return "Books"
            case .character: return "Characters"
            case .movies: return "Movies"
            case .potions: return "Potions"
            case .spells: return "Spells"
            }
        }
    }
}
