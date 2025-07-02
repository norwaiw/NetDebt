import SwiftUI

@main
struct DebtTrackerApp: App {
    @StateObject private var debtStore = DebtStore()
    @StateObject private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(debtStore)
                .environmentObject(userSettings)
                .preferredColorScheme(userSettings.selectedTheme.colorScheme)
        }
    }
}