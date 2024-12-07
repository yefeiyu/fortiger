//
//  ScrollOffsetPreferenceKey.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.
//
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
struct TrackableScrollView<Content: View>: View {
    let axes: Axis.Set
    let showIndicators: Bool
    let content: Content
    let onScroll: (CGFloat) -> Void
    
    init(axes: Axis.Set = .vertical, showIndicators: Bool = true, onScroll: @escaping (CGFloat) -> Void, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content()
        self.onScroll = onScroll
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showIndicators) {
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)
            content
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: onScroll)
    }
}
