//
//  EditConcertView.swift
//  ConcertLibraryTutorial
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditConcertView: View {
    @Bindable var concert: Concert
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Photo Management Section
                photoManagementSection
                
                VStack(spacing: 24) {
                    // Main Info Section
                    InputSection(title: "The Experience", icon: "music.mic") {
                        CustomTextField("Concert Title", text: $concert.title, icon: "textformat")
                        
                        CustomTextField("Artist Name", text: $concert.artist, icon: "person.circle")
                        
                        CustomTextField("Venue Location", text: $concert.location, icon: "mappin.and.ellipse")
                    }
                    
                    // Date Section
                    InputSection(title: "When", icon: "calendar") {
                        DatePicker("Date of the event", selection: $concert.date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.accentColor)
                    }
                    
                    // Description Section
                    InputSection(title: "Memories", icon: "note.text") {
                        TextEditor(text: $concert.concertDescription)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Edit Experience")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
                .bold()
            }
        }
    }
    
    private var photoManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
                Label("Add More Photos", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor))
                    .padding(.horizontal)
            }
            .onChange(of: selectedItems) { _, newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            let newImage = ConcertImage(data: data, concert: concert)
                            if concert.images == nil {
                                concert.images = []
                            }
                            concert.images?.append(newImage)
                        }
                    }
                    selectedItems.removeAll()
                }
            }
            
            if let currentImages = concert.images, !currentImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(currentImages) { image in
                            if let data = image.data, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 160)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if let index = concert.images?.firstIndex(where: { $0.id == image.id }) {
                                                if let imageToDelete = concert.images?.remove(at: index) {
                                                    modelContext.delete(imageToDelete)
                                                }
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, .red)
                                            .font(.title2)
                                    }
                                    .padding(4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 160)
            }
        }
        .padding(.top)
    }
}
