import SwiftUI

@MainActor
final class UserSettings: ObservableObject {
    @Published var selectedTheme: AppTheme = .system
    @Published var selectedLanguage: Language = .english
    @Published var hideTotalAmount: Bool = false
    @Published var defaultCurrency: String = "RUB"
    @Published var notificationsEnabled: Bool = true
    
    enum AppTheme: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return nil
            }
        }
        
        func localizedName(for language: Language) -> String {
            switch self {
            case .light:
                switch language {
                case .english: return "Light"
                case .russian: return "Светлая"
                case .chinese: return "浅色"
                }
            case .dark:
                switch language {
                case .english: return "Dark"
                case .russian: return "Тёмная"
                case .chinese: return "深色"
                }
            case .system:
                switch language {
                case .english: return "System"
                case .russian: return "Системная"
                case .chinese: return "系统"
                }
            }
        }
    }
    
    enum Language: String, CaseIterable {
        case english = "en"
        case russian = "ru"
        case chinese = "zh-Hans"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .russian: return "Русский"
            case .chinese: return "中文"
            }
        }
        
        var localizedName: String {
            return displayName
        }
    }
    
    // Compatibility alias
    typealias AppLanguage = Language
    
    private let themeKey = "selectedTheme"
    private let languageKey = "selectedLanguage"
    private let hideTotalAmountKey = "hideTotalAmount"
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let themeString = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: themeString) {
            selectedTheme = theme
        }
        
        if let languageString = UserDefaults.standard.string(forKey: languageKey),
           let language = Language(rawValue: languageString) {
            selectedLanguage = language
        }
        
        // Load hide total amount preference
        if UserDefaults.standard.object(forKey: hideTotalAmountKey) != nil {
            hideTotalAmount = UserDefaults.standard.bool(forKey: hideTotalAmountKey)
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: themeKey)
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: languageKey)
        UserDefaults.standard.set(hideTotalAmount, forKey: hideTotalAmountKey)
    }
    
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
        saveSettings()
    }
    
    func updateLanguage(_ language: Language) {
        selectedLanguage = language
        saveSettings()
    }
    
    func updateHideTotalAmount(_ hide: Bool) {
        hideTotalAmount = hide
        saveSettings()
    }
}
