//
//  OddsWebSocketSimulator.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

final class OddsWebSocketSimulator {

    var onReceive: ((OddsUpdate) -> Void)?

    private var task: Task<Void, Never>?

    func start(matchIDs: [Int]) {
        task = Task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 100_000_000) // ~1 updates/sec
                    
                    let id = matchIDs.randomElement()!
                    let update = OddsUpdate(
                        matchID: id,
                        teamAOdds: Double.random(in: 1.5...2.5),
                        teamBOdds: Double.random(in: 1.5...2.5)
                    )
                    
                    onReceive?(update)
                } catch {
                    
                }
            }
        }
    }

    func stop() {
        task?.cancel()
    }
}
