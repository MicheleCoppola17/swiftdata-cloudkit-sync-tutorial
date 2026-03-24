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
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $title)
                TextField("Artist", text: $artist)
                TextField("Location", text: $location)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            
            Section("Notes") {
                TextField("Description", text: $concertDescription, axis: .vertical)
                    .lineLimit(4...10)
            }
            
            Section("Photos") {
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
                    Label("Select Photos", systemImage: "photo.on.rectangle")
                }
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
                
                if !selectedImageData.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImageData, id: \.self) { data in
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .frame(height: 110)
                }
            }
        }
        .navigationTitle("Add Concert")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveConcert()
                }
                .disabled(title.isEmpty || artist.isEmpty)
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

#Preview {
    NavigationStack {
        AddConcertView()
            .modelContainer(for: Concert.self, inMemory: true)
    }
}
