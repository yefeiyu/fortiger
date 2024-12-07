//
//  SwipeGestureHandler.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.
//
import UIKit

// ScrollDirection enum
enum ScrollDirection {
    case up, down
}

class SwipeGestureHandler: NSObject {
    private weak var view: UIView?
    var scrollAction: ((ScrollDirection) -> Void)?

    init(view: UIView) {
        self.view = view
        super.init()
        setupSwipeGestures()
    }

    // Set up left and right swipe gestures
    private func setupSwipeGestures() {
        guard let view = view else { return }

        // Left swipe gesture
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)

        // Right swipe gesture
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }

    // Handle swipe gestures
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // Left swipe
            scrollAction?(.down)
        } else if gesture.direction == .right {
            // Right swipe
            scrollAction?(.up)
        }
    }
}
