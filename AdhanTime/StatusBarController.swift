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

    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "Loading..."
        }
        
        startTimer()
    }
 
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateStatusBar(timer:)), userInfo: nil, repeats: true)
    }

    @objc private func updateStatusBar(timer: Timer) {
        if let (remainingTime, nextPrayerName) = fetchRemainingTime() {
            let timeString = formatTimeInterval(remainingTime, prayerName: nextPrayerName)
            statusItem.button?.title = timeString
        }
    }

    func fetchRemainingTime() -> (TimeInterval, String)? {
        let prayerTimes = ["03:30", "05:00", "12:00", "15:00", "18:00", "20:00"]
        let prayerNames = ["Zora", "Izlazak Sunca", "Podne", "Ikindija", "Akšam", "Jacija"]
        
        guard let nextPrayerTimeString = prayerTimes.first(where: {
            let components = $0.split(separator: ":")
            guard components.count == 2, let hour = Int(components[0]), let minute = Int(components[1]) else {
                return false
            }
            let calendar = Calendar.current
            let now = Date()
            let prayerTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)!
            return prayerTime > now
        }) else {
            return nil
        }
        
        guard let index = prayerTimes.firstIndex(of: nextPrayerTimeString) else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Sarajevo")
        
        let currentTimeString = dateFormatter.string(from: Date())
        let currentTimeComponents = currentTimeString.split(separator: ":").compactMap { Int($0) }
        let currentHour = currentTimeComponents[0]
        let currentMinute = currentTimeComponents[1]
        let currentSecond = Calendar.current.component(.second, from: Date())
        
        let currentTimeInSeconds = (currentHour * 3600) + (currentMinute * 60) + currentSecond
        
        let nextPrayerTimeComponents = nextPrayerTimeString.split(separator: ":").compactMap { Int($0) }
        let nextPrayerHour = nextPrayerTimeComponents[0]
        let nextPrayerMinute = nextPrayerTimeComponents[1]
        let nextPrayerTimeInSeconds = (nextPrayerHour * 3600) + (nextPrayerMinute * 60)
        
        var timeDifferenceInSeconds = nextPrayerTimeInSeconds - currentTimeInSeconds
        if timeDifferenceInSeconds < 0 {
            timeDifferenceInSeconds += 86400 // 24 hours in seconds
        }
        
        return (TimeInterval(timeDifferenceInSeconds), prayerNames[index])
    }

    func formatTimeInterval(_ interval: TimeInterval, prayerName: String) -> String {
        if interval <= 60 {
            return "\(prayerName) je za \(Int(interval)) sec"
        } else {
            let hours = Int(interval) / 3600
            let minutes = (Int(interval) % 3600 + 59) / 60
            if hours > 0 {
                return "\(prayerName) je za \(hours) h \(minutes) min"
            } else {
                return "\(prayerName) je za \(minutes) min"
            }
        }
    }
    
    func refresh() {
        timer?.invalidate()
        updateStatusBar(timer: Timer())
        startTimer()
    }
}
