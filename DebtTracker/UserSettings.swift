import SwiftUI
import Foundation

@MainActor
final class UserSettings: ObservableObject {
    @Published var selectedTheme: AppTheme = .system
    @Published var selectedLanguage: AppLanguage = .english
    @Published var showTotalAmounts: Bool = true
    
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
    
    enum AppLanguage: String, CaseIterable {
        case english = "en"
        case russian = "ru"
        case chinese = "zh-Hans"
        
        var localizedName: String {
            switch self {
            case .english:
                return "English"
            case .russian:
                return "Русский"
            case .chinese:
                return "中文"
            }
        }
        
        var locale: Locale {
            return Locale(identifier: rawValue)
        }
    }
    
    private let themeKey = "selectedTheme"
    private let languageKey = "selectedLanguage"
    private let showAmountsKey = "showTotalAmounts"
    
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
        
        showTotalAmounts = UserDefaults.standard.object(forKey: showAmountsKey) as? Bool ?? true
    }
    
    func saveSettings() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: themeKey)
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: languageKey)
        UserDefaults.standard.set(showTotalAmounts, forKey: showAmountsKey)
    }
    
    func updateTheme(_ theme: AppTheme) {
        selectedTheme = theme
        saveSettings()
    }
    
    func updateLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        saveSettings()
    }
    
    func updateShowTotalAmounts(_ show: Bool) {
        showTotalAmounts = show
        saveSettings()
    }
}