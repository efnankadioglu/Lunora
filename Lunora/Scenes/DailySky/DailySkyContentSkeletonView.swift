//
//  DailySkyContentSkeletonView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.08.2026.
//

import UIKit

final class DailySkyContentSkeletonView: UIView {

    // MARK: - UI

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        return stack
    }()

    private var skeletonViews: [LunoraSkeletonView] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupHierarchy()
        buildSkeletonContent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
        setupHierarchy()
        buildSkeletonContent()
    }

    // MARK: - Setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    private func setupHierarchy() {
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            stackView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            stackView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }

    // MARK: - Content

    private func buildSkeletonContent() {

        // 1. Ana gökyüzü kartı
        stackView.addArrangedSubview(
            makeHeroSkeletonCard()
        )

        // 2. Bugünün Enerjisi
        stackView.addArrangedSubview(
            makeContentSkeletonCard(
                height: 150,
                lineCount: 3
            )
        )

        // 3. Bugün bunları yapabilirsin
        stackView.addArrangedSubview(
            makeContentSkeletonCard(
                height: 190,
                lineCount: 4
            )
        )

        // 4. Bugün biraz dikkat
        stackView.addArrangedSubview(
            makeContentSkeletonCard(
                height: 145,
                lineCount: 3
            )
        )

        // 5. İlişkilerde Bugün
        stackView.addArrangedSubview(
            makeContentSkeletonCard(
                height: 155,
                lineCount: 3
            )
        )

        // 6. Güzellik & Bakım
        stackView.addArrangedSubview(
            makeContentSkeletonCard(
                height: 160,
                lineCount: 3
            )
        )

        // 7. Yaklaşan Gökyüzü
        stackView.addArrangedSubview(
            makeContentSkeletonCard(
                height: 185,
                lineCount: 4,
                darkBackground: true
            )
        )
    }

    // MARK: - Hero

    private func makeHeroSkeletonCard() -> UIView {

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(hex: "#E9D4FF")
        card.layer.cornerRadius = 28
        card.clipsToBounds = true

        let iconSkeleton = makeSkeleton(
            cornerRadius: 56
        )

        let titleSkeleton = makeSkeleton(
            cornerRadius: 10
        )

        let phaseSkeleton = makeSkeleton(
            cornerRadius: 8
        )

        let eventSkeleton = makeSkeleton(
            cornerRadius: 17
        )

        card.addSubview(iconSkeleton)
        card.addSubview(titleSkeleton)
        card.addSubview(phaseSkeleton)
        card.addSubview(eventSkeleton)

        NSLayoutConstraint.activate([

            card.heightAnchor.constraint(
                equalToConstant: 160
            ),

            iconSkeleton.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 20
            ),
            iconSkeleton.centerYAnchor.constraint(
                equalTo: card.centerYAnchor
            ),
            iconSkeleton.widthAnchor.constraint(
                equalToConstant: 112
            ),
            iconSkeleton.heightAnchor.constraint(
                equalToConstant: 112
            ),

            titleSkeleton.leadingAnchor.constraint(
                equalTo: iconSkeleton.trailingAnchor,
                constant: 14
            ),
            titleSkeleton.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 30
            ),
            titleSkeleton.widthAnchor.constraint(
                equalToConstant: 140
            ),
            titleSkeleton.heightAnchor.constraint(
                equalToConstant: 26
            ),

            phaseSkeleton.leadingAnchor.constraint(
                equalTo: titleSkeleton.leadingAnchor
            ),
            phaseSkeleton.topAnchor.constraint(
                equalTo: titleSkeleton.bottomAnchor,
                constant: 12
            ),
            phaseSkeleton.widthAnchor.constraint(
                equalToConstant: 110
            ),
            phaseSkeleton.heightAnchor.constraint(
                equalToConstant: 18
            ),

            eventSkeleton.leadingAnchor.constraint(
                equalTo: titleSkeleton.leadingAnchor
            ),
            eventSkeleton.topAnchor.constraint(
                equalTo: phaseSkeleton.bottomAnchor,
                constant: 17
            ),
            eventSkeleton.widthAnchor.constraint(
                equalToConstant: 145
            ),
            eventSkeleton.heightAnchor.constraint(
                equalToConstant: 34
            )
        ])

        return card
    }

    // MARK: - Generic Card

    private func makeContentSkeletonCard(
        height: CGFloat,
        lineCount: Int,
        darkBackground: Bool = false
    ) -> UIView {

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false

        if darkBackground {
            card.backgroundColor = UIColor(hex: "#4A416F")
        } else {
            card.backgroundColor =
                UIColor.white.withAlphaComponent(0.55)
        }

        card.layer.cornerRadius = 24
        card.clipsToBounds = true

        let titleSkeleton = makeSkeleton(
            cornerRadius: 10
        )

        card.addSubview(titleSkeleton)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(
                equalToConstant: height
            ),

            titleSkeleton.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 20
            ),
            titleSkeleton.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 20
            ),
            titleSkeleton.widthAnchor.constraint(
                equalTo: card.widthAnchor,
                multiplier: 0.48
            ),
            titleSkeleton.heightAnchor.constraint(
                equalToConstant: 22
            )
        ])

        var previousView: UIView = titleSkeleton

        for index in 0..<lineCount {

            let line = makeSkeleton(
                cornerRadius: 7
            )

            card.addSubview(line)

            let widthMultiplier: CGFloat

            if index == lineCount - 1 {
                widthMultiplier = 0.58
            } else if index % 2 == 0 {
                widthMultiplier = 0.86
            } else {
                widthMultiplier = 0.74
            }

            NSLayoutConstraint.activate([
                line.topAnchor.constraint(
                    equalTo: previousView.bottomAnchor,
                    constant: index == 0 ? 18 : 10
                ),
                line.leadingAnchor.constraint(
                    equalTo: card.leadingAnchor,
                    constant: 20
                ),
                line.widthAnchor.constraint(
                    equalTo: card.widthAnchor,
                    multiplier: widthMultiplier
                ),
                line.heightAnchor.constraint(
                    equalToConstant: 14
                )
            ])

            previousView = line
        }

        return card
    }

    // MARK: - Skeleton Helper

    private func makeSkeleton(
        cornerRadius: CGFloat
    ) -> LunoraSkeletonView {

        let skeleton = LunoraSkeletonView()

        skeleton.translatesAutoresizingMaskIntoConstraints = false
        skeleton.cornerRadius = cornerRadius

        skeletonViews.append(skeleton)

        return skeleton
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
