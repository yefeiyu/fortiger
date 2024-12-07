// ForumListView+SwipeActions.swift
import SwiftUI

extension ForumListView {
    /// 处理滑动手势
    func handleSwipe(_ value: DragGesture.Value, proxy: ScrollViewProxy) {
        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height
        if abs(horizontalAmount) > abs(verticalAmount) && abs(horizontalAmount) > 75 {
            if horizontalAmount < 0 {
                // 向左滑动
                scrollPage(direction: .down, proxy: proxy)
            } else {
                // 向右滑动
                scrollPage(direction: .up, proxy: proxy)
            }
        }
    }
    
    /// 滑动页面
    private func scrollPage(direction: ScrollDirection, proxy: ScrollViewProxy) {
        let itemsPerPage = estimateItemsPerPage()
        if direction == .up {
            // 向右滑动：回到上一页
            if scrollIndex == 0 && currentPage > 1 {
                currentPage -= 1
                scrollIndex = (currentPage - 1) * itemsPerPage
                Task {
                    await refreshThreads()
                }
            } else {
                scrollIndex = max(scrollIndex - itemsPerPage, 0)
            }
        } else if direction == .down {
            // 向左滑动：加载下一页
            if scrollIndex >= threads.count - itemsPerPage {
                // 超过当前页的最后一个元素时加载下一页
                currentPage += 1
                scrollIndex = (currentPage - 1) * itemsPerPage
                Task {
                    await loadThreads(append: true)
                }
            } else {
                scrollIndex = min(scrollIndex + itemsPerPage, threads.count - 1)
            }
        }
        proxy.scrollTo(scrollIndex, anchor: .top)
    }
    
    /// 滑动方向枚举
    enum ScrollDirection {
        case up, down
    }
    
    /// 估算每页显示的项目数量
    private func estimateItemsPerPage() -> Int {
        // 你可以根据屏幕上通常可见的项目数量调整此值
        return 8
    }
}
