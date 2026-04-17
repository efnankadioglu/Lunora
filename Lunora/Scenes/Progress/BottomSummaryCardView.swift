//
//  BottomSummaryCardView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 9.04.2026.
//

import UIKit

final class BottomSummaryCardView: UIView {

    private let gradientLayer = CAGradientLayer()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "BUGÜNÜN MANTRAN"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        return label
    }()

    private let mantraLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\"Her küçük adım, büyük değişimin parçası.\""
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let sparklesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "✧"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let dividerTop: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        return view
    }()

    private let divider1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        return view
    }()

    private let divider2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        return view
    }()

    private let streakValueLabel = BottomSummaryCardView.makeValueLabel()
    private let completedValueLabel = BottomSummaryCardView.makeValueLabel()
    private let remainingValueLabel = BottomSummaryCardView.makeValueLabel()

    private let streakTitleLabel = BottomSummaryCardView.makeCaptionLabel(text: "GÜN STREAK")
    private let completedTitleLabel = BottomSummaryCardView.makeCaptionLabel(text: "TAMAMLANDI")
    private let remainingTitleLabel = BottomSummaryCardView.makeCaptionLabel(text: "KALAN SÜRE")

    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configure(
            mantra: "Her küçük adım, büyük değişimin parçası.",
            streakText: "15",
            completedText: "0/4",
            remainingText: "7s 52dk"
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        configure(
            mantra: "Her küçük adım, büyük değişimin parçası.",
            streakText: "15",
            completedText: "0/4",
            remainingText: "7s 52dk"
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 24
    }

    func configure(mantra: String, streakText: String, completedText: String, remainingText: String) {
        mantraLabel.text = "\"\(mantra)\""
        streakValueLabel.text = streakText
        completedValueLabel.text = completedText
        remainingValueLabel.text = remainingText
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 24
        layer.masksToBounds = true

        gradientLayer.colors = [
            UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1).cgColor, // #FAB9DB
            UIColor(red: 248/255, green: 120/255, blue: 185/255, alpha: 1).cgColor,
            UIColor(red: 245/255, green: 56/255, blue: 154/255, alpha: 1).cgColor,  // #F5389A
            UIColor(red: 248/255, green: 140/255, blue: 120/255, alpha: 1).cgColor,
            UIColor(red: 252/255, green: 212/255, blue: 69/255, alpha: 1).cgColor   // #FCD445
        ]

        gradientLayer.locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.35)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.65)
        gradientLayer.type = .axial
        layer.insertSublayer(gradientLayer, at: 0)

        addSubview(titleLabel)
        addSubview(mantraLabel)
        addSubview(sparklesLabel)
        addSubview(dividerTop)
        addSubview(statsStackView)

        let streakBlock = makeStatBlock(valueLabel: streakValueLabel, titleLabel: streakTitleLabel)
        let completedBlock = makeStatBlock(valueLabel: completedValueLabel, titleLabel: completedTitleLabel)
        let remainingBlock = makeStatBlock(valueLabel: remainingValueLabel, titleLabel: remainingTitleLabel)

        statsStackView.addArrangedSubview(streakBlock)
        statsStackView.addArrangedSubview(completedBlock)
        statsStackView.addArrangedSubview(remainingBlock)

        addSubview(divider1)
        addSubview(divider2)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),

            sparklesLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            sparklesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),

            mantraLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            mantraLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            mantraLabel.trailingAnchor.constraint(equalTo: sparklesLabel.leadingAnchor, constant: -12),

            dividerTop.topAnchor.constraint(equalTo: mantraLabel.bottomAnchor, constant: 18),
            dividerTop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            dividerTop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            dividerTop.heightAnchor.constraint(equalToConstant: 1),

            statsStackView.topAnchor.constraint(equalTo: dividerTop.bottomAnchor, constant: 18),
            statsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            statsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            statsStackView.heightAnchor.constraint(equalToConstant: 72),

            divider1.centerXAnchor.constraint(equalTo: leadingAnchor, constant: bounds.width / 3),
            divider1.widthAnchor.constraint(equalToConstant: 1),
            divider1.topAnchor.constraint(equalTo: statsStackView.topAnchor, constant: 6),
            divider1.bottomAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: -6),

            divider2.centerXAnchor.constraint(equalTo: leadingAnchor, constant: (bounds.width / 3) * 2),
            divider2.widthAnchor.constraint(equalToConstant: 1),
            divider2.topAnchor.constraint(equalTo: statsStackView.topAnchor, constant: 6),
            divider2.bottomAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: -6)
        ])
    }

    private func makeStatBlock(valueLabel: UILabel, titleLabel: UILabel) -> UIView {
        let container = UIView()

        container.addSubview(valueLabel)
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor)
        ])

        return container
    }

    private static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }

    private static func makeCaptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }
}
