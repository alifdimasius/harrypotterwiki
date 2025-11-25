//
//  PotionsView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct PotionsView: View {
    @State private var viewModel = PotionsViewModel()
    
    var body: some View {
        @Bindable var bindedViewModel = viewModel
        
        NavigationStack {
            VStack(spacing: 0) {
                PotionsSortPickerView(
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
            .navigationTitle("Potions")
        }
        .task {
            if bindedViewModel.state == .idle {
                await viewModel.loadPotions(reset: true)
            }
        }
    }
    
    @ViewBuilder
    private func content(for viewModel: PotionsViewModel) -> some View {
        if viewModel.potions.isEmpty {
            switch viewModel.state {
            case .idle, .loading:
                PotionsLoadingStateView(message: "Brewing potions...")
            case .success:
                PotionsEmptyStateView()
            case .failure(let message):
                PotionsErrorStateView(message: message) {
                    Task {
                        await self.viewModel.loadPotions(reset: true)
                    }
                }
            }
        } else {
            potionsList(for: viewModel)
        }
    }
    
    private func potionsList(for viewModel: PotionsViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 18, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.potions, id: \.id) { potion in
                        PotionCardView(potion: potion)
                            .padding(.horizontal)
                            .onAppear {
                                Task {
                                    if potion.id == viewModel.potions.last?.id {
                                        await self.viewModel.loadPotions()
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
            await self.viewModel.loadPotions(reset: true)
        }
    }
}

private struct PotionCardView: View {
    let potion: Potion
    
    var body: some View {
        HStack(spacing: 16) {
            PotionImageView(imageURL: potion.attributes.image)
            
            VStack(alignment: .leading, spacing: 8) {
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

private struct PotionsSortPickerView: View {
    let selected: PotionsViewModel.SortOption
    let onSelect: (PotionsViewModel.SortOption) -> Void
    
    var body: some View {
        Picker("Sort potions", selection: Binding(
            get: { selected },
            set: { onSelect($0) }
        )) {
            ForEach(PotionsViewModel.SortOption.allCases) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct PotionsLoadingStateView: View {
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

private struct PotionsErrorStateView: View {
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

private struct PotionsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "testtube.2")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No potions yet")
                .font(.headline)
            Text("Pull to refresh to try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    PotionsView()
}
