//
//  SkyCardSkeletonView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.08.2026.
//

import UIKit

final class SkyCardSkeletonView: UIView {

    private let moonSkeleton = LunoraSkeletonView()
    private let phaseSkeleton = LunoraSkeletonView()
    private let eventSkeleton = LunoraSkeletonView()

    private var skeletonViews: [LunoraSkeletonView] {
        [
            moonSkeleton,
            phaseSkeleton,
            eventSkeleton
        ]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
        setupHierarchy()
        setupConstraints()
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        skeletonViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.theme = .onPurple
        }

        moonSkeleton.cornerRadius = 8
        phaseSkeleton.cornerRadius = 7
        eventSkeleton.cornerRadius = 15
    }

    private func setupHierarchy() {
        addSubview(moonSkeleton)
        addSubview(phaseSkeleton)
        addSubview(eventSkeleton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // Ay burcu
            moonSkeleton.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 4
            ),
            moonSkeleton.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            moonSkeleton.widthAnchor.constraint(
                equalTo: widthAnchor,
                multiplier: 0.52
            ),
            moonSkeleton.heightAnchor.constraint(
                equalToConstant: 24
            ),

            // Ay fazı
            phaseSkeleton.topAnchor.constraint(
                equalTo: moonSkeleton.bottomAnchor,
                constant: 12
            ),
            phaseSkeleton.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            phaseSkeleton.widthAnchor.constraint(
                equalTo: widthAnchor,
                multiplier: 0.44
            ),
            phaseSkeleton.heightAnchor.constraint(
                equalToConstant: 14
            ),

            // Astrolojik event badge
            eventSkeleton.topAnchor.constraint(
                equalTo: phaseSkeleton.bottomAnchor,
                constant: 17
            ),
            eventSkeleton.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            eventSkeleton.widthAnchor.constraint(
                equalTo: widthAnchor,
                multiplier: 0.55
            ),
            eventSkeleton.heightAnchor.constraint(
                equalToConstant: 30
            ),

            eventSkeleton.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor
            )
        ])
    }

    func startAnimating() {
        layoutIfNeeded()

        skeletonViews.forEach {
            $0.startAnimating()
        }
    }

    func stopAnimating() {
        skeletonViews.forEach {
            $0.stopAnimating()
        }
    }
}
