//
//  DetailsCardCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 16.03.2026.
//

import UIKit

final class DetailsCardCell: UITableViewCell {

    // MARK: - UI

    private let outerCard = UIView()

    private let titleRowStack = UIStackView()
    private let titleIconView = UIImageView()
    private let titleLabel = UILabel()

    private let statsContainer = UIView()
    private let statsStack = UIStackView()

    private let dividerLine = UIView()

    private let elementsTitleStack = UIStackView()
    private let elementsIconView = UIImageView()
    private let elementsTitleLabel = UILabel()

    private let elementsScrollView = UIScrollView()
    private let elementsHorizontalStack = UIStackView()

    // MARK: - Init

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

        elementsHorizontalStack.arrangedSubviews.forEach { view in
            elementsHorizontalStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    // MARK: - Configure

    func configure(
        duration: String,
        dailyDuration: String,
        difficulty: String,
        elementItems: [String]
    ) {
        rebuildStats(
            duration: duration,
            dailyDuration: dailyDuration,
            difficulty: difficulty
        )

        rebuildElementRows(with: elementItems)
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupOuterCard()
        setupTitleArea()
        setupStatsArea()
        setupDivider()
        setupElementsArea()

        contentView.addSubview(outerCard)

        outerCard.addSubview(titleRowStack)
        outerCard.addSubview(statsContainer)
        outerCard.addSubview(dividerLine)
        outerCard.addSubview(elementsTitleStack)
        outerCard.addSubview(elementsScrollView)

        NSLayoutConstraint.activate([
            outerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            outerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            outerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            outerCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleRowStack.topAnchor.constraint(equalTo: outerCard.topAnchor, constant: 20),
            titleRowStack.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 20),
            titleRowStack.trailingAnchor.constraint(lessThanOrEqualTo: outerCard.trailingAnchor, constant: -20),

            statsContainer.topAnchor.constraint(equalTo: titleRowStack.bottomAnchor, constant: 18),
            statsContainer.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 20),
            statsContainer.trailingAnchor.constraint(equalTo: outerCard.trailingAnchor, constant: -20),

            statsStack.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 4),
            statsStack.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor),
            statsStack.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor),
            statsStack.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -4),

            dividerLine.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 18),
            dividerLine.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 20),
            dividerLine.trailingAnchor.constraint(equalTo: outerCard.trailingAnchor, constant: -20),
            dividerLine.heightAnchor.constraint(equalToConstant: 1),

            elementsTitleStack.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 16),
            elementsTitleStack.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 20),
            elementsTitleStack.trailingAnchor.constraint(lessThanOrEqualTo: outerCard.trailingAnchor, constant: -20),

            elementsScrollView.topAnchor.constraint(equalTo: elementsTitleStack.bottomAnchor,
                constant: 12
            ),

            elementsScrollView.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor,
                constant: 20
            ),

            elementsScrollView.trailingAnchor.constraint(equalTo: outerCard.trailingAnchor,
                constant: -20
            ),

            elementsScrollView.heightAnchor.constraint(equalToConstant: 38
            ),

            elementsScrollView.bottomAnchor.constraint(
                equalTo: outerCard.bottomAnchor,
                constant: -20
            ),

            elementsHorizontalStack.topAnchor.constraint(
                equalTo: elementsScrollView.contentLayoutGuide.topAnchor
            ),

            elementsHorizontalStack.leadingAnchor.constraint(
                equalTo: elementsScrollView.contentLayoutGuide.leadingAnchor
            ),

            elementsHorizontalStack.trailingAnchor.constraint(
                equalTo: elementsScrollView.contentLayoutGuide.trailingAnchor
            ),

            elementsHorizontalStack.bottomAnchor.constraint(
                equalTo: elementsScrollView.contentLayoutGuide.bottomAnchor
            ),

            elementsHorizontalStack.heightAnchor.constraint(
                equalTo: elementsScrollView.frameLayoutGuide.heightAnchor
            )        ])
    }

    private func setupOuterCard() {
        outerCard.translatesAutoresizingMaskIntoConstraints = false
        outerCard.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        outerCard.layer.cornerRadius = 24
        outerCard.layer.masksToBounds = true
        outerCard.layer.borderWidth = 1
        outerCard.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
    }

    private func setupTitleArea() {
        titleRowStack.translatesAutoresizingMaskIntoConstraints = false
        titleRowStack.axis = .horizontal
        titleRowStack.alignment = .center
        titleRowStack.spacing = 10

        titleIconView.translatesAutoresizingMaskIntoConstraints = false
        titleIconView.image = UIImage(systemName: "sparkles")
        titleIconView.contentMode = .scaleAspectFit
        titleIconView.tintColor = UIColor.systemPink.withAlphaComponent(0.78)

        NSLayoutConstraint.activate([
            titleIconView.widthAnchor.constraint(equalToConstant: 22),
            titleIconView.heightAnchor.constraint(equalToConstant: 22)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Program Özeti"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.label.withAlphaComponent(0.95)

        titleRowStack.addArrangedSubview(titleIconView)
        titleRowStack.addArrangedSubview(titleLabel)
    }

    private func setupStatsArea() {
        statsContainer.translatesAutoresizingMaskIntoConstraints = false

        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .horizontal
        statsStack.alignment = .top
        statsStack.distribution = .fill
        statsStack.spacing = 0

        statsContainer.addSubview(statsStack)
    }

    private func setupDivider() {
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        dividerLine.backgroundColor = UIColor.systemPink.withAlphaComponent(0.18)
    }

    private func setupElementsArea() {

        elementsTitleStack.translatesAutoresizingMaskIntoConstraints = false
        elementsTitleStack.axis = .horizontal
        elementsTitleStack.alignment = .center
        elementsTitleStack.spacing = 8

        elementsIconView.translatesAutoresizingMaskIntoConstraints = false
        elementsIconView.image = UIImage(systemName: "sparkles")
        elementsIconView.contentMode = .scaleAspectFit
        elementsIconView.tintColor = UIColor.systemPink.withAlphaComponent(0.78)

        NSLayoutConstraint.activate([
            elementsIconView.widthAnchor.constraint(equalToConstant: 18),
            elementsIconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        elementsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        elementsTitleLabel.text = "Elementler"
        elementsTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        elementsTitleLabel.textColor = UIColor.label.withAlphaComponent(0.92)

        elementsTitleStack.addArrangedSubview(elementsIconView)
        elementsTitleStack.addArrangedSubview(elementsTitleLabel)

        // Horizontal scroll
        elementsScrollView.translatesAutoresizingMaskIntoConstraints = false
        elementsScrollView.showsHorizontalScrollIndicator = false
        elementsScrollView.showsVerticalScrollIndicator = false
        elementsScrollView.alwaysBounceHorizontal = true

        elementsHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        elementsHorizontalStack.axis = .horizontal
        elementsHorizontalStack.alignment = .center
        elementsHorizontalStack.distribution = .fill
        elementsHorizontalStack.spacing = 8

        elementsScrollView.addSubview(elementsHorizontalStack)
    }

    // MARK: - Stats

    private func rebuildStats(
        duration: String,
        dailyDuration: String,
        difficulty: String
    ) {
        statsStack.arrangedSubviews.forEach { view in
            statsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let durationView = makeStatItem(
            icon: "calendar",
            value: duration,
            title: "Süre"
        )

        let dailyView = makeStatItem(
            icon: "clock",
            value: dailyDuration,
            title: "Günlük süre"
        )

        let difficultyView = makeStatItem(
            icon: "flame.fill",
            value: difficulty,
            title: "Zorluk"
        )

        let divider1 = makeVerticalDivider()
        let divider2 = makeVerticalDivider()

        statsStack.addArrangedSubview(durationView)
        statsStack.addArrangedSubview(divider1)
        statsStack.addArrangedSubview(dailyView)
        statsStack.addArrangedSubview(divider2)
        statsStack.addArrangedSubview(difficultyView)

        NSLayoutConstraint.activate([
            divider1.widthAnchor.constraint(equalToConstant: 1),
            divider2.widthAnchor.constraint(equalToConstant: 1),

            durationView.widthAnchor.constraint(equalTo: dailyView.widthAnchor),
            dailyView.widthAnchor.constraint(equalTo: difficultyView.widthAnchor),

            divider1.heightAnchor.constraint(equalToConstant: 86),
            divider2.heightAnchor.constraint(equalToConstant: 86)
        ])
    }

    private func makeStatItem(
        icon: String,
        value: String,
        title: String
    ) -> UIView {

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8

        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor.systemPink.withAlphaComponent(0.10)
        iconCircle.layer.cornerRadius = 22
        iconCircle.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            iconCircle.widthAnchor.constraint(equalToConstant: 44),
            iconCircle.heightAnchor.constraint(equalToConstant: 44)
        ])

        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemPink.withAlphaComponent(0.82)

        iconCircle.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = UIColor.label.withAlphaComponent(0.92)
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 0
        valueLabel.text = value

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = UIColor.label.withAlphaComponent(0.58)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = title

        stack.addArrangedSubview(iconCircle)
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(titleLabel)

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func makeVerticalDivider() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemPink.withAlphaComponent(0.16)
        return view
    }

    // MARK: - Element Chips

    private func rebuildElementRows(with items: [String]) {

        elementsHorizontalStack.arrangedSubviews.forEach { view in
            elementsHorizontalStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard !items.isEmpty else { return }

        for item in items {

            let chip = makeChip(text: item)

            chip.setContentHuggingPriority(
                .required,
                for: .horizontal
            )

            chip.setContentCompressionResistancePriority(
                .required,
                for: .horizontal
            )

            elementsHorizontalStack.addArrangedSubview(chip)
        }
    }

    private func makeChip(text: String) -> UIView {
        let chip = UIView()
        chip.translatesAutoresizingMaskIntoConstraints = false
        chip.layer.cornerRadius = 18
        chip.layer.masksToBounds = true
        chip.layer.borderWidth = 1

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = text

        if text.contains("Su") {
            chip.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.06)
            chip.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.20).cgColor
            label.textColor = UIColor.label.withAlphaComponent(0.90)
        } else if text.contains("Hava") {
            chip.backgroundColor = UIColor.systemGray.withAlphaComponent(0.08)
            chip.layer.borderColor = UIColor.systemGray3.withAlphaComponent(0.40).cgColor
            label.textColor = UIColor.label.withAlphaComponent(0.90)
        } else if text.contains("Toprak") {
            chip.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.06)
            chip.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.18).cgColor
            label.textColor = UIColor.label.withAlphaComponent(0.90)
        } else if text.contains("Ateş") {
            chip.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.07)
            chip.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.20).cgColor
            label.textColor = UIColor.label.withAlphaComponent(0.90)
        } else {
            chip.backgroundColor = UIColor.white.withAlphaComponent(0.40)
            chip.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
            label.textColor = UIColor.label.withAlphaComponent(0.90)
        }

        chip.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: chip.topAnchor,
                constant: 7
            ),

            label.leadingAnchor.constraint(
                equalTo: chip.leadingAnchor,
                constant: 11
            ),

            label.trailingAnchor.constraint(
                equalTo: chip.trailingAnchor,
                constant: -11
            ),

            label.bottomAnchor.constraint(
                equalTo: chip.bottomAnchor,
                constant: -7
            ),

            chip.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 34
            )
        ])

        return chip
    }
}
