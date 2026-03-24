//
//  ConcertLibraryTutorialApp.swift
//  ConcertLibraryTutorial
//
//  Created by Michele Coppola on 10/03/2026.
//

import SwiftUI
import SwiftData

@main
struct ConcertLibraryTutorialApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ConcertsView()
        }
        .modelContainer(persistenceController.container)
    }
}
