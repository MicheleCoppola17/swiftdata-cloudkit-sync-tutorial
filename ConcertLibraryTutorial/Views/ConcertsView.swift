//
//  ConcertsView.swift
//  ConcertLibraryTutorial
//
//  Created by Michele Coppola on 10/03/2026.
//

import SwiftUI
import SwiftData

struct ConcertsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Concert.date, order: .reverse) private var concerts: [Concert]
    
    @State private var showingAddConcert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if concerts.isEmpty {
                    ContentUnavailableView("No Concerts",
                                           systemImage: "music.mic",
                                           description: Text("Tap the + button to add your first concert."))
                } else {
                    List {
                        ForEach(concerts) { concert in
                            NavigationLink(value: concert) {
                                VStack(alignment: .leading) {
                                    Text(concert.title)
                                        .font(.headline)
                                    Text(concert.artist)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(concert.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .onDelete(perform: deleteConcerts)
                    }
                }
            }
            .navigationTitle("Concerts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddConcert = true
                    }) {
                        Image(systemName: "plus")
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
    
    private func deleteConcerts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(concerts[index])
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    ConcertsView()
        .modelContainer(for: Concert.self, inMemory: true)
}
