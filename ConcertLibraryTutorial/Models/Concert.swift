import Foundation
import SwiftData

@Model
final class Concert {
    var id: UUID = UUID()
    var title: String = ""
    var artist: String = ""
    var concertDescription: String = ""
    var date: Date = Date.now
    var location: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \ConcertImage.concert)
    var images: [ConcertImage]? = []
    
    init(id: UUID = UUID(), title: String = "", artist: String = "", concertDescription: String = "", date: Date = Date.now, location: String = "", images: [ConcertImage]? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.concertDescription = concertDescription
        self.date = date
        self.location = location
        self.images = images
    }
}
