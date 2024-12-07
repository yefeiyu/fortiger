//
//  SwipeGestureView.swift
//  FourFour
//
//  Created by Charles Thomas on 12/1/24.
//
import SwiftUI

struct SwipeGestureView: UIViewRepresentable {
    var onSwipe: (ScrollDirection) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = PassThroughView()
        context.coordinator.setupGestureHandler(on: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSwipe: onSwipe)
    }

    class Coordinator: NSObject {
        var onSwipe: (ScrollDirection) -> Void
        var swipeHandler: SwipeGestureHandler?

        init(onSwipe: @escaping (ScrollDirection) -> Void) {
            self.onSwipe = onSwipe
        }

        func setupGestureHandler(on view: UIView) {
            let swipeHandler = SwipeGestureHandler(view: view)
            swipeHandler.scrollAction = { direction in
                self.onSwipe(direction)
            }
            self.swipeHandler = swipeHandler
        }
    }
}

// Custom UIView that only intercepts swipe gestures
class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false // Allow touches to pass through
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if any gesture recognizers recognize the touch
        if let gestures = gestureRecognizers, !gestures.isEmpty {
            for gesture in gestures {
                if gesture is UISwipeGestureRecognizer {
                    return self
                }
            }
        }
        // Otherwise, pass the touch to underlying views
        return nil
    }
}
