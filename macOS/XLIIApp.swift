//
//  XLIIApp.swift
//  Shared
//
//  Created by Miho on 2021/04/29.
//

import SwiftUI

@main
struct XLIIApp: App {
    
    init(){
        UserDefaults.shared.registerDefaults()
    }

    var body: some Scene {
        WindowGroup{
            ContentView()

        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowStyle(.titleBar)
        .commands(content: {
            AppCommands()
            InspectorCommands()
        })
        .defaultAppStorage(.shared)
        .windowResizability(.contentSize)
        
        Settings {
            VStack{
                SettingsView()
                    .defaultAppStorage(.shared)
            }.padding()
            
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowStyle(.titleBar)
        
        
    }
}
