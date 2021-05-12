import Foundation

extension Date {
    var relativeTime_abbreviated: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var relativeTime_short: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var relativeTime_full: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var relativeTime_spellOut: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .spellOut
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
