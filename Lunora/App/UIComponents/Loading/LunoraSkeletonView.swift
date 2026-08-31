//
//  LunoraSkeletonView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.08.2026.
//


import UIKit

final class LunoraSkeletonView: UIView {

    // MARK: - Theme

    enum Theme {
        case `default`
        case onPurple
        case onDark
    }

    var theme: Theme = .default {
        didSet {
            applyTheme()
        }
    }

    // MARK: - Shimmer

    private let shimmerLayer = CAGradientLayer()

    // MARK: - Public Properties

    var cornerRadius: CGFloat = 12 {
        didSet {
            layer.cornerRadius = cornerRadius
            shimmerLayer.cornerRadius = cornerRadius
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        clipsToBounds = true

        layer.cornerRadius = cornerRadius
        shimmerLayer.cornerRadius = cornerRadius

        shimmerLayer.locations = [0.0, 0.5, 1.0]
        shimmerLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        layer.addSublayer(shimmerLayer)

        applyTheme()
    }

    private func applyTheme() {

        let baseColor: UIColor
        let highlightColor: UIColor

        switch theme {

        case .default:
            baseColor = UIColor(
                red: 0.95,
                green: 0.89,
                blue: 0.93,
                alpha: 1.0
            )

            highlightColor = UIColor(
                red: 1.0,
                green: 0.97,
                blue: 0.99,
                alpha: 1.0
            )

        case .onPurple:
            baseColor = UIColor.white.withAlphaComponent(0.16)
            highlightColor = UIColor.white.withAlphaComponent(0.32)

        case .onDark:
            baseColor = UIColor.white.withAlphaComponent(0.10)
            highlightColor = UIColor.white.withAlphaComponent(0.22)
        }

        backgroundColor = baseColor

        shimmerLayer.colors = [
            baseColor.cgColor,
            highlightColor.cgColor,
            baseColor.cgColor
        ]
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        shimmerLayer.frame = CGRect(
            x: -bounds.width,
            y: 0,
            width: bounds.width * 3,
            height: bounds.height
        )
    }

    // MARK: - Animation

    func startAnimating() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            shimmerLayer.removeAllAnimations()
            return
        }

        guard shimmerLayer.animation(
            forKey: "lunoraShimmer"
        ) == nil else {
            return
        }

        let animation = CABasicAnimation(
            keyPath: "transform.translation.x"
        )

        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.4
        animation.repeatCount = .infinity

        animation.timingFunction =
            CAMediaTimingFunction(
                name: .easeInEaseOut
            )

        shimmerLayer.add(
            animation,
            forKey: "lunoraShimmer"
        )
    }

    func stopAnimating() {
        shimmerLayer.removeAnimation(
            forKey: "lunoraShimmer"
        )
    }
}
