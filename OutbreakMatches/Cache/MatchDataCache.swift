//
//  MatchDataCache.swift
//  OutbreakMatches
//
//  Created by Eddy Tsai on 2025/12/17.
//

import Foundation

final class MatchDataCache {

    static let shared = MatchDataCache()
    private init() {}

    // MARK: - Memory Cache

    private var memoryCache: [Match]?
    private var memorySavedAt: Date?

    // MARK: - Config

    private let ttl: TimeInterval = 60 * 5   // 5 minutes
    private let fileName = "match_cache.json"

    // MARK: - Public API

    func load() -> [Match]? {
        // 1️⃣ Memory 優先
        if let matches = memoryCache,
           let date = memorySavedAt,
           !isExpired(date) {
            return matches
        }

        // 2️⃣ Disk 次之
        if let payload = loadFromDisk(),
           !isExpired(payload.savedAt) {
            memoryCache = payload.matches
            memorySavedAt = payload.savedAt
            return payload.matches
        }

        return nil
    }

    func save(matches: [Match]) {
        let payload = CachedPayload(
            matches: matches,
            savedAt: Date()
        )

        // Memory
        memoryCache = matches
        memorySavedAt = payload.savedAt

        // Disk
        saveToDisk(payload)
    }

    func clear() {
        memoryCache = nil
        memorySavedAt = nil
        deleteDiskCache()
    }

    // MARK: - Expiration

    private func isExpired(_ date: Date) -> Bool {
        Date().timeIntervalSince(date) > ttl
    }
}

private extension MatchDataCache {

    var fileURL: URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(fileName)
    }

    func saveToDisk(_ payload: CachedPayload) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let data = try JSONEncoder().encode(payload)
                try data.write(to: self.fileURL, options: .atomic)
            } catch {
                print("❌ Cache save failed:", error)
            }
        }
    }

    func loadFromDisk() -> CachedPayload? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(CachedPayload.self, from: data)
        } catch {
            print("❌ Cache load failed:", error)
            return nil
        }
    }

    func deleteDiskCache() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
