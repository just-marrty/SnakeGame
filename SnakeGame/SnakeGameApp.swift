//
//  SnakeGameApp.swift
//  SnakeGame
//
//  Created by Martin Hrbáček on 19.06.2025.
//

import SwiftUI

@main
struct SnakeGameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // portrain mode only
    let persistenceController = PersistenceController.shared

    init() {
        // Výpis všech dostupných fontů pro debug
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)") // zobrazí název rodiny fontu
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print("   - \(fontName)") // vypíše skutečný název fontu
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            LoadingView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
