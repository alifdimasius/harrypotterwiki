//
//  RecommendationsView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct RecommendationsView: View {
    @State private var viewModel = RecommendationsViewModel()
    
    var body: some View {
        @Bindable var bindedViewModel = viewModel
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    content(for: bindedViewModel)
                    
                    Button(action: {
                        Task {
                            await viewModel.loadRandomRecommendation()
                        }
                    }) {
                        Label("Feeling Something Else", systemImage: "shuffle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.accentColor)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .disabled(viewModel.state == .loading)
                }
            }
            .navigationTitle("Recommendation")
            .refreshable {
                await viewModel.loadRandomRecommendation()
            }
        }
        .task {
            if bindedViewModel.state == .idle {
                await viewModel.loadRandomRecommendation()
            }
        }
    }
    
    @ViewBuilder
    private func content(for viewModel: RecommendationsViewModel) -> some View {
        switch viewModel.state {
        case .idle, .loading:
            RecommendationsLoadingStateView(message: "Finding your perfect recommendation...")
        case .success:
            if let recommendation = viewModel.recommendation {
                RecommendationCardView(recommendation: recommendation)
                    .padding(.horizontal)
                    .padding(.top, 24)
            } else {
                RecommendationsEmptyStateView()
            }
        case .failure(let message):
            RecommendationsErrorStateView(message: message) {
                Task {
                    await self.viewModel.loadRandomRecommendation()
                }
            }
        }
    }
}

private struct RecommendationCardView: View {
    let recommendation: RecommendationType
    
    var body: some View {
        VStack(spacing: 16) {
            
            Group {
                switch recommendation {
                case .book(let book):
                    BookRecommendationCard(book: book)
                case .character(let character):
                    CharacterRecommendationCard(character: character)
                case .movie(let movie):
                    MovieRecommendationCard(movie: movie)
                case .potion(let potion):
                    PotionRecommendationCard(potion: potion)
                case .spell(let spell):
                    SpellRecommendationCard(spell: spell)
                }
            }
        }
    }
}

