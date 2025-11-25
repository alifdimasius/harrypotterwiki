//
//  CharactersView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct CharactersView: View {
    @State private var viewModel = CharactersViewModel()
    
    var body: some View {
        @Bindable var bindedViewModel = viewModel
        
        VStack(spacing: 0) {
            SortPickerView(
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
        .navigationTitle("Characters")
        .task {
            if bindedViewModel.state == .idle {
                await viewModel.loadCharacters(reset: true)
            }
        }
    }
    
    @ViewBuilder
    private func content(for viewModel: CharactersViewModel) -> some View {
        if viewModel.characters.isEmpty {
            switch viewModel.state {
            case .idle, .loading:
                LoadingStateView(message: "Fetching characters...")
            case .success:
                EmptyStateView()
            case .failure(let message):
                ErrorStateView(message: message) {
                    Task {
                        await self.viewModel.loadCharacters(reset: true)
                    }
                }
            }
        } else {
            characterList(for: viewModel)
        }
    }
    
    private func characterList(for viewModel: CharactersViewModel) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.characters, id: \.id) { character in
                    CharacterCard(character: character)
                        .onAppear {
                            Task {
                                if character.id == viewModel.characters.last?.id {
                                    await self.viewModel.loadCharacters()
                                }
                            }
                        }
                }
                
                if case .loading = viewModel.state {
                    ProgressView()
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .gridCellColumns(columns.count)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await self.viewModel.loadCharacters(reset: true)
        }
    }
}

private struct CharacterCard: View {
    let character: Char
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CharacterImageView(imageURL: character.attributes.image)
                .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(character.attributes.name ?? "Unknown name")
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Label(houseText, systemImage: "house")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("aka \(aliasText)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var houseText: String {
        guard let house = character.attributes.house?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !house.isEmpty else { return "None" }
        return house
    }
    
    private var aliasText: String {
        guard let alias = character.attributes.aliasNames?
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !alias.isEmpty else { return "None" }
        return alias
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

private struct SortPickerView: View {
    let selected: CharactersViewModel.SortOption
    let onSelect: (CharactersViewModel.SortOption) -> Void
    
    var body: some View {
        Picker("Sort Order", selection: Binding(
            get: { selected },
            set: { onSelect($0) }
        )) {
            ForEach(CharactersViewModel.SortOption.allCases) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct LoadingStateView: View {
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

private struct ErrorStateView: View {
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

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.3.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No characters yet")
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
    CharactersView()
}
