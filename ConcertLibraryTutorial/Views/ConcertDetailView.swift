//
//  ConcertDetailView.swift
//  ConcertLibraryTutorial
//

import SwiftUI
import SwiftData

struct ConcertDetailView: View {
    let concert: Concert
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Parallax Header / Gallery
                headerGallery
                
                VStack(alignment: .leading, spacing: 24) {
                    // Title and Artist
                    VStack(alignment: .leading, spacing: 8) {
                        Text(concert.artist)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.accent)
                        
                        Text(concert.title)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .lineLimit(2)
                    }
                    .padding(.top, 24)
                    
                    // Info Cards (Fact Sheet)
                    HStack(spacing: 12) {
                        InfoCard(title: "Date", value: concert.date.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                        InfoCard(title: "Location", value: concert.location, icon: "mappin.and.ellipse")
                    }
                    
                    Divider()
                    
                    // Editorial Description
                    VStack(alignment: .leading, spacing: 16) {
                        Label("THE EXPERIENCE", systemImage: "quote.opening")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        
                        Text(concert.concertDescription)
                            .font(.system(.body, design: .serif))
                            .lineSpacing(6)
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .offset(y: -32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditConcertView(concert: concert)
            }
        }
        .alert("Delete Concert?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteConcert()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this experience? This action cannot be undone.")
        }
    }
    
    private func deleteConcert() {
        modelContext.delete(concert)
        try? modelContext.save()
        dismiss()
    }
    
    private var headerGallery: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            
            Group {
                if let images = concert.images, !images.isEmpty {
                    TabView {
                        ForEach(images) { image in
                            if let data = image.data, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                } else {
                    Rectangle()
                        .fill(LinearGradient(colors: [.accentColor, .purple], startPoint: .top, endPoint: .bottom))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height + (minY > 0 ? minY : 0))
            .clipped()
            .offset(y: minY > 0 ? -minY : 0)
        }
        .frame(height: 400)
    }
}

// MARK: - Subviews

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.accent)
                Text(title.uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
