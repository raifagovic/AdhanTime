//
//  StatusBarController.swift
//  AdhanTime
//
//  Created by Raif Agovic on 30. 5. 2024..
//

import Cocoa

class StatusBarController {
    static let shared = StatusBarController()
    private var statusItem: NSStatusItem
    private var timer: Timer?
    private var mainWindow: NSWindow?
    
    var remainingTime: TimeInterval?
    var nextPrayerName: String?
    
    private let prayerTimeCache = PrayerTimeCache()

    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "Loading..."
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        
        startTimer()
    }
    
    func setMainWindow(_ window: NSWindow) {
        self.mainWindow = window
    }
    
    @objc func statusBarButtonClicked() {
        if let window = mainWindow {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateStatusBar(timer:)), userInfo: nil, repeats: true)
    }

    @objc func updateStatusBar(timer: Timer) {
        if let cachedPrayerTimes = PrayerTimeCache.loadCachedPrayerTimes(), !cachedPrayerTimes.isEmpty {
            // Use cached prayer times
            if let (remainingTime, nextPrayerName) = PrayerTimeCalculator.calculateRemainingTime(prayerTimes: cachedPrayerTimes) {
                let timeString = TimeUtils.formatTimeInterval(remainingTime, prayerName: nextPrayerName)
                statusItem.button?.title = timeString
                self.remainingTime = remainingTime
                self.nextPrayerName = nextPrayerName
            }
        } else {
            // Fallback if no cached data is available (should rarely happen)
            statusItem.button?.title = "No cached data"
        }
    }

    func updateStatusBar(title: String) {
        statusItem.button?.title = title
    }

    func refresh() {
        // Recalculate remaining time and next prayer name
        if let (newRemainingTime, newNextPrayerName) = PrayerTimeCalculator.calculateRemainingTime() {
            self.remainingTime = newRemainingTime
            self.nextPrayerName = newNextPrayerName
            let timeString = TimeUtils.formatTimeInterval(newRemainingTime, prayerName: newNextPrayerName)
            updateStatusBar(title: timeString)
        }
        // Restart the timer
        startTimer()
    }
}

