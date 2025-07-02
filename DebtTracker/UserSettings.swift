import SwiftUI
import Foundation

class UserSettings: ObservableObject {
    @Published var selectedTheme: AppTheme = .system
    @Published var selectedLanguage: AppLanguage = .english
    
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
        
        func localizedName(for language: AppLanguage) -> String {
            switch self {
            case .light:
                return language == .english ? "Light" : "Светлая"
            case .dark:
                return language == .english ? "Dark" : "Тёмная"
            case .system:
                return language == .english ? "System" : "Системная"
            }
        }
    }
    
    enum AppLanguage: String, CaseIterable {
        case english = "en"
        case russian = "ru"
        
        var localizedName: String {
            switch self {
            case .english:
                return "English"
            case .russian:
                return "Русский"
            }
        }
        
        var locale: Locale {
            return Locale(identifier: rawValue)
        }
    }
    
    private let themeKey = "selectedTheme"
    private let languageKey = "selectedLanguage"
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let themeString = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: themeString) {
            selectedTheme = theme
        }
        
        if let languageString = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: languageString) {
            selectedLanguage = language
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: themeKey)
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: languageKey)
    }
    
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
        saveSettings()
    }
    
    func updateLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        saveSettings()
    }
}