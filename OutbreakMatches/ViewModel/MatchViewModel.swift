//
//  MatchViewModel.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/16.
//

import Foundation

@MainActor
final class MatchViewModel {

    // MARK: - Dependencies

    private let store = MatchStore()                  // actor (thread-safe)
    private let api = MatchAPIService()               // mock REST
    private let socket = OddsWebSocketSimulator()     // mock WebSocket
    private let cache = MatchDataCache.shared         // in-memory cache

    // MARK: - View State (UIKit 同步只讀)

    private(set) var cachedMatches: [Match] = []

    // MARK: - WebSocket State

    private enum ConnectionState {
        case disconnected
        case connecting
        case connected
    }

    private var connectionState: ConnectionState = .disconnected
    private var retryCount = 0
    private let maxRetry = 5

    // MARK: - View Callbacks

    var onInitialLoad: (() -> Void)?
    var onOddsUpdate: ((IndexPath) -> Void)?

    // MARK: - Public API (View → ViewModel)

    func load() {

        // ✅ 1. 優先使用快取
        if let cached = cache.load() {
            Task {
                await store.setInitial(matches: cached)
            }
            
            cachedMatches = cached
            onInitialLoad?()
            connectSocketIfNeeded()
            return
        }

        // ❌ 無快取才打 API
        Task {
            let matches = await api.fetchMatches()
            await store.setInitial(matches: matches)

            let sorted = await store.sortedMatches()
            cachedMatches = sorted

            // 🔑 寫入快取
            cache.save(matches: sorted)

            onInitialLoad?()
            connectSocketIfNeeded()
        }
    }

    // MARK: - UIKit 同步介面（⚠️ 不可 async）

    func numberOfRows() -> Int {
        cachedMatches.count
    }

    func match(at index: Int) -> Match {
        cachedMatches[index]
    }

    // MARK: - Odds Handling

    private func handleOdds(_ update: OddsUpdate) {
        Task {
            // actor 裡 thread-safe 更新
            if let row = await store.updateOdds(update) {
                let sorted = await store.sortedMatches()

                // 🔑 同步 View State + Cache
                cachedMatches = sorted
                cache.save(matches: sorted)

                onOddsUpdate?(IndexPath(row: row, section: 0))
            }
        }
    }

    // MARK: - WebSocket Setup

    private func connectSocketIfNeeded() {
        guard connectionState != .connecting,
              !socket.isConnected else { return }

        connectionState = .connecting

        socket.onReceive = { [weak self] update in
            self?.handleOdds(update)
        }

        socket.onDisconnect = { [weak self] in
            self?.handleDisconnect()
        }

        socket.connect(matchIDs: cachedMatches.map { $0.id })

        connectionState = .connected
        retryCount = 0
    }

    private func handleDisconnect() {
        connectionState = .disconnected
        scheduleReconnect()
    }

    // MARK: - Retry Strategy (Exponential Backoff)

    private func scheduleReconnect() {
        guard retryCount < maxRetry else {
            print("❌ WebSocket reconnect failed")
            return
        }

        retryCount += 1
        let delay = pow(2.0, Double(retryCount)) // 等待時間隨著重試次數增加

        Task {
            try await Task.sleep(
                nanoseconds: UInt64(delay * 1_000_000_000)
            )
            connectSocketIfNeeded()
        }
    }
}
