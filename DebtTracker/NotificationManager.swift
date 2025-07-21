import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() { }

    // Keep track of the latest authorisation status so we don't schedule when denied.
    private var authorizationGranted: Bool = false

    // Ask the user for permission to show notifications. Call this once – for example, on app launch.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("[NotificationManager] Authorization error: \(error.localizedDescription)")
            } else {
                print("[NotificationManager] Authorization granted: \(granted)")
                self.authorizationGranted = granted
            }
        }
    }

    // Schedule a one-off notification that fires `daysBefore` days before the debt's due date.
    func scheduleNotification(for debt: Debt, daysBefore: Int = 3) {
        guard authorizationGranted else {
            // If we haven't asked yet, request now and exit; caller can retry later.
            requestAuthorization()
            print("[NotificationManager] Cannot schedule – not authorised yet.")
            return
        }

        guard let dueDate = debt.dueDate, !debt.isPaid else { return }

        // Calculate the trigger date (due date minus the offset).
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: dueDate) else { return }
        // Do not schedule anything in the past.
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Debt due soon"
        // Basic body text. In a production app you might localise this string.
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        content.body = "\(debt.personName) - \(debt.description ?? "Debt") is due on \(formatter.string(from: dueDate))."
        content.sound = .default
        // Store the debt id so the app can react when the notification is tapped.
        content.userInfo = ["debtId": debt.id.uuidString]

        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        let request = UNNotificationRequest(identifier: debt.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Scheduling error: \(error.localizedDescription)")
            } else {
                print("[NotificationManager] Scheduled notification for debt \(debt.id)")
            }
        }
    }

    // Remove any pending notification that belongs to the given debt.
    func cancelNotification(for debt: Debt) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [debt.id.uuidString])
        print("[NotificationManager] Cancelled notification for debt \(debt.id)")
    }
}