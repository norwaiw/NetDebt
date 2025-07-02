import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject private var localizationHelper = LocalizationHelper.shared
    
    private func localizedString(_ key: String) -> String {
        return localizationHelper.localizedString(key, language: userSettings.selectedLanguage)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Appearance Section
                Section {
                    // Theme Selection
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text(localizedString("theme"))
                            .font(.body)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(UserSettings.AppTheme.allCases, id: \.self) { theme in
                                Button(action: {
                                    userSettings.updateTheme(theme)
                                }) {
                                    HStack {
                                        Text(theme.localizedName(for: userSettings.selectedLanguage))
                                        if userSettings.selectedTheme == theme {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(userSettings.selectedTheme.localizedName(for: userSettings.selectedLanguage))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(localizedString("appearance"))
                }
                
                // General Section
                Section {
                    // Language Selection
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text(localizedString("language"))
                            .font(.body)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(UserSettings.AppLanguage.allCases, id: \.self) { language in
                                Button(action: {
                                    userSettings.updateLanguage(language)
                                }) {
                                    HStack {
                                        Text(language.localizedName)
                                        if userSettings.selectedLanguage == language {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(userSettings.selectedLanguage.localizedName)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(localizedString("general"))
                }
                
                // Theme Preview Section
                Section {
                    VStack(spacing: 16) {
                        // Theme preview card
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizedString("debt_tracker"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(localizedString("owed_to_me"))
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                
                                Text(localizedString("i_owe"))
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("$1,250.00")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Text("$500.00")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle(localizedString("settings"))
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings())
}