//
//  BooksDetailView.swift
//  harrypotterwiki
//
//  Created by Alif Dimasius on 25/11/25.
//

import SwiftUI

struct BooksDetailView: View {
    let book: Book
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                heroSection
                    .padding(.top, 24)
                
                statsSection
                
                summarySection
                
                detailsSection
                
                if let wikiURL = sanitizedURL(from: book.attributes.wiki) {
                    externalLinkSection(url: wikiURL)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(heroBackground)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            BookCoverHeroView(imageURL: sanitizedURL(from: book.attributes.cover))
                .frame(width: 200)
                .padding(.top, 8)
            
            VStack(spacing: 8) {
                Text(book.attributes.title ?? "Untitled book")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text(book.attributes.author ?? "Unknown author")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            chipRow
        }
        .frame(maxWidth: .infinity)
    }
    
    private var chipRow: some View {
        HStack(spacing: 12) {
            if let releaseYear {
                BookInfoChip(icon: "calendar", text: releaseYear)
            }
            
            BookInfoChip(icon: "book", text: pagesText)
            
            if !chapterCountText.isEmpty {
                BookInfoChip(icon: "list.number", text: chapterCountText)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(title: "Pages", value: pagesValue)
            StatCard(title: "Release", value: releaseDateText)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.title2.bold())
            Text(book.attributes.summary ?? "No summary has been provided for this book yet.")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.title2.bold())
            
            VStack(spacing: 0) {
                BookMetadataRow(label: "Author", value: book.attributes.author ?? "Unknown", showsDivider: false)
                BookMetadataRow(label: "Release date", value: releaseDateText)
                BookMetadataRow(label: "Pages", value: pagesText)
                
                if let dedication = book.attributes.dedication, !dedication.isEmpty {
                    BookMetadataRow(label: "Dedication", value: dedication)
                }
                
                BookMetadataRow(label: "Slug", value: book.attributes.slug)
                BookMetadataRow(label: "ID", value: book.id)
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.05))
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func externalLinkSection(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More on the web")
                .font(.title2.bold())
            Link(destination: url) {
                HStack {
                    Image(systemName: "safari")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Open wiki entry")
                            .font(.headline)
                        Text(url.host ?? url.absoluteString)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var heroBackground: some View {
        LinearGradient(
            colors: [
                Color(uiColor: .systemGray6),
                Color(uiColor: .systemBackground)
            ],
            startPoint: .top,
            endPoint: .center
        )
    }
    
    private var releaseYear: String? {
        guard let releaseDate = book.attributes.releaseDate,
              let year = releaseDate.split(separator: "-").first else {
            return nil
        }
        return String(year)
    }
    
    private var pagesText: String {
        guard let pages = book.attributes.pages, pages > 0 else {
            return "Unknown length"
        }
        return "\(pages) pages"
    }
    
    private var pagesValue: String {
        guard let pages = book.attributes.pages, pages > 0 else {
            return "--"
        }
        return "\(pages)"
    }
    
    private var releaseDateText: String {
        guard let release = book.attributes.releaseDate,
              let date = DateFormatter.potterAPIDate.date(from: release) else {
            return "Unknown"
        }
        return DateFormatter.displayDate.string(from: date)
    }
    
    private var chapterCountText: String {
        let count = book.relationships.chapters.data.count
        return count > 0 ? "\(count) chapters" : ""
    }
    
    private func sanitizedURL(from string: String?) -> URL? {
        guard let string else { return nil }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed) {
            return url
        }
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            return nil
        }
        return URL(string: encoded)
    }
}

private struct BookCoverHeroView: View {
    let imageURL: URL?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(contentImage)
            .aspectRatio(2 / 3, contentMode: .fit)
            .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 20)
    }
    
    @ViewBuilder
    private var contentImage: some View {
        if let imageURL {
            AsyncImage(url: imageURL) { phase in
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
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemBackground))
            Image(systemName: "book.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
}

private struct BookInfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.footnote.weight(.semibold))
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            Capsule(style: .continuous)
                .fill(Color(uiColor: .systemGray6))
        )
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

private struct BookMetadataRow: View {
    let label: String
    let value: String
    var showsDivider: Bool = true
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .overlay(alignment: .top) {
            if showsDivider {
                Divider()
            }
        }
    }
}

private extension DateFormatter {
    static let potterAPIDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

#Preview {
    NavigationStack {
        BooksDetailView(
            book: .init(
                id: "1",
                type: "book",
                attributes: .init(
                    slug: "sorcerers-stone",
                    author: "J.K. Rowling",
                    cover: nil,
                    dedication: "For Jessica, who loves stories.",
                    pages: 309,
                    releaseDate: "1997-06-26",
                    summary: "Harry Potter discovers he is a wizard and attends Hogwarts.",
                    title: "Harry Potter and the Sorcerer's Stone",
                    wiki: "https://www.wizardingworld.com"
                ),
                relationships: .init(
                    chapters: .init(
                        data: (1...17).map { ChapterData(id: "\($0)", type: "chapter") }
                    )
                ),
                links: .init(self: nil)
            )
        )
    }
}
