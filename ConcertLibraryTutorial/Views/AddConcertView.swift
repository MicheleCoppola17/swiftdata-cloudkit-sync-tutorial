//
//  AddConcertView.swift
//  ConcertLibraryTutorial
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddConcertView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var concertDescription: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, artist, location, description
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header Image Picker / Preview
                imageSelectionHeader
                
                VStack(spacing: 24) {
                    // Main Info Section
                    InputSection(title: "The Experience", icon: "music.mic") {
                        CustomTextField("Concert Title", text: $title, icon: "textformat")
                            .focused($focusedField, equals: .title)
                        
                        CustomTextField("Artist Name", text: $artist, icon: "person.circle")
                            .focused($focusedField, equals: .artist)
                        
                        CustomTextField("Venue Location", text: $location, icon: "mappin.and.ellipse")
                            .focused($focusedField, equals: .location)
                    }
                    
                    // Date Section
                    InputSection(title: "When", icon: "calendar") {
                        DatePicker("Date of the event", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.accentColor)
                    }
                    
                    // Description Section
                    InputSection(title: "Memories", icon: "note.text") {
                        TextEditor(text: $concertDescription)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                            .focused($focusedField, equals: .description)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("New Experience")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveConcert() }
                    .bold()
                    .disabled(title.isEmpty || artist.isEmpty)
            }
        }
    }
    
    private var imageSelectionHeader: some View {
        PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
            ZStack {
                if selectedImageData.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.viewfinder")
                            .font(.system(size: 40))
                        Text("Add Photos")
                            .font(.headline)
                    }
                    .foregroundStyle(.accent)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(.accent.opacity(0.1))
                    )
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(selectedImageData, id: \.self) { data in
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 200)
                    .padding(.vertical, 20)
                }
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selectedItems) { _, newItems in
            Task {
                selectedImageData.removeAll()
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        selectedImageData.append(data)
                    }
                }
            }
        }
    }
    
    private func saveConcert() {
        let newConcert = Concert(title: title, artist: artist, concertDescription: concertDescription, date: date, location: location)
        let images = selectedImageData.map { ConcertImage(data: $0, concert: newConcert) }
        newConcert.images = images
        modelContext.insert(newConcert)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Reusable Components

struct InputSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title.uppercased(), systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    init(_ placeholder: String, text: Binding<String>, icon: String) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.accent)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AddConcertView()
    }
}
