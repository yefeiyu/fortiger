// ForumListView+ThreadListView.swift
import SwiftUI

extension ForumListView {
    /// 帖子列表视图
    @ViewBuilder
    var threadListView: some View {
        ScrollViewReader { ScrollViewProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(threads.indices, id: \.self) { index in
                        let thread = threads[index]
                        Button(action: {
                            if !isSwiping {
                                selectedThread = thread
                                // 打开帖子后标记为已读
                                readStatusManager.markAsRead(threadId: thread.id, replyCount: thread.replies)
                            }
                        })
                        {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(threadTitle(for: thread))
                                    .foregroundColor(getColor(for: thread))
                                    .font(.system(size: 20))
                                
                                HStack {
                                    Text("作者：\(thread.authorName)")
                                    Spacer()
                                    Text(thread.date)
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                
                                HStack {
                                    Text("回复：\(thread.replies)")
                                    Spacer()
                                    Text("查看：\(thread.views)")
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(PlainButtonStyle()) // 保持原有样式
                        .listRowInsets(EdgeInsets())
                        .id(index)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: VisibleItemPreferenceKey.self, value: [index: geometry.frame(in: .named("scroll")).minY])
                            }
                        )
                        .onAppear {
                            if index == threads.count - 1 {
                                loadNextPage()
                            }
                        }
                    }
                    if isLoading && !threads.isEmpty {
                        ProgressView("加载更多...")
                            .padding()
                    }
                }
                .coordinateSpace(name: "scroll")
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onChanged { _ in
                        // 开始滑动，设置 isSwiping 为 true
                        isSwiping = true
                    }
                    .onEnded { value in
                        handleSwipe(value, proxy: ScrollViewProxy)
                        // 滑动结束后，稍后将 isSwiping 重置为 false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isSwiping = false
                        }
                    }
            )
            .listStyle(PlainListStyle())
            .padding(.horizontal, 10)
            .refreshable {
                await refreshThreads()
            }
            .onPreferenceChange(VisibleItemPreferenceKey.self) { values in
                let visibleItems = values.filter { $0.value >= 0 }
                if let minItem = visibleItems.min(by: { $0.value < $1.value }) {
                    if scrollIndex != minItem.key {
                        scrollIndex = minItem.key
                    }
                }
            }
        }
    }
}
