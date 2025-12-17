//
//  CachedPayload.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/17.
//

import Foundation

struct CachedPayload: Codable {
    let matches: [Match]
    let savedAt: Date
}

