//
//  Date+.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Foundation

extension Date {
    func timeString() -> String {
        timeFormatter.string(from: self)
    }

    func timestampString() -> String {
        if Calendar.current.isDateInToday(self) {
            return timeString()
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return dateString()
        }
    }

    func chatTimestampString() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return dateString()
        }
    }
}

private extension Date {
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }

    func dateString() -> String {
        dayFormatter.string(from: self)
    }
}

extension Date {
    /// if today: 3:30 PM
    /// if yesterday returns Yesterday
    /// 02/15/24
    var dayOrTimeRepresentation: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
            let formattedDate = dateFormatter.string(from: self)
            return formattedDate

        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: self)
        }
    }

    /// 3:30 PM
    var formatToTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let formattedTime = dateFormatter.string(from: self)
        return formattedTime
    }

    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
