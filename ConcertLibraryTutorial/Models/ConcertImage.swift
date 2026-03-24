import Foundation
import SwiftData

@Model
final class ConcertImage {
    var id: UUID = UUID()
    
    @Attribute(.externalStorage)
    var data: Data?
    
    var concert: Concert?
    
    init(id: UUID = UUID(), data: Data? = nil, concert: Concert? = nil) {
        self.id = id
        self.data = data
        self.concert = concert
    }
}
