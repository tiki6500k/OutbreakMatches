//
//  OddsWebSocketSimulator.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

enum WebSocketConnectionState {
    case disconnected
    case connecting
    case connected
}

final class OddsWebSocketSimulator {

    var onReceive: ((OddsUpdate) -> Void)?
    var onDisconnect: (() -> Void)?

    private var task: Task<Void, Never>?
    private(set) var isConnected = false

    func connect(matchIDs: [Int]) {
        guard task == nil else { return } // prevent double reconnection
        
        isConnected = true

        task = Task {
            do {
                while !Task.isCancelled {
                    try await Task.sleep(nanoseconds: 100_000_000)

                    // 💥 pretend service down randomly
                    if Int.random(in: 0...30) == 0 {
                        throw CancellationError()
                    }

                    let id = matchIDs.randomElement()!
                    onReceive?(OddsUpdate(
                        matchID: id,
                        teamAOdds: Double.random(in: 1.5...2.5),
                        teamBOdds: Double.random(in: 1.5...2.5)
                    ))
                }
            } catch {
                disconnect()
            }
        }
    }

    func disconnect() {
        guard isConnected else { return }
        isConnected = false
        task?.cancel()
        task = nil
        onDisconnect?()
    }
}
