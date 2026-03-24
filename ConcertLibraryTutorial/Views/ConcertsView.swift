//
//  ConcertsView.swift
//  ConcertLibraryTutorial
//

import SwiftUI
import SwiftData

struct ConcertsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Concert.date, order: .reverse) private var concerts: [Concert]
    
    @State private var showingAddConcert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if concerts.isEmpty {
                    VStack {
                        Spacer(minLength: 100)
                        ContentUnavailableView {
                            Label("No Concerts", systemImage: "music.mic.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.largeTitle)
                        } description: {
                            Text("Your musical journey begins here.\nTap the plus to add your first memory.")
                                .font(.subheadline)
                        } actions: {
                            Button(action: { showingAddConcert = true }) {
                                Label("Add Concert", systemImage: "plus")
                                    .bold()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }
                } else {
                    LazyVStack(spacing: 20) {
                        // Hero Card: Most Recent
                        if let heroConcert = concerts.first {
                            HeroConcertCard(concert: heroConcert)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        delete(heroConcert)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        
                        // Remaining Concerts Grid/List
                        if concerts.count > 1 {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Previous Experiences")
                                    .font(.title3.bold())
                                    .padding(.horizontal)
                                
                                ForEach(concerts.dropFirst()) { concert in
                                    NavigationLink(value: concert) {
                                        ConcertCard(concert: concert)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            delete(concert)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Experiences")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddConcert = true
                    }) {
                        Label("Add Concert", systemImage: "plus")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddConcert) {
                NavigationStack {
                    AddConcertView()
                }
            }
            .navigationDestination(for: Concert.self) { concert in
                ConcertDetailView(concert: concert)
            }
        }
    }
    
    private func delete(_ concert: Concert) {
        withAnimation {
            modelContext.delete(concert)
            try? modelContext.save()
        }
    }
}

// MARK: - Components

struct HeroConcertCard: View {
    let concert: Concert
    
    var body: some View {
        NavigationLink(value: concert) {
            ZStack(alignment: .bottomLeading) {
                if let imageData = concert.images?.first?.data, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
//                        .containerRelativeShape()
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [.accentColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 280)
                }
                
                // Gradient Overlay
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
//                    .containerRelativeShape()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("LATEST EXPERIENCE")
                        .font(.caption2.bold())
                        .kerning(1)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text(concert.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    
                    Text(concert.artist)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(24)
            }
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

struct ConcertCard: View {
    let concert: Concert
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageData = concert.images?.first?.data, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.accent.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: "music.note")
                        .foregroundStyle(.accent)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(concert.title)
                    .font(.headline)
                
                Text(concert.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(concert.date, style: .date)
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .padding(.horizontal)
    }
}

#Preview {
    ConcertsView()
        .modelContainer(for: Concert.self, inMemory: true)
}
