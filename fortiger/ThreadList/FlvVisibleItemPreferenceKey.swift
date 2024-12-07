//
//  VisibleItemPreferenceKey.swift
//  FourTiger
//
//  Created by Charles Thomas on 12/7/24.
//
// VisibleItemPreferenceKey.swift
import SwiftUI

struct VisibleItemPreferenceKey: PreferenceKey {
    typealias Value = [Int: CGFloat] // 帖子索引和其垂直位置的字典
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int : CGFloat], nextValue: () -> [Int : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
