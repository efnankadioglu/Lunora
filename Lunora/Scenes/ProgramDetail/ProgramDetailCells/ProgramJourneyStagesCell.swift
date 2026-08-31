//
//  ProgramJourneyStagesCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.08.2026.
//

import UIKit

final class ProgramJourneyStagesCell: UITableViewCell {

    private let cardView = UIView()

    private let titleRow = UIStackView()
    private let titleIcon = UIImageView()
    private let titleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let stagesStack = UIStackView()

    private let mainStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        stagesStack.arrangedSubviews.forEach { view in
            stagesStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func configure(
        title: String,
        stages: [ProgramJourneyStage]
    ) {

        titleLabel.text = title

        stagesStack.arrangedSubviews.forEach { view in
            stagesStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let sortedStages = stages.sorted {
            $0.order < $1.order
        }

        for stage in sortedStages {
            stagesStack.addArrangedSubview(
                makeStageCard(stage: stage)
            )
        }
    }

    private func setupUI() {

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCard()
        setupHeader()
        setupScroll()
        setupStacks()

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)

        mainStack.addArrangedSubview(titleRow)
        mainStack.addArrangedSubview(scrollView)

        NSLayoutConstraint.activate([

            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8
            ),

            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),

            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            cardView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            ),

            mainStack.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 20
            ),

            mainStack.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 20
            ),

            mainStack.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -20
            ),

            mainStack.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -20
            )
        ])
    }

    private func setupCard() {

        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.backgroundColor =
            UIColor.white.withAlphaComponent(0.55)

        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true

        cardView.layer.borderWidth = 1
        cardView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.30).cgColor
    }

    private func setupHeader() {

        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 10

        titleIcon.image = UIImage(
            systemName: "sparkles"
        )

        titleIcon.tintColor =
            UIColor.systemPink.withAlphaComponent(0.80)

        titleIcon.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            titleIcon.widthAnchor.constraint(
                equalToConstant: 22
            ),

            titleIcon.heightAnchor.constraint(
                equalToConstant: 22
            )
        ])

        titleLabel.font = .systemFont(
            ofSize: 19,
            weight: .semibold
        )

        titleLabel.numberOfLines = 0

        titleLabel.textColor =
            UIColor.label.withAlphaComponent(0.95)

        titleRow.addArrangedSubview(titleIcon)
        titleRow.addArrangedSubview(titleLabel)
    }

    private func setupScroll() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true

        stagesStack.translatesAutoresizingMaskIntoConstraints = false

        stagesStack.axis = .horizontal
        stagesStack.alignment = .fill
        stagesStack.distribution = .fill
        stagesStack.spacing = 12

        scrollView.addSubview(stagesStack)

        NSLayoutConstraint.activate([

            scrollView.heightAnchor.constraint(
                equalToConstant: 230
            ),

            stagesStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),

            stagesStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),

            stagesStack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),

            stagesStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),

            stagesStack.heightAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.heightAnchor
            )
        ])
    }

    private func setupStacks() {

        mainStack.translatesAutoresizingMaskIntoConstraints = false

        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        mainStack.spacing = 18
    }

    private func makeStageCard(
        stage: ProgramJourneyStage
    ) -> UIView {

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        container.backgroundColor =
            UIColor.white.withAlphaComponent(0.48)

        container.layer.cornerRadius = 20
        container.layer.masksToBounds = true

        container.layer.borderWidth = 1
        container.layer.borderColor =
            UIColor.systemPink
                .withAlphaComponent(0.16)
                .cgColor

        container.widthAnchor.constraint(
            equalToConstant: 220
        ).isActive = true

        let numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        numberLabel.text = "\(stage.order)"
        numberLabel.textAlignment = .center

        numberLabel.font = .systemFont(
            ofSize: 14,
            weight: .bold
        )

        numberLabel.textColor = .white

        numberLabel.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.82)

        numberLabel.layer.cornerRadius = 15
        numberLabel.layer.masksToBounds = true

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.08)

        iconContainer.layer.cornerRadius = 25
        iconContainer.layer.masksToBounds = true

        let iconView = UIImageView(
            image: UIImage(
                systemName: stage.iconName
            )
        )

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor =
            UIColor.systemPink.withAlphaComponent(0.78)

        iconView.contentMode = .scaleAspectFit

        iconContainer.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )

        titleLabel.textColor =
            UIColor.label.withAlphaComponent(0.92)

        titleLabel.numberOfLines = 2
        titleLabel.text = stage.title

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.font = .systemFont(
            ofSize: 14,
            weight: .regular
        )

        descriptionLabel.textColor =
            UIColor.label.withAlphaComponent(0.62)

        descriptionLabel.numberOfLines = 3
        descriptionLabel.text = stage.shortDescription

        let dayLabel = UILabel()
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        dayLabel.font = .systemFont(
            ofSize: 13,
            weight: .semibold
        )

        dayLabel.textColor =
            UIColor.systemPink.withAlphaComponent(0.88)

        dayLabel.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.08)

        dayLabel.textAlignment = .center
        dayLabel.layer.cornerRadius = 13
        dayLabel.layer.masksToBounds = true

        dayLabel.text =
            makeDayText(stage.dayNumbers)

        container.addSubview(numberLabel)
        container.addSubview(iconContainer)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        container.addSubview(dayLabel)

        NSLayoutConstraint.activate([

            numberLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 14
            ),

            numberLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 14
            ),

            numberLabel.widthAnchor.constraint(
                equalToConstant: 30
            ),

            numberLabel.heightAnchor.constraint(
                equalToConstant: 30
            ),

            iconContainer.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 16
            ),

            iconContainer.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -16
            ),

            iconContainer.widthAnchor.constraint(
                equalToConstant: 50
            ),

            iconContainer.heightAnchor.constraint(
                equalToConstant: 50
            ),

            iconView.centerXAnchor.constraint(
                equalTo: iconContainer.centerXAnchor
            ),

            iconView.centerYAnchor.constraint(
                equalTo: iconContainer.centerYAnchor
            ),

            iconView.widthAnchor.constraint(
                equalToConstant: 27
            ),

            iconView.heightAnchor.constraint(
                equalToConstant: 27
            ),

            titleLabel.topAnchor.constraint(
                equalTo: iconContainer.bottomAnchor,
                constant: 12
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 16
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -16
            ),

            descriptionLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 7
            ),

            descriptionLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 16
            ),

            descriptionLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -16
            ),

            dayLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 16
            ),

            dayLabel.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -14
            ),

            dayLabel.heightAnchor.constraint(
                equalToConstant: 28
            ),

            dayLabel.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 80
            )
        ])

        return container
    }

    private func makeDayText(
        _ days: [Int]
    ) -> String {

        guard let first = days.min(),
              let last = days.max() else {
            return ""
        }

        if first == last {
            return "Gün \(first)"
        }

        return "Gün \(first)–\(last)"
    }
}
