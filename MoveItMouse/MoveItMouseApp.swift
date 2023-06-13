//
//  MoveItMouseApp.swift
//  MoveItMouse
//
//  Created by Saadat Baig on 13.06.23.
//
import SwiftUI


@main
struct MoveItMouseApp: App {
  
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
    
}
