import SwiftUI
import SwiftData

struct ConcertDetailView: View {
    let concert: Concert
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let currentImages = concert.images, !currentImages.isEmpty {
                    TabView {
                        ForEach(currentImages) { image in
                            if let data = image.data, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(concert.title)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(concert.artist)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(concert.date, style: .date)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(concert.location)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding(.vertical)
                    
                    Text("Description")
                        .font(.headline)
                    
                    Text(concert.concertDescription)
                        .font(.body)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditConcertView(concert: concert)
            }
        }
    }
}
