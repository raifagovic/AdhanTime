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
    var locationId: Int = 77 // Default locationId
    
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
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }
    
    func updateStatusBar(title: String) {
        if let button = statusItem.button {
            button.title = title
        }
    }
    
    func refresh() {
        ContentView().fetchPrayerTimes()
    }
    
    func fetchNextMonthFirstWeek(nextMonthComponents: DateComponents) {
        guard let nextYear = nextMonthComponents.year,
              let nextMonth = nextMonthComponents.month else {
            return
        }
        
        // Fetch prayer times for the first week of the next month
        PrayerTimeAPI.fetchPrayerTimes(for: locationId, year: nextYear, month: nextMonth, day: 1) { result in
            switch result {
            case .success(let times):
                let nextMonthDate = Calendar.current.date(from: nextMonthComponents)!
                PrayerTimeCache.savePrayerTimes(times, for: nextMonthDate)
            case .failure(let error):
                print("Failed to fetch prayer times for the first week of the next month: \(error)")
            }
        }
    }
}


