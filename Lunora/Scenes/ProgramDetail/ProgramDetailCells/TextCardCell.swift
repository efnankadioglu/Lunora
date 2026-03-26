//
//  TextCardCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 16.03.2026.
//

import UIKit

final class TextCardCell: UITableViewCell {

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let verticalStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(title: String?, body: String) {
        if let title = title, !title.isEmpty {
            titleLabel.isHidden = false
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
            titleLabel.text = nil
        }

        bodyLabel.text = body
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

        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.distribution = .fill
        verticalStack.spacing = 10

        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        titleLabel.textColor = UIColor.label.withAlphaComponent(0.95)

        bodyLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: 17, weight: .regular)
        bodyLabel.textColor = UIColor.label.withAlphaComponent(0.88)

        contentView.addSubview(cardView)
        cardView.addSubview(verticalStack)

        verticalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(bodyLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            verticalStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            verticalStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            verticalStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            verticalStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }
}
