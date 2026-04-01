//
//  DetailsCardCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 16.03.2026.
//


import UIKit

final class DetailsCardCell: UITableViewCell {

    private let outerCard = UIView()
    private let titleLabel = UILabel()
    private let innerCard = UIView()
    private let rowStack = UIStackView()

    private let durationValueLabel = UILabel()
    private let difficultyValueLabel = UILabel()
    private let flexibilityValueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(duration: String, difficulty: String, flexibility: String) {
        durationValueLabel.text = duration
        difficultyValueLabel.text = difficulty
        flexibilityValueLabel.text = flexibility
        flexibilityValueLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        flexibilityValueLabel.numberOfLines = 2
        flexibilityValueLabel.lineBreakMode = .byWordWrapping
        flexibilityValueLabel.textAlignment = .center
        flexibilityValueLabel.setContentHuggingPriority(.required, for: .vertical)
        flexibilityValueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
       flexibilityValueLabel.text = flexibility.replacingOccurrences(of: " ", with: "\n")
    
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        outerCard.translatesAutoresizingMaskIntoConstraints = false
        outerCard.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        outerCard.layer.cornerRadius = 24
        outerCard.layer.masksToBounds = true
        outerCard.layer.borderWidth = 1
        outerCard.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.label.withAlphaComponent(0.95)
        titleLabel.text = "Program Detayları"

        innerCard.translatesAutoresizingMaskIntoConstraints = false
        innerCard.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        innerCard.layer.cornerRadius = 18
        innerCard.layer.masksToBounds = true
        innerCard.layer.borderWidth = 1
        innerCard.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        rowStack.translatesAutoresizingMaskIntoConstraints = false
        rowStack.axis = .horizontal
        rowStack.alignment = .fill
        rowStack.distribution = .fill
        rowStack.spacing = 12

        let col1 = makeDetailColumn(icon: "calendar", title: "Süre", valueLabel: durationValueLabel)
        let col2 = makeDetailColumn(icon: "flame.fill", title: "Zorluk", valueLabel: difficultyValueLabel)
        let col3 = makeDetailColumn(icon: "sparkles", title: "Element", valueLabel: flexibilityValueLabel)

        let divider1 = makeDivider()
        let divider2 = makeDivider()

        contentView.addSubview(outerCard)
        outerCard.addSubview(titleLabel)
        outerCard.addSubview(innerCard)
        innerCard.addSubview(rowStack)

        rowStack.addArrangedSubview(col1)
        rowStack.addArrangedSubview(divider1)
        rowStack.addArrangedSubview(col2)
        rowStack.addArrangedSubview(divider2)
        rowStack.addArrangedSubview(col3)

        NSLayoutConstraint.activate([
            divider1.widthAnchor.constraint(equalToConstant: 1),
            divider2.widthAnchor.constraint(equalToConstant: 1),

            col1.widthAnchor.constraint(equalTo: col2.widthAnchor),
            col2.widthAnchor.constraint(equalTo: col3.widthAnchor),

            outerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            outerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            outerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            outerCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: outerCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: outerCard.trailingAnchor, constant: -20),

            innerCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            innerCard.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 20),
            innerCard.trailingAnchor.constraint(equalTo: outerCard.trailingAnchor, constant: -20),
            innerCard.bottomAnchor.constraint(equalTo: outerCard.bottomAnchor, constant: -20),

            rowStack.topAnchor.constraint(equalTo: innerCard.topAnchor, constant: 8),
            rowStack.leadingAnchor.constraint(equalTo: innerCard.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: innerCard.trailingAnchor, constant: -16),
            rowStack.bottomAnchor.constraint(equalTo: innerCard.bottomAnchor, constant: -16),

            divider1.heightAnchor.constraint(equalToConstant: 64),
            divider2.heightAnchor.constraint(equalToConstant: 64)
            
            // elements değeri uzarsa değişiklik gerekli
        ])
    }

    private func makeDetailColumn(icon: String, title: String, valueLabel: UILabel) -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 8
        container.translatesAutoresizingMaskIntoConstraints = false

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .fill
        topRow.spacing = 6
        topRow.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemPink.withAlphaComponent(0.75)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor.label.withAlphaComponent(0.90)
        titleLabel.text = title

        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byWordWrapping
        valueLabel.textAlignment = .center
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = UIColor.label.withAlphaComponent(0.88)
        
        topRow.addArrangedSubview(imageView)
        topRow.addArrangedSubview(titleLabel)

        container.addArrangedSubview(topRow)
        container.addArrangedSubview(valueLabel)
        

        return container
    }

    private func makeDivider() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        return view
    }
}
