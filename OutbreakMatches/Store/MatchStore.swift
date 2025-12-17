//
//  MatchStore.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

actor MatchStore {

    private var matches: [Int: Match] = [:]

    func setInitial(matches: [Match]) {
        self.matches = Dictionary(uniqueKeysWithValues: matches.map { ($0.id, $0) })
    }

    func updateOdds(_ update: OddsUpdate) -> Int? {
        guard var match = matches[update.matchID] else { return nil }

        match.teamAOdds = update.teamAOdds
        match.teamBOdds = update.teamBOdds
        matches[update.matchID] = match

        return sortedMatches().firstIndex { $0.id == match.id }
    }

    func sortedMatches() -> [Match] {
        matches.values.sorted { $0.startTime < $1.startTime }
    }

    func match(at index: Int) -> Match? {
        let list = sortedMatches()
        guard index < list.count else { return nil }
        return list[index]
    }

    var count: Int {
        matches.count
    }
}
