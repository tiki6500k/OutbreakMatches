//
//  MatchAPIService.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

final class MatchAPIService {

    func fetchMatches() async -> [Match] {
        (0..<100).map { index in
            Match(
                id: 1000 + index,
                teamA: "Team A \(index)",
                teamB: "Team B \(index)",
                startTime: Date().addingTimeInterval(TimeInterval(index * 60)),
                teamAOdds: Double.random(in: 1.5...2.5),
                teamBOdds: Double.random(in: 1.5...2.5)
            )
        }
    }
}
