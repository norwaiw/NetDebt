import SwiftUI

@main
struct DebtTrackerApp: App {
    @StateObject private var debtStore = DebtStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(debtStore)
        }
    }
}