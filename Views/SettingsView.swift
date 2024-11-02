//
//  SettingsView.swift
//  Journella
//
//  Created by Arkaprava Ghosh on 05/10/24.
//
import SwiftUI

struct SettingsView : View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appDefaults : AppDefaults
    var settingsOptions = ["Choose Font"]
    
    
    var body: some View {
        NavigationView {
            
            
                List {
                    
                    VStack(alignment: .leading) {
                        Text("App Version")
                            .font(.custom(appDefaults.appFontString, size: 21))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                        Text(appDefaults.getAppVersion())
                            .font(.custom(appDefaults.appFontString, size: 18))
                            .foregroundStyle(.primary)
                        
                    }
                    NavigationLink(destination: FontPickerView()) {
                        VStack(alignment: .leading) {
                            Text("Font Picker")
                                .font(.custom(appDefaults.appFontString, size: 21))
                            Text("Choose from handpicked fonts for your app")
                                .font(.custom(appDefaults.appFontString, size: 18))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Link(destination: URL(string: "https://github.com/ribhu69/Journella")!) {
                        Text("@Journella")
                            .font(.custom(appDefaults.appFontString, size: 21))
                            .padding(.vertical, 8)
                    }
                }
            
            
                
            
            
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .tint(colorScheme == .dark ? .white : .black)
                    })
                }
            }
        }
    }
    
  
}

#Preview {
    SettingsView().environmentObject(AppDefaults.shared)
}
