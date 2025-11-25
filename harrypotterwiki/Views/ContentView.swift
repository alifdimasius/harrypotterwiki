//
//  ContentView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    
    var body: some View {
        @Bindable var bindedViewModel = viewModel
        
        TabView(selection: $bindedViewModel.selectedTab) {
            NavigationStack {
                RecommendationsView()
            }
            .tabItem {
                Label(
                    ContentViewModel.Tab.recommendations.title,
                    systemImage: ContentViewModel.Tab.recommendations.systemImage)
            }
            .tag(ContentViewModel.Tab.recommendations)

            NavigationStack {
                WizardingWorldHubView()
            }
            .tabItem {
                Label(
                    ContentViewModel.Tab.wizardingWorld.title,
                    systemImage: ContentViewModel.Tab.wizardingWorld.systemImage)
            }
            .tag(ContentViewModel.Tab.wizardingWorld)
            
            NavigationStack {
                StoriesHubView()
            }
            .tabItem {
                Label(
                    ContentViewModel.Tab.stories.title,
                    systemImage: ContentViewModel.Tab.stories.systemImage)
            }
            .tag(ContentViewModel.Tab.stories)
        }
    }
}

private enum WizardingSegment: String, CaseIterable, Identifiable {
    case characters
    case potions
    case spells
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .characters: return "Characters"
        case .potions: return "Potions"
        case .spells: return "Spells"
        }
    }
}

private struct WizardingWorldHubView: View {
    @State private var segment: WizardingSegment = .characters
    
    var body: some View {
        VStack() {
            Picker("Wizarding World section", selection: $segment) {
                ForEach(WizardingSegment.allCases) { segment in
                    Text(segment.title).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Group {
                switch segment {
                case .characters: CharactersView()
                case .potions: PotionsView()
                case .spells: SpellsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Wizarding World")
    }
}

private enum StoriesSegment: String, CaseIterable, Identifiable {
    case books
    case movies
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .books: return "Books"
        case .movies: return "Movies"
        }
    }
}

private struct StoriesHubView: View {
    @State private var segment: StoriesSegment = .books
    
    var body: some View {
        VStack() {
            Picker("Stories section", selection: $segment) {
                ForEach(StoriesSegment.allCases) { segment in
                    Text(segment.title).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Group {
                switch segment {
                case .books: BooksView()
                case .movies: MoviesView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Stories")
    }
}

#Preview {
    ContentView()
}
