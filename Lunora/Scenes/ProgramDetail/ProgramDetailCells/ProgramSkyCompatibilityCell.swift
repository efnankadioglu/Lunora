//
//  ProgramSkyCompatibilityCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.08.2026.
//

import UIKit

final class ProgramSkyCompatibilityCell: UITableViewCell {
    
    private let cardView = UIView()
    private let gradientLayer = CAGradientLayer()

    // MARK: - Header

    private let headerStack = UIStackView()

    private let moonIconContainer = UIView()
    private let moonIconView = UIImageView()

    private let titleLabel = UILabel()

    // MARK: - Status

    private let statusContainer = UIView()
    private let statusDot = UIView()
    private let statusLabel = UILabel()

    // MARK: - Description

    private let descriptionLabel = UILabel()

    // MARK: - Matched Sky Items

    private let matchedItemsScrollView = UIScrollView()
    private let matchedItemsStack = UIStackView()

    // MARK: - Main

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

        titleLabel.text = nil
        statusLabel.text = nil
        descriptionLabel.text = nil

        matchedItemsStack.arrangedSubviews.forEach { view in
            matchedItemsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = cardView.bounds
    }

    func configure(
        compatibility: ProgramSkyCompatibility
    ) {

        titleLabel.text = "Başlamak İçin En İyi Zaman"

        statusLabel.text = compatibility.title
        statusLabel.textColor = .white

        statusDot.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.90)

        statusContainer.backgroundColor =
            UIColor.white.withAlphaComponent(0.10)

        descriptionLabel.text = compatibility.description

        matchedItemsStack.arrangedSubviews.forEach { view in
            matchedItemsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        matchedItemsScrollView.isHidden = true
    }

    private func setupUI() {

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCard()
        setupHeader()
        setupTitle()
        setupStatus()
        setupDescription()
        setupMatchedItems()
        setupMatchedItems()
        setupStacks()

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)

        mainStack.addArrangedSubview(headerStack)
        mainStack.addArrangedSubview(statusContainer)
        mainStack.addArrangedSubview(descriptionLabel)
        mainStack.addArrangedSubview(matchedItemsScrollView)

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

        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true

