//
//  BadgeRewardCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 24.03.2026.
//

import UIKit

final class BadgeRewardCell: UITableViewCell {

    private let cardView = UIView()
    private let badgeImageView = RoundedImageView(frame: .zero)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textStack = UIStackView()
    private let horizontalStack = UIStackView()

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
        badgeImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(title: String, subtitle: String, imageName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        badgeImageView.image = UIImage(named: imageName)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor

        // Badge image
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.backgroundColor = UIColor.white.withAlphaComponent(0.20)

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.label.withAlphaComponent(0.95)

        // Subtitle
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = UIColor.label.withAlphaComponent(0.75)

        // Text stack
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.distribution = .fill
        textStack.spacing = 8

        // Horizontal stack
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.spacing = 16

        contentView.addSubview(cardView)
        cardView.addSubview(horizontalStack)

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        horizontalStack.addArrangedSubview(badgeImageView)
        horizontalStack.addArrangedSubview(textStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            horizontalStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            horizontalStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            horizontalStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            horizontalStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),

            badgeImageView.widthAnchor.constraint(equalToConstant: 72),
            badgeImageView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
}
