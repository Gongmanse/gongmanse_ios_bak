import Foundation

extension Date {
    
    func yearsFrom(date: Date) -> Int {
        return Calendar.current.component(.year, from: date)
    }
    
    func monthsFrom(date: Date) -> Int {
        return Calendar.current.component(.month, from: date)
    }
    
    func weeksFrom(date: Date) -> Int {
        return Calendar.current.component(.weekOfYear, from: date)
    }
    
    func daysFrom(date: Date) -> Int {
        return Calendar.current.component(.day, from: date)
    }
    
    func hoursFrom(date: Date) -> Int {
        return Calendar.current.component(.hour, from: date)
    }
    
    func minutesFrom(date: Date) -> Int {
        return Calendar.current.component(.minute, from: date)
    }
    
    func secondsFrom(date: Date) -> Int {
        return Calendar.current.component(.second, from: date)
    }
    
    func offsetFrom(date: Date) -> String {
        if yearsFrom(date: date) > 0 { return "\(yearsFrom(date: date))y"}
        if monthsFrom(date: date) > 0 { return "\(monthsFrom(date: date))M"}
        if weeksFrom(date: date) > 0 { return "\(weeksFrom(date: date))w"}
        if daysFrom(date: date) > 0 { return "\(daysFrom(date: date))d"}
        if hoursFrom(date: date) > 0 { return "\(hoursFrom(date: date))h"}
        if minutesFrom(date: date) > 0 { return "\(minutesFrom(date: date))m"}
        if secondsFrom(date: date) > 0 { return "\(secondsFrom(date: date))s"}
        
        return ""
    }
}
