//
//  MatchModel.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

struct Match: Identifiable {
    let id: Int
    let teamA: String
    let teamB: String
    let startTime: Date

    var teamAOdds: Double
    var teamBOdds: Double
}
