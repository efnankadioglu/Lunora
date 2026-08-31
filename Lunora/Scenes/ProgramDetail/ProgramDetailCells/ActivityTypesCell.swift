//
//  ActivityTypesCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.08.2026.
//

import UIKit

final class ActivityTypesCell: UITableViewCell {

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let itemsStack = UIStackView()
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

        itemsStack.arrangedSubviews.forEach { view in
            itemsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func configure(
        title: String,
        items: [ProgramActivityType]
    ) {
        titleLabel.text = title

        itemsStack.arrangedSubviews.forEach { view in
            itemsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for item in items {
            itemsStack.addArrangedSubview(
                makeActivityRow(item: item)
            )
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
        cardView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.30).cgColor

        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(
            ofSize: 19,
            weight: .semibold
        )
        titleLabel.textColor =
            UIColor.label.withAlphaComponent(0.95)

        itemsStack.axis = .vertical
        itemsStack.alignment = .fill
        itemsStack.distribution = .fill
        itemsStack.spacing = 14

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        mainStack.spacing = 18

        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)

        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(itemsStack)

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

    private func makeActivityRow(
        item: ProgramActivityType
    ) -> UIView {

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 12

        let emojiLabel = UILabel()
        emojiLabel.font = .systemFont(ofSize: 21)
        emojiLabel.text = item.emoji
        emojiLabel.textAlignment = .center

        emojiLabel.widthAnchor
            .constraint(equalToConstant: 30)
            .isActive = true

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 3

        let activityTitleLabel = UILabel()
        activityTitleLabel.numberOfLines = 0
        activityTitleLabel.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )
        activityTitleLabel.textColor =
            UIColor.label.withAlphaComponent(0.88)
        activityTitleLabel.text = item.title

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(
            ofSize: 13,
            weight: .regular
        )
        descriptionLabel.textColor =
            UIColor.label.withAlphaComponent(0.58)
        descriptionLabel.text = item.description

        textStack.addArrangedSubview(activityTitleLabel)
        textStack.addArrangedSubview(descriptionLabel)

        let frequencyLabel = UILabel()
        frequencyLabel.font = .systemFont(
            ofSize: 12,
            weight: .semibold
        )

        frequencyLabel.text = item.frequencyText
        frequencyLabel.textAlignment = .center

        frequencyLabel.textColor =
            UIColor.systemPink.withAlphaComponent(0.85)

        frequencyLabel.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.09)

        frequencyLabel.layer.cornerRadius = 12
        frequencyLabel.layer.masksToBounds = true

        frequencyLabel.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        frequencyLabel.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        frequencyLabel.widthAnchor
            .constraint(greaterThanOrEqualToConstant: 48)
            .isActive = true

        frequencyLabel.heightAnchor
            .constraint(equalToConstant: 26)
            .isActive = true

        row.addArrangedSubview(emojiLabel)
        row.addArrangedSubview(textStack)
        row.addArrangedSubview(frequencyLabel)

        return row
    }
}
