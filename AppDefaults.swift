//
//  AppDefaults.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 06/10/24.
//
import UIKit

var APP_FONT = "appFont"

class AppDefaults : ObservableObject {
    private var userDefaults = UserDefaults.standard
    @Published var appFontString : String!
    static var shared = AppDefaults()
    private init() {
        appFontString = userDefaults.value(forKey: APP_FONT) as? String ?? "San Francisco"
    }
    
    func setAppFont(value: String) {
        appFontString = value
        userDefaults.setValue(value, forKey: APP_FONT)
    }
    
    func isDeletePromptEnabled() -> Bool {
        
        if let value = userDefaults.value(forKey: "isDeletePromptEnabled") as? Bool {
            return value
        }
        return false
    }
    func setDeletePromptEnabled(value: Bool) {
        userDefaults.setValue(value, forKey: "isDeletePromptEnabled")
    }
    
    func getAppVersion() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        return version
    }
}
