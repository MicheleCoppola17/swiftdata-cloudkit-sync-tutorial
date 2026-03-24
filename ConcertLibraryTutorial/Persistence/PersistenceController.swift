import SwiftData
import Foundation

@MainActor
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: ModelContainer
    
    init(inMemory: Bool = false) {
        let schema = Schema([Concert.self, ConcertImage.self])
        let modelConfiguration: ModelConfiguration
        
        if inMemory {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            modelConfiguration = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .private("iCloud.michele.coppola.ConcertLib")
            )
        }
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
