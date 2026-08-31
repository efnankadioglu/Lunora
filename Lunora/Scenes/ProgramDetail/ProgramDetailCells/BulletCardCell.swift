//
//  BulletCardCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 16.03.2026.
//

import UIKit

final class BulletCardCell: UITableViewCell {

    // MARK: - UI

    private let cardView = UIView()

    private let headerStack = UIStackView()
    private let headerIconContainer = UIView()
    private let headerIconView = UIImageView()
    private let titleLabel = UILabel()

    private let bulletsStack = UIStackView()
    private let mainStack = UIStackView()

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

        titleLabel.text = nil

        bulletsStack.arrangedSubviews.forEach { view in
            bulletsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    // MARK: - Configure

    func configure(
        title: String,
        bullets: [String]
    ) {
        titleLabel.text = title

        bulletsStack.arrangedSubviews.forEach { view in
            bulletsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for bullet in bullets {
            bulletsStack.addArrangedSubview(
                makeBulletRow(text: bullet)
            )
        }
    }

    // MARK: - Setup

    private func setupUI() {

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCard()
        setupHeader()
        setupStacks()

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)

        headerStack.addArrangedSubview(titleLabel)

        mainStack.addArrangedSubview(headerStack)
        mainStack.addArrangedSubview(bulletsStack)

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

        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .fill
        headerStack.spacing = 12

        titleLabel.numberOfLines = 0

        titleLabel.font = .systemFont(
            ofSize: 19,
            weight: .semibold
        )

        titleLabel.textColor =
            UIColor.label.withAlphaComponent(0.95)
    }

    private func setupStacks() {

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        mainStack.spacing = 16

        bulletsStack.translatesAutoresizingMaskIntoConstraints = false
        bulletsStack.axis = .vertical
        bulletsStack.alignment = .fill
        bulletsStack.distribution = .fill
        bulletsStack.spacing = 12
    }

    // MARK: - Bullet Row

    private func makeBulletRow(text: String) -> UIView {

        let row = UIStackView()

        row.axis = .horizontal
        row.alignment = .top
        row.distribution = .fill
        row.spacing = 10

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.10)

        iconContainer.layer.cornerRadius = 9
        iconContainer.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(
                equalToConstant: 18
            ),

            iconContainer.heightAnchor.constraint(
                equalToConstant: 18
            )
        ])

        let icon = UIImageView(
            image: UIImage(
                systemName: "checkmark"
            )
        )

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        icon.tintColor =
            UIColor.systemPink.withAlphaComponent(0.85)

        iconContainer.addSubview(icon)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(
                equalTo: iconContainer.centerXAnchor
            ),

            icon.centerYAnchor.constraint(
                equalTo: iconContainer.centerYAnchor
            ),

            icon.widthAnchor.constraint(
                equalToConstant: 10
            ),

            icon.heightAnchor.constraint(
                equalToConstant: 10
            )
        ])

        let label = UILabel()

        label.numberOfLines = 0

        label.font = .systemFont(
            ofSize: 16,
            weight: .regular
        )

        label.textColor =
            UIColor.label.withAlphaComponent(0.82)

        label.text = text

        row.addArrangedSubview(iconContainer)
        row.addArrangedSubview(label)

        return row
    }
}
