//
//  MatchModel.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

struct Match: Identifiable, Codable {
    let id: Int
    let teamA: String
    let teamB: String
    let startTime: Date

    var teamAOdds: Double
    var teamBOdds: Double
}