private struct BookRecommendationCard: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 16) {
            BookCoverView(imageURL: book.attributes.cover)
                .frame(width: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Book", systemImage: "book.closed.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(book.attributes.title ?? "Untitled book")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(book.attributes.author ?? "Unknown author")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(book.attributes.summary ?? "No synopsis available.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Label(releaseYear, systemImage: "calendar")
                    Label("\(book.attributes.pages ?? 0) pages", systemImage: "book")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
    
    private var releaseYear: String {
        guard let release = book.attributes.releaseDate,
              let year = release.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }
}

private struct CharacterRecommendationCard: View {
    let character: Char
    
    var body: some View {
        HStack(spacing: 16) {
            CharacterImageView(imageURL: character.attributes.image)
                .frame(width: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Character", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(character.attributes.name ?? "Unknown name")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Label(houseText, systemImage: "house")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let species = character.attributes.species, !species.isEmpty {
                    Label(species, systemImage: "pawprint.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                if let patronus = character.attributes.patronus, !patronus.isEmpty {
                    Label("Patronus: \(patronus)", systemImage: "sparkles")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
    
    private var houseText: String {
        guard let house = character.attributes.house?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !house.isEmpty else { return "No house" }
        return house
    }
}

private struct MovieRecommendationCard: View {
    let movie: Movie
    
    var body: some View {
        HStack(spacing: 16) {
            MoviePosterView(imageURL: movie.attributes.poster)
                .frame(width: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Movie", systemImage: "film.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(movie.attributes.title ?? "Untitled movie")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                if let director = movie.attributes.directors?.first {
                    Text("Directed by \(director)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text(movie.attributes.summary ?? "No synopsis available.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                
                Spacer()
                
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(releaseYear, systemImage: "calendar")
                        if let rating = movie.attributes.rating {
                            Label(rating, systemImage: "star.fill")
                        }
                    }
                    if let runningTime = movie.attributes.runningTime {
                        Label(runningTime, systemImage: "clock")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
    
    private var releaseYear: String {
        guard let release = movie.attributes.releaseDate,
              let year = release.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }
}

private struct PotionRecommendationCard: View {
    let potion: Potion
    
    var body: some View {
        HStack(spacing: 16) {
            PotionImageView(imageURL: potion.attributes.image)
                .frame(width: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Potion", systemImage: "testtube.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(potion.attributes.name ?? "Mystery Potion")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(potion.attributes.effect ?? "Effect unknown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                if let ingredients = potion.attributes.ingredients, !ingredients.isEmpty {
                    Label(ingredientsSummary(for: ingredients), systemImage: "leaf")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Label(potion.attributes.characteristics ?? "Unknown characteristics", systemImage: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                Label(potion.attributes.difficulty ?? "Unknown difficulty", systemImage: "wand.and.stars")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
    
    private func ingredientsSummary(for ingredients: String) -> String {
        let list = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if list.count > 2 {
            return "\(list.prefix(2).joined(separator: ", ")); +\(list.count - 2) more"
        }
        return list.joined(separator: ", ")
    }
}

private struct SpellRecommendationCard: View {
    let spell: Spell
    
    var body: some View {
        HStack(spacing: 16) {
            SpellImageView(imageURL: spell.attributes.image)
                .frame(width: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Spell", systemImage: "wand.and.stars")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(spell.attributes.name ?? "Unknown spell")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(spell.attributes.effect ?? "Effect unknown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                if let incantation = spell.attributes.incantation, !incantation.isEmpty {
                    Label(incantation, systemImage: "sparkles")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                if let category = spell.attributes.category, !category.isEmpty {
                    Label(category, systemImage: "tag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if let light = spell.attributes.light, !light.isEmpty {
                    Label(light, systemImage: "wand.and.stars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Supporting Views

private struct BookCoverView: View {
    let imageURL: String?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(contentImage)
            .aspectRatio(2 / 3, contentMode: .fit)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
    }
    
    @ViewBuilder
    private var contentImage: some View {
        if let imageURL, let url = sanitizedURL(from: imageURL) {
            FailableAsyncImage(url: url)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
            Image(systemName: "book.closed.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
    
    private func sanitizedURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let directURL = URL(string: trimmed) {
            return directURL
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
        
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            return nil
        }
        
        return URL(string: encoded)
    }
}

private struct CharacterImageView: View {
    let imageURL: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .overlay(contentImage)
        }
        .aspectRatio(3 / 4, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    @ViewBuilder
    private var contentImage: some View {
        if let imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        Image(systemName: "person.crop.circle.badge.questionmark.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundStyle(.secondary)
    }
}

private struct MoviePosterView: View {
    let imageURL: String?
    
    var body: some View {
        contentImage
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
    }
    
    @ViewBuilder
    private var contentImage: some View {
        if let imageURL, let url = sanitizedURL(from: imageURL) {
            FailableAsyncImage(url: url)
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
            Image(systemName: "film.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
    
    private func sanitizedURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let directURL = URL(string: trimmed) {
            return directURL
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
        
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            return nil
        }
        
        return URL(string: encoded)
    }
}

private struct PotionImageView: View {
    let imageURL: String?
    private let imageSize = CGSize(width: 120, height: 180)
    private let cornerRadius: CGFloat = 16
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
            contentImage
        }
        .frame(width: imageSize.width, height: imageSize.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
    }
    
    @ViewBuilder
    private var contentImage: some View {
        if let imageURL, let url = sanitizedURL(from: imageURL) {
            FailableAsyncImage(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(uiColor: .tertiarySystemBackground))
            .overlay(
                Image(systemName: "testtube.2")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            )
    }
    
    private func sanitizedURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let directURL = URL(string: trimmed) {
            return directURL
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
        
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            return nil
        }
        
        return URL(string: encoded)
    }
}

private struct SpellImageView: View {
    let imageURL: String?
    private let imageSize = CGSize(width: 120, height: 180)
    private let cornerRadius: CGFloat = 16
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
            contentImage
        }
        .frame(width: imageSize.width, height: imageSize.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.black.opacity(0.05))
        )
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
    }
    
    @ViewBuilder
    private var contentImage: some View {
        if let imageURL, let url = sanitizedURL(from: imageURL) {
            FailableAsyncImage(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(uiColor: .tertiarySystemBackground))
            .overlay(
                Image(systemName: "wand.and.stars")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            )
    }
    
    private func sanitizedURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let directURL = URL(string: trimmed) {
            return directURL
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
        
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            return nil
        }
        
        return URL(string: encoded)
    }
}

private struct FailableAsyncImage: View {
    let url: URL?
    private let isRetry: Bool
    
    init(url: URL?) {
        self.init(url: url, isRetry: false)
    }
    
    private init(url: URL?, isRetry: Bool) {
        self.url = url
        self.isRetry = isRetry
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure(let error):
                if !isRetry, (error as? URLError)?.code == .cancelled {
                    FailableAsyncImage(url: url, isRetry: true)
                } else {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

private struct RecommendationsLoadingStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct RecommendationsErrorStateView: View {
    let message: String
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct RecommendationsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No recommendation available")
                .font(.headline)
            Text("Pull to refresh to try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    RecommendationsView()
}
