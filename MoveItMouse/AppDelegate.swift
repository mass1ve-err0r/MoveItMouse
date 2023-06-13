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
                timerActivity.interval = 2 * 60
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
        var mouseLocation = NSEvent.mouseLocation
        mouseLocation.y = NSHeight(NSScreen.screens[0].frame) - mouseLocation.y;
        
        var randomizer = SystemRandomNumberGenerator()
        let randX = Int.random(in: 1...1000, using: &randomizer)
        let randY = Int.random(in: 1...1000, using: &randomizer)
        let isPositive = Int.random(in: 0...2, using: &randomizer)
        
        let newLocation: CGPoint
        if isPositive == 0 {
            newLocation = CGPoint(
                x: mouseLocation.x + CGFloat(randX),
                y: mouseLocation.y + CGFloat(randY)
            )
        } else {
            newLocation = CGPoint(
                x: mouseLocation.x - CGFloat(randX),
                y: mouseLocation.y - CGFloat(randY)
            )
        }
        
        CGDisplayMoveCursorToPoint(0, newLocation)
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
