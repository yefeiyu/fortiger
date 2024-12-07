// ForumListView+Network.swift
import Foundation

extension ForumListView {
    /// 刷新帖子列表
    @MainActor
    func refreshThreads() async {
        guard !isLoading else { return }
        currentPage = 1
        await loadThreads(append: false)
    }
    
    /// 加载帖子数据
    func loadThreads(append: Bool = false) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let fetchedThreads = try await threadLoader.loadThreads(fid: fid, page: currentPage)
            
            // 这里可以处理线程数据，例如检查新回复
            let updatedThreads = fetchedThreads.map { thread -> Thread in
                // 你可以在这里对线程进行额外处理
                return thread
            }
            
            if append {
                self.threads.append(contentsOf: updatedThreads)
            } else {
                self.threads = updatedThreads
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
    
    /// 加载下一页数据
    func loadNextPage() {
        guard !isLoading else { return }
        currentPage += 1
        Task {
            await loadThreads(append: true)
        }
    }
}
