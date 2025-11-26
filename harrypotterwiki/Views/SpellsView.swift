//
//  SpellsView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct SpellsView: View {
    @State private var viewModel = SpellsViewModel()
    
    var body: some View {
        @Bindable var bindedViewModel = viewModel
        
        NavigationStack {
            VStack(spacing: 0) {
                SpellsSortPickerView(
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
            .navigationTitle("Spells")
        }
        .task {
            if bindedViewModel.state == .idle {
                await viewModel.loadSpells(reset: true)
            }
        }
    }
    
    @ViewBuilder
    private func content(for viewModel: SpellsViewModel) -> some View {
        if viewModel.spells.isEmpty {
            switch viewModel.state {
            case .idle, .loading:
                SpellsLoadingStateView(message: "Casting spells...")
            case .success:
                SpellsEmptyStateView()
            case .failure(let message):
                SpellsErrorStateView(message: message) {
                    Task {
                        await self.viewModel.loadSpells(reset: true)
                    }
                }
            }
        } else {
            spellsList(for: viewModel)
        }
    }
    
    private func spellsList(for viewModel: SpellsViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 18, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.spells, id: \.id) { spell in
                        SpellCardView(spell: spell)
                            .padding(.horizontal)
                            .onAppear {
                                Task {
                                    if spell.id == viewModel.spells.last?.id {
                                        await self.viewModel.loadSpells()
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
            await self.viewModel.loadSpells(reset: true)
        }
    }
}

private struct SpellCardView: View {
    let spell: Spell
    
    var body: some View {
        HStack(spacing: 16) {
            SpellImageView(imageURL: spell.attributes.image)
            
            VStack(alignment: .leading, spacing: 8) {
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

private struct SpellsSortPickerView: View {
    let selected: SpellsViewModel.SortOption
    let onSelect: (SpellsViewModel.SortOption) -> Void
    
    var body: some View {
        Picker("Sort spells", selection: Binding(
            get: { selected },
            set: { onSelect($0) }
        )) {
            ForEach(SpellsViewModel.SortOption.allCases) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct SpellsLoadingStateView: View {
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

private struct SpellsErrorStateView: View {
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

private struct SpellsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "wand.and.stars")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No spells yet")
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
    SpellsView()
}
