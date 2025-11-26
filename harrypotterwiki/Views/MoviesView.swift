//
//  MoviesView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct MoviesView: View {
    @State private var viewModel = MoviesViewModel()
    
    var body: some View {
        @Bindable var bindedViewModel = viewModel
        
        NavigationStack {
            VStack(spacing: 0) {
                MoviesSortPickerView(
                    selected: bindedViewModel.sortOption,
                    onSelect: { option in
                        Task {
                            await viewModel.updateSortOption(option)
                        }
                    }
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Divider()
                
                content(for: bindedViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Movies")
        }
        .task {
            if bindedViewModel.state == .idle {
                await viewModel.loadMovies(reset: true)
            }
        }
    }
    
    @ViewBuilder
    private func content(for viewModel: MoviesViewModel) -> some View {
        if viewModel.movies.isEmpty {
            switch viewModel.state {
            case .idle, .loading:
                MoviesLoadingStateView(message: "Fetching movies...")
            case .success:
                MoviesEmptyStateView()
            case .failure(let message):
                MoviesErrorStateView(message: message) {
                    Task {
                        await self.viewModel.loadMovies(reset: true)
                    }
                }
            }
        } else {
            moviesList(for: viewModel)
        }
    }
    
    private func moviesList(for viewModel: MoviesViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 18, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.movies, id: \.id) { movie in
                        NavigationLink {
                            MoviesDetailView(movie: movie)
                        } label: {
                            MovieCardView(movie: movie)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .onAppear {
                            Task {
                                if movie.id == viewModel.movies.last?.id {
                                    await self.viewModel.loadMovies()
                                }
                            }
                        }
                    }
                    
                    if case .loading = viewModel.state {
                        ProgressView()
                            .padding(.vertical)
                    }
                } 
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await self.viewModel.loadMovies(reset: true)
        }
    }
}

private struct MovieCardView: View {
    let movie: Movie
    
    var body: some View {
        HStack(spacing: 16) {
            MoviePosterView(imageURL: movie.attributes.poster)
                .frame(width: 120)
            
            VStack(alignment: .leading, spacing: 8) {
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
                
                HStack(alignment:.top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4){
                        Label(releaseYear, systemImage: "calendar")
                        if let rating = movie.attributes.rating {
                            Label(rating, systemImage: "exclamationmark.circle")
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

private struct MoviesSortPickerView: View {
    let selected: MoviesViewModel.SortOption
    let onSelect: (MoviesViewModel.SortOption) -> Void
    
    var body: some View {
        Picker("Sort movies", selection: Binding(
            get: { selected },
            set: { onSelect($0) }
        )) {
            ForEach(MoviesViewModel.SortOption.allCases) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct MoviesLoadingStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MoviesErrorStateView: View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MoviesEmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "film.stack")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No movies yet")
                .font(.headline)
            Text("Pull to refresh to try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MoviesDetailView: View {
    let movie: Movie
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(movie.attributes.title ?? "Untitled movie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(movie.attributes.summary ?? "No synopsis available.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(movie.attributes.title ?? "Movie")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MoviesView()
}
