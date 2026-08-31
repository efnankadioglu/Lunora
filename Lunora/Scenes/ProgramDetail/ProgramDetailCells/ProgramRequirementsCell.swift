//
//  ProgramRequirementsCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.08.2026.
//

import UIKit

final class ProgramRequirementsCell: UITableViewCell {

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
        items: [ProgramRequirementItem]
    ) {
        titleLabel.text = title

        itemsStack.arrangedSubviews.forEach { view in
            itemsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for item in items {
            itemsStack.addArrangedSubview(
                makeRequirementRow(item: item)
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

    private func makeRequirementRow(
        item: ProgramRequirementItem
    ) -> UIView {

        let row = UIStackView()

        row.axis = .horizontal
        row.alignment = .top
        row.distribution = .fill
        row.spacing = 12

        // Pembe nokta
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false

        dot.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.65)

        dot.layer.cornerRadius = 4

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8)
        ])

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 4

        let itemTitleLabel = UILabel()
        itemTitleLabel.numberOfLines = 0
        itemTitleLabel.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )
        itemTitleLabel.textColor =
            UIColor.label.withAlphaComponent(0.88)

        itemTitleLabel.text = item.title

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(
            ofSize: 14,
            weight: .regular
        )

        descriptionLabel.textColor =
            UIColor.label.withAlphaComponent(0.58)

        descriptionLabel.text = item.description

        textStack.addArrangedSubview(itemTitleLabel)
        textStack.addArrangedSubview(descriptionLabel)

        // Noktayı ilk satırın ortasına yaklaştırıyoruz
        let dotWrapper = UIView()
        dotWrapper.translatesAutoresizingMaskIntoConstraints = false

        dotWrapper.addSubview(dot)

        NSLayoutConstraint.activate([
            dot.topAnchor.constraint(
                equalTo: dotWrapper.topAnchor,
                constant: 7
            ),

            dot.leadingAnchor.constraint(
                equalTo: dotWrapper.leadingAnchor
            ),

            dot.trailingAnchor.constraint(
                equalTo: dotWrapper.trailingAnchor
            )
        ])

        dotWrapper.widthAnchor
            .constraint(equalToConstant: 8)
            .isActive = true

        row.addArrangedSubview(dotWrapper)
        row.addArrangedSubview(textStack)

        return row
    }
}
