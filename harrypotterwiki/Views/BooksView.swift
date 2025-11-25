//
//  BooksView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct BooksView: View {
    @State private var viewModel = BooksViewModel()
    
    var body: some View {
        @Bindable var bindedViewModel = viewModel
        
        NavigationStack {
            VStack(spacing: 0) {
                BooksSortPickerView(
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
            .navigationTitle("Books")
        }
        .task {
            if bindedViewModel.state == .idle {
                await viewModel.loadBooks(reset: true)
            }
        }
    }
    
    @ViewBuilder
    private func content(for viewModel: BooksViewModel) -> some View {
        if viewModel.books.isEmpty {
            switch viewModel.state {
            case .idle, .loading:
                BooksLoadingStateView(message: "Fetching books...")
            case .success:
                BooksEmptyStateView()
            case .failure(let message):
                BooksErrorStateView(message: message) {
                    Task {
                        await self.viewModel.loadBooks(reset: true)
                    }
                }
            }
        } else {
            bookshelf(for: viewModel)
        }
    }
    
    private func bookshelf(for viewModel: BooksViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 18, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.books, id: \.id) { book in
                        NavigationLink {
                            BooksDetailView(book: book)
                        } label: {
                            BookCardView(book: book)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .onAppear {
                            Task {
                                if book.id == viewModel.books.last?.id {
                                    await self.viewModel.loadBooks()
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
            await self.viewModel.loadBooks(reset: true)
        }
    }
}

private struct BookCardView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 16) {
            BookCoverView(imageURL: book.attributes.cover)
                .frame(width: 120)
            
            VStack(alignment: .leading, spacing: 8) {
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

private struct BooksSortPickerView: View {
    let selected: BooksViewModel.SortOption
    let onSelect: (BooksViewModel.SortOption) -> Void
    
    var body: some View {
        Picker("Sort books", selection: Binding(
            get: { selected },
            set: { onSelect($0) }
        )) {
            ForEach(BooksViewModel.SortOption.allCases) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct BooksLoadingStateView: View {
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

private struct BooksErrorStateView: View {
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

private struct BooksEmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "books.vertical")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No books yet")
                .font(.headline)
            Text("Pull to refresh to try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BooksView()
}
