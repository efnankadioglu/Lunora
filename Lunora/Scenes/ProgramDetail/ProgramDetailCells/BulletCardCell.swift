//
//  BulletCardCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 16.03.2026.
//

import UIKit

final class BulletCardCell: UITableViewCell {

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let bulletsStack = UIStackView()
    private let mainStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(title: String, bullets: [String]) {
        titleLabel.text = title

        bulletsStack.arrangedSubviews.forEach { view in
            bulletsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for bullet in bullets {
            bulletsStack.addArrangedSubview(makeBulletRow(text: bullet))
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        cardView.layer.cornerRadius = 24
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        mainStack.spacing = 12

        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        titleLabel.textColor = UIColor.label.withAlphaComponent(0.95)

        bulletsStack.axis = .vertical
        bulletsStack.alignment = .fill
        bulletsStack.distribution = .fill
        bulletsStack.spacing = 10
        bulletsStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)

        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(bulletsStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    private func makeBulletRow(text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 10

        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .systemGreen

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18)
        ])

        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.label.withAlphaComponent(0.88)
        label.text = text

        row.addArrangedSubview(icon)
        row.addArrangedSubview(label)

        return row
    }
}
