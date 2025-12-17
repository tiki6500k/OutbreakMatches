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

    // connectoin management
    private var connectionState: WebSocketConnectionState = .disconnected
    private var retryCount = 0
    private let maxRetry = 5

    var onInitialLoad: (() -> Void)?
    var onOddsUpdate: ((IndexPath) -> Void)?

    func load() {
        Task {
            let matches = await api.fetchMatches()
            await store.setInitial(matches: matches)
            cachedMatches = await store.sortedMatches()
            onInitialLoad?()

            setupSocket(matchIDs: matches.map { $0.id })
            connectSocket()
        }
    }

    // MARK: - WebSocket Setup

    private func setupSocket(matchIDs: [Int]) {
        socket.onReceive = { [weak self] update in
            self?.handleOdds(update)
        }

        socket.onDisconnect = { [weak self] in
            self?.handleDisconnect()
        }
    }

    private func connectSocket() {
        guard connectionState != .connecting else { return }

        connectionState = .connecting
        socket.connect(matchIDs: cachedMatches.map { $0.id })
        connectionState = .connected
        retryCount = 0
    }
    
    private func handleOdds(_ update: OddsUpdate) {
        Task {
            if let row = await store.updateOdds(update) {
                cachedMatches = await store.sortedMatches()
                onOddsUpdate?(IndexPath(row: row, section: 0))
            }
        }
    }

    private func handleDisconnect() {
        connectionState = .disconnected
        scheduleReconnect()
    }
    

    // MARK: - Retry Strategy

    private func scheduleReconnect() {
        guard retryCount < maxRetry else {
            print("❌ WebSocket reconnect failed")
            return
        }

        retryCount += 1
        let delay = pow(2.0, Double(retryCount)) // 隨著重試次數增加等待時間

        Task {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            connectSocket()
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
