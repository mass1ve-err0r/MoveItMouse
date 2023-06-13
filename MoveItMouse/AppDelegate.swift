//
//  AppDelegate.swift
//  MoveItMouse
//
//  Created by Saadat Baig on 13.06.23.
//
import AppKit
import IOKit.pwr_mgt


var noSleepAssertionID: IOPMAssertionID = 0
var noSleepReturn: IOReturn?

class AppDelegate: NSObject, NSApplicationDelegate, NSUserInterfaceValidations {
    
    var statusBarItem: NSStatusItem!
    var statusBarMenu: NSMenu!
    
    var timerStarted: Bool = false
    var timerActivity: NSBackgroundActivityScheduler!
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBar = NSStatusBar.system

        self.statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        self.statusBarItem.button?.image = NSImage(systemSymbolName: "cursorarrow.motionlines", accessibilityDescription: "Status Bar Icon")
        
        setupStatusBarMenu()
    }
    
    
    //MARK: - NSUserInterfaceValidations
    
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(startMovementTimer) {
            if timerStarted {
                return false
            }
        }
        
        if item.action == #selector(endMovementTimer) {
            if !timerStarted {
                return false
            }
        }
        
        return true
    }
    
    
    //MARK: - Functions
    
    @objc
    func startMovementTimer() {
        if disableScreenSleep() ?? false {
            timerStarted.toggle()
            
            if timerActivity == nil {
                timerActivity = NSBackgroundActivityScheduler(identifier: "dev.saadat.moveitmouse")
                timerActivity.repeats = true
                timerActivity.interval = 5 * 60
            }
            
            timerActivity.schedule() { completion in
                self.moveMouse()

                completion(NSBackgroundActivityScheduler.Result.finished)
            }
        }
    }
    
    @objc
    func endMovementTimer() {
        if enableScreenSleep() {
            timerStarted.toggle()
            
            timerActivity.invalidate()
        }
    }
    
    func moveMouse() {
        var mouseLoc = NSEvent.mouseLocation
        mouseLoc.y = NSHeight(NSScreen.screens[0].frame) - mouseLoc.y;
        
        let newLoc = CGPoint(x: mouseLoc.x-(mouseLoc.x-10), y: mouseLoc.y+(mouseLoc.y-10))
        
        CGDisplayMoveCursorToPoint(0, newLoc)
    }
    
    func disableScreenSleep(reason: String = "MoveItMouse Mover Activity") -> Bool? {
        guard noSleepReturn == nil else { return nil }
        
        noSleepReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                    IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                    reason as CFString,
                                                    &noSleepAssertionID
        )
        
        return noSleepReturn == kIOReturnSuccess
    }

    func  enableScreenSleep() -> Bool {
        if noSleepReturn != nil {
            _ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
            noSleepReturn = nil
            
            return true
        }
        
        return false
    }
    
    private func setupStatusBarMenu() {
        self.statusBarMenu = NSMenu()
        
        self.statusBarMenu.addItem(withTitle: "Start Mover", action: #selector(startMovementTimer), keyEquivalent: "")
        self.statusBarMenu.addItem(withTitle: "End Mover", action: #selector(endMovementTimer), keyEquivalent: "")
        self.statusBarMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        self.statusBarItem.menu = self.statusBarMenu
    }
    
}
