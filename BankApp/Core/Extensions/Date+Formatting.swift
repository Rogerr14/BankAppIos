import Foundation

extension Date {
    var apiDate: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    var displayDate: String {
        formatted(.dateTime.day(.twoDigits).month(.twoDigits).year())
    }
}

