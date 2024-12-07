// ReadStatusManager.swift
import Foundation
import Combine

class ReadStatusManager: ObservableObject {
    private let userDefaultsKey = "readThreads"
    
    // 线程ID: 最后回复数
    @Published var readThreads: [Int: Int]
    
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Int: Int].self, from: data) {
            readThreads = decoded
        } else {
            readThreads = [:]
        }
    }
    
    func markAsRead(threadId: Int, replyCount: Int) {
        readThreads[threadId] = replyCount
        save()
    }
    
    func hasRead(threadId: Int) -> Bool {
        return readThreads[threadId] != nil
    }
    
    func hasNewReplies(threadId: Int, currentReplyCount: Int) -> Bool {
        guard let lastReplyCount = readThreads[threadId] else { return false }
        return currentReplyCount > lastReplyCount
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(readThreads) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
