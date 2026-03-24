import SwiftUI
import SwiftData
import PhotosUI

struct EditConcertView: View {
    @Bindable var concert: Concert
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Title", text: $concert.title)
                TextField("Artist", text: $concert.artist)
                TextField("Location", text: $concert.location)
                DatePicker("Date", selection: $concert.date, displayedComponents: .date)
            }
            
            Section("Notes") {
                TextField("Description", text: $concert.concertDescription, axis: .vertical)
                    .lineLimit(4...10)
            }
            
            Section("Photos") {
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
                    Label("Add Photos", systemImage: "photo.on.rectangle")
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
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(currentImages) { image in
                                if let data = image.data, let uiImage = UIImage(data: data) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        Button(action: {
                                            if let index = concert.images?.firstIndex(where: { $0.id == image.id }) {
                                                if let imageToDelete = concert.images?.remove(at: index) {
                                                    modelContext.delete(imageToDelete)
                                                }
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .red)
                                                .padding(4)
                                                .background(Circle().fill(.black.opacity(0.3)))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 110)
                }
            }
        }
        .navigationTitle("Edit Concert")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
