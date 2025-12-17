//
//  MatchViewModel.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

@MainActor
final class MatchViewModel {

    private let store = MatchStore()
    private let api = MatchAPIService()
    private let socket = OddsWebSocketSimulator()

    private(set) var cachedMatches: [Match] = []

    var onInitialLoad: (() -> Void)?
    var onOddsUpdate: ((IndexPath) -> Void)?

    func load() {
        Task {
            let matches = await api.fetchMatches()
            await store.setInitial(matches: matches)

            cachedMatches = await store.sortedMatches()
            onInitialLoad?()

            socket.onReceive = { [weak self] update in
                self?.handleOdds(update)
            }

            socket.start(matchIDs: matches.map { $0.id })
        }
    }

    private func handleOdds(_ update: OddsUpdate) {
        Task {
            if let row = await store.updateOdds(update) {
                cachedMatches = await store.sortedMatches()
                onOddsUpdate?(IndexPath(row: row, section: 0))
            }
        }
    }

    // MARK: - UIKit 同步介面

    func numberOfRows() -> Int {
        cachedMatches.count
    }

    func match(at index: Int) -> Match {
        cachedMatches[index]
    }
}
