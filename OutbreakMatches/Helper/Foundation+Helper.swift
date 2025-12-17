//
//  Double+Helper.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/17.
//

import Foundation

extension Double {
    func formattedNumber(fractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        
        return formatter.string(for: self) ?? ""
    }
}

extension Date {
    var iso8601: String {
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return iso8601Formatter.string(from: self)
    }
}
