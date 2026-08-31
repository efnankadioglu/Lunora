//
//  ProgramCardSkeletonView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.08.2026.
//

import UIKit

final class ProgramCardSkeletonView: UIView {

    // MARK: - Card

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.58)
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor =
            UIColor.white.withAlphaComponent(0.55).cgColor
        view.layer.masksToBounds = true
        return view
    }()

    // MARK: - Skeleton Pieces

    private let imageSkeleton = LunoraSkeletonView()
    private let difficultySkeleton = LunoraSkeletonView()

    private let titleSkeleton = LunoraSkeletonView()

    private let summaryLine1 = LunoraSkeletonView()
    private let summaryLine2 = LunoraSkeletonView()
    private let summaryLine3 = LunoraSkeletonView()

    private let durationSkeleton = LunoraSkeletonView()
    private let startButtonSkeleton = LunoraSkeletonView()

    private var skeletonViews: [LunoraSkeletonView] {
        [
            imageSkeleton,
            difficultySkeleton,
            titleSkeleton,
            summaryLine1,
            summaryLine2,
            summaryLine3,
            durationSkeleton,
            startButtonSkeleton
        ]
    }

    // MARK: - Init

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

    // MARK: - Setup

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        skeletonViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        imageSkeleton.cornerRadius = 28
        difficultySkeleton.cornerRadius = 19

        titleSkeleton.cornerRadius = 9

        summaryLine1.cornerRadius = 7
        summaryLine2.cornerRadius = 7
        summaryLine3.cornerRadius = 7

        durationSkeleton.cornerRadius = 18
        startButtonSkeleton.cornerRadius = 22
    }

    private func setupHierarchy() {
        addSubview(cardView)

        cardView.addSubview(imageSkeleton)
        cardView.addSubview(difficultySkeleton)

        cardView.addSubview(titleSkeleton)

        cardView.addSubview(summaryLine1)
        cardView.addSubview(summaryLine2)
        cardView.addSubview(summaryLine3)

        cardView.addSubview(durationSkeleton)
        cardView.addSubview(startButtonSkeleton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // Card
            cardView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 4
            ),
            cardView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            cardView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            cardView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -4
            ),

            // Image
            imageSkeleton.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 12
            ),
            imageSkeleton.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 18
            ),
            imageSkeleton.widthAnchor.constraint(
                equalToConstant: 56
            ),
            imageSkeleton.heightAnchor.constraint(
                equalToConstant: 56
            ),

            // Difficulty
            difficultySkeleton.centerYAnchor.constraint(
                equalTo: imageSkeleton.centerYAnchor
            ),
            difficultySkeleton.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -18
            ),
            difficultySkeleton.widthAnchor.constraint(
                equalToConstant: 128
            ),
            difficultySkeleton.heightAnchor.constraint(
                equalToConstant: 38
            ),

            // Title
            titleSkeleton.topAnchor.constraint(
                equalTo: imageSkeleton.bottomAnchor,
                constant: 14
            ),
            titleSkeleton.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 18
            ),
            titleSkeleton.widthAnchor.constraint(
                equalTo: cardView.widthAnchor,
                multiplier: 0.67
            ),
            titleSkeleton.heightAnchor.constraint(
                equalToConstant: 22
            ),

            // Summary 1
            summaryLine1.topAnchor.constraint(
                equalTo: titleSkeleton.bottomAnchor,
                constant: 14
            ),
            summaryLine1.leadingAnchor.constraint(
                equalTo: titleSkeleton.leadingAnchor
            ),
            summaryLine1.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -18
            ),
            summaryLine1.heightAnchor.constraint(
                equalToConstant: 14
            ),

            // Summary 2
            summaryLine2.topAnchor.constraint(
                equalTo: summaryLine1.bottomAnchor,
                constant: 8
            ),
            summaryLine2.leadingAnchor.constraint(
                equalTo: titleSkeleton.leadingAnchor
            ),
            summaryLine2.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -44
            ),
            summaryLine2.heightAnchor.constraint(
                equalToConstant: 14
            ),

            // Summary 3
            summaryLine3.topAnchor.constraint(
                equalTo: summaryLine2.bottomAnchor,
                constant: 8
            ),
            summaryLine3.leadingAnchor.constraint(
                equalTo: titleSkeleton.leadingAnchor
            ),
            summaryLine3.widthAnchor.constraint(
                equalTo: cardView.widthAnchor,
                multiplier: 0.52
            ),
            summaryLine3.heightAnchor.constraint(
                equalToConstant: 14
            ),

            // Duration
            durationSkeleton.topAnchor.constraint(
                equalTo: summaryLine3.bottomAnchor,
                constant: 18
            ),
            durationSkeleton.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 18
            ),
            durationSkeleton.widthAnchor.constraint(
                equalToConstant: 98
            ),
            durationSkeleton.heightAnchor.constraint(
                equalToConstant: 36
            ),
            durationSkeleton.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -12
            ),

            // Start button
            startButtonSkeleton.centerYAnchor.constraint(
                equalTo: durationSkeleton.centerYAnchor
            ),
            startButtonSkeleton.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -18
            ),
            startButtonSkeleton.widthAnchor.constraint(
                equalToConstant: 136
            ),
            startButtonSkeleton.heightAnchor.constraint(
                equalToConstant: 44
            )
        ])
    }

    // MARK: - Animation

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