        cardView.layer.borderWidth = 1
        cardView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.12).cgColor

        gradientLayer.colors = [
            UIColor(
                red: 11 / 255,
                green: 12 / 255,
                blue: 116 / 255,
                alpha: 1
            ).cgColor,
            UIColor(
                red: 28 / 255,
                green: 79 / 255,
                blue: 205 / 255,
                alpha: 1
            ).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        gradientLayer.cornerRadius = 24

        if gradientLayer.superlayer == nil {
            cardView.layer.insertSublayer(
                gradientLayer,
                at: 0
            )
        }
    }
    
    private func setupHeader() {

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .fill
        headerStack.spacing = 12

        moonIconContainer.translatesAutoresizingMaskIntoConstraints = false

        moonIconContainer.backgroundColor =
            UIColor.white.withAlphaComponent(0.10)

        moonIconContainer.layer.cornerRadius = 22
        moonIconContainer.layer.masksToBounds = true

        moonIconContainer.layer.borderWidth = 1

        moonIconContainer.layer.borderColor =
            UIColor.white.withAlphaComponent(0.18).cgColor

        moonIconView.translatesAutoresizingMaskIntoConstraints = false
        moonIconView.contentMode = .scaleAspectFit

        moonIconView.image = UIImage(
            systemName: "moon.stars.fill"
        )

        moonIconView.tintColor = UIColor(
            red: 1.0,
            green: 0.91,
            blue: 0.62,
            alpha: 1
        )

        moonIconContainer.addSubview(moonIconView)

        NSLayoutConstraint.activate([

            moonIconContainer.widthAnchor.constraint(
                equalToConstant: 44
            ),

            moonIconContainer.heightAnchor.constraint(
                equalToConstant: 44
            ),

            moonIconView.centerXAnchor.constraint(
                equalTo: moonIconContainer.centerXAnchor
            ),

            moonIconView.centerYAnchor.constraint(
                equalTo: moonIconContainer.centerYAnchor
            ),

            moonIconView.widthAnchor.constraint(
                equalToConstant: 23
            ),

            moonIconView.heightAnchor.constraint(
                equalToConstant: 23
            )
        ])

        headerStack.addArrangedSubview(moonIconContainer)
        headerStack.addArrangedSubview(titleLabel)
    }

    private func setupTitle() {

        titleLabel.numberOfLines = 0

        titleLabel.font = .systemFont(
            ofSize: 19,
            weight: .semibold
        )

        titleLabel.textColor = .white
    }

    private func setupStatus() {

        statusContainer.translatesAutoresizingMaskIntoConstraints = false

        statusContainer.layer.cornerRadius = 14
        statusContainer.layer.masksToBounds = true

        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.layer.cornerRadius = 4

        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.font = .systemFont(
            ofSize: 13,
            weight: .semibold
        )

        statusContainer.addSubview(statusDot)
        statusContainer.addSubview(statusLabel)

        NSLayoutConstraint.activate([

            statusDot.leadingAnchor.constraint(
                equalTo: statusContainer.leadingAnchor,
                constant: 10
            ),

            statusDot.centerYAnchor.constraint(
                equalTo: statusContainer.centerYAnchor
            ),

            statusDot.widthAnchor.constraint(
                equalToConstant: 8
            ),

            statusDot.heightAnchor.constraint(
                equalToConstant: 8
            ),

            statusLabel.leadingAnchor.constraint(
                equalTo: statusDot.trailingAnchor,
                constant: 7
            ),

            statusLabel.trailingAnchor.constraint(
                equalTo: statusContainer.trailingAnchor,
                constant: -12
            ),

            statusLabel.topAnchor.constraint(
                equalTo: statusContainer.topAnchor,
                constant: 7
            ),

            statusLabel.bottomAnchor.constraint(
                equalTo: statusContainer.bottomAnchor,
                constant: -7
            )
        ])
    }

    private func setupDescription() {

        descriptionLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        descriptionLabel.textColor =
            UIColor.white.withAlphaComponent(0.72)
    }
    
    private func setupMatchedItems() {

        matchedItemsScrollView.translatesAutoresizingMaskIntoConstraints = false

        matchedItemsScrollView.showsHorizontalScrollIndicator = false
        matchedItemsScrollView.showsVerticalScrollIndicator = false

        matchedItemsScrollView.alwaysBounceHorizontal = true

        matchedItemsStack.translatesAutoresizingMaskIntoConstraints = false
        matchedItemsStack.axis = .horizontal
        matchedItemsStack.alignment = .center
        matchedItemsStack.distribution = .fill
        matchedItemsStack.spacing = 8

        matchedItemsScrollView.addSubview(matchedItemsStack)

        NSLayoutConstraint.activate([

            matchedItemsScrollView.heightAnchor.constraint(
                equalToConstant: 42
            ),

            matchedItemsStack.topAnchor.constraint(
                equalTo: matchedItemsScrollView.contentLayoutGuide.topAnchor
            ),

            matchedItemsStack.bottomAnchor.constraint(
                equalTo: matchedItemsScrollView.contentLayoutGuide.bottomAnchor
            ),

            matchedItemsStack.leadingAnchor.constraint(
                equalTo: matchedItemsScrollView.contentLayoutGuide.leadingAnchor
            ),

            matchedItemsStack.trailingAnchor.constraint(
                equalTo: matchedItemsScrollView.contentLayoutGuide.trailingAnchor
            ),

            matchedItemsStack.heightAnchor.constraint(
                equalTo: matchedItemsScrollView.frameLayoutGuide.heightAnchor
            )
        ])
    }

    private func setupStacks() {

        mainStack.translatesAutoresizingMaskIntoConstraints = false

        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        mainStack.spacing = 16
    }

    private func configureStatus(
        _ status: ProgramSkyCompatibilityStatus
    ) {

        switch status {

        case .supportive:

            statusLabel.text = "Destekleyici"

            statusLabel.textColor =
                UIColor.systemPink.withAlphaComponent(0.90)

            statusDot.backgroundColor =
                UIColor.systemPink.withAlphaComponent(0.80)

            statusContainer.backgroundColor =
                UIColor.systemPink.withAlphaComponent(0.09)

        case .neutral:

            statusLabel.text = "Nötr"

            statusLabel.textColor =
                UIColor.secondaryLabel

            statusDot.backgroundColor =
                UIColor.systemGray

            statusContainer.backgroundColor =
                UIColor.systemGray.withAlphaComponent(0.10)

        case .slowDown:

            statusLabel.text = "Yavaşlamak İyi Gelebilir"

            statusLabel.textColor =
                UIColor.systemOrange.withAlphaComponent(0.90)

            statusDot.backgroundColor =
                UIColor.systemOrange.withAlphaComponent(0.80)

            statusContainer.backgroundColor =
                UIColor.systemOrange.withAlphaComponent(0.10)
        }
    }

    private func makeMatchedItemView(
        item: ProgramSkyCompatibilityItem
    ) -> UIView {

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        container.backgroundColor =
            UIColor.white.withAlphaComponent(0.55)

        container.layer.cornerRadius = 14
        container.layer.masksToBounds = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 13,
            weight: .medium
        )

        label.textColor =
            UIColor.label.withAlphaComponent(0.78)

        if let symbol = item.symbol,
           !symbol.isEmpty {

            label.text =
                "\(symbol) \(item.title)"

        } else {

            label.text =
                item.title
        }

        container.addSubview(label)

        NSLayoutConstraint.activate([

            label.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 7
            ),

            label.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -7
            ),

            label.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 10
            ),

            label.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -10
            )
        ])

        return container
    }
}
