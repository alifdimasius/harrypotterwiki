//
//  ContentViewModel.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

@Observable
final class ContentViewModel {
    enum Tab: String, CaseIterable, Identifiable {
        case recommendations
        case wizardingWorld
        case stories
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .recommendations: return "safari"
            case .wizardingWorld: return "wand.and.stars"
            case .stories: return "books.vertical"
            }
        }
        
        var title: String {
            switch self {
            case .recommendations: return "For You"
            case .wizardingWorld: return "Wizarding World"
            case .stories: return "Stories"
            }
        }
    }
    
    var selectedTab: Tab = .recommendations
}
