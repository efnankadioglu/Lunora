//
//  CompletedSummaryHeaderView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.04.2026.
//

import UIKit

struct CompletedSummaryHeaderData {
    let completedProgramCount: Int
    let totalCompletedDays: Int
    let bestStreakText: String
    let badgeImageNames: [String]
}
final class CompletedSummaryHeaderView: UIView {
    
    var onTapAddProgram: (() -> Void)?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let cardsStackView = UIStackView()
    private let badgesContainerView = UIView()
    private let badgesStackView = UIStackView()
    private let badgesScrollView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor(named: "lunoraPink") ?? UIColor(
            red: 246/255,
            green: 238/255,
            blue: 244/255,
            alpha: 1
        )

        let mainStack = UIStackView()
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 20

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        // Title
        titleLabel.text = "Başarı Koleksiyonum"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)

        subtitleLabel.text = ""
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 113/255, green: 122/255, blue: 138/255, alpha: 1)
        
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 6

        mainStack.addArrangedSubview(headerStack)

        // Cards
        cardsStackView.axis = .horizontal
        cardsStackView.distribution = .fillEqually
        cardsStackView.spacing = 12

        mainStack.addArrangedSubview(cardsStackView)

        // Badges
        badgesContainerView.backgroundColor = .white
        badgesContainerView.layer.cornerRadius = 20

        let badgesTitle = UILabel()
        badgesTitle.text = "Kazanılan Rozetler:"
        badgesTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        
        badgesScrollView.translatesAutoresizingMaskIntoConstraints = false
        badgesScrollView.showsHorizontalScrollIndicator = false
        badgesScrollView.alwaysBounceHorizontal = true

        badgesStackView.translatesAutoresizingMaskIntoConstraints = false
        badgesStackView.axis = .horizontal
        badgesStackView.spacing = 18
        badgesStackView.distribution = .fill
        badgesStackView.alignment = .center

        badgesScrollView.addSubview(badgesStackView)

        let badgesInnerStack = UIStackView(arrangedSubviews: [badgesTitle, badgesScrollView])
        badgesInnerStack.axis = .vertical
        badgesInnerStack.spacing = 12
        badgesInnerStack.translatesAutoresizingMaskIntoConstraints = false

        badgesContainerView.addSubview(badgesInnerStack)

        NSLayoutConstraint.activate([
            badgesInnerStack.topAnchor.constraint(equalTo: badgesContainerView.topAnchor, constant: 16),
            badgesInnerStack.leadingAnchor.constraint(equalTo: badgesContainerView.leadingAnchor, constant: 16),
            badgesInnerStack.trailingAnchor.constraint(equalTo: badgesContainerView.trailingAnchor, constant: -16),
            badgesInnerStack.bottomAnchor.constraint(equalTo: badgesContainerView.bottomAnchor, constant: -16),

            badgesScrollView.heightAnchor.constraint(equalToConstant: 76),

            badgesStackView.topAnchor.constraint(equalTo: badgesScrollView.contentLayoutGuide.topAnchor),
            badgesStackView.leadingAnchor.constraint(equalTo: badgesScrollView.contentLayoutGuide.leadingAnchor),
            badgesStackView.trailingAnchor.constraint(equalTo: badgesScrollView.contentLayoutGuide.trailingAnchor),
            badgesStackView.bottomAnchor.constraint(equalTo: badgesScrollView.contentLayoutGuide.bottomAnchor),
            badgesStackView.heightAnchor.constraint(equalTo: badgesScrollView.frameLayoutGuide.heightAnchor)
        ])
        

        mainStack.addArrangedSubview(badgesContainerView)

    }

    func configure(with data: CompletedSummaryHeaderData) {
        
        if data.completedProgramCount == 0 {
                subtitleLabel.text = "Henüz bir program tamamlamadın. İlk adımını attığında başarıların burada görünecek ✨"
            } else {
                subtitleLabel.text = "Harikasın! Her adım bir zafer ✨"
            }
        
        cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        cardsStackView.addArrangedSubview(makeCard(
            value: "\(data.completedProgramCount)",
            title: "Tamamlanan Program"
        ))

        cardsStackView.addArrangedSubview(makeCard(
            value: "\(data.totalCompletedDays)",
            title: "Aktif Günler"
        ))

        cardsStackView.addArrangedSubview(makeCard(
            value: data.bestStreakText,
            title: "En Uzun Seri"
        ))

        badgesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for imageName in data.badgeImageNames {
            let badgeView = makeBadgeIcon(imageName: imageName)
            badgesStackView.addArrangedSubview(badgeView)
        }

        if data.badgeImageNames.isEmpty {
            badgesStackView.addArrangedSubview(makePlusBadgeIcon())
        }
    }

    private func makeCard(value: String, title: String) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 155).isActive = true

        let colors: [CGColor]

        switch title {
        case "Tamamlanan Program":
            colors = [
                UIColor(red: 255/255, green: 185/255, blue: 0/255, alpha: 1).cgColor,
                UIColor(red: 255/255, green: 150/255, blue: 0/255, alpha: 1).cgColor
            ]

        case "Aktif Günler":
            colors = [
                UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1).cgColor,
                UIColor(red: 255/255, green: 80/255, blue: 150/255, alpha: 1).cgColor
            ]

        default:
            colors = [
                UIColor(red: 140/255, green: 100/255, blue: 255/255, alpha: 1).cgColor,
                UIColor(red: 110/255, green: 70/255, blue: 230/255, alpha: 1).cgColor
            ]
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 20
        view.layer.insertSublayer(gradientLayer, at: 0)

        let iconCircleView = UIView()
        iconCircleView.translatesAutoresizingMaskIntoConstraints = false
        iconCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        iconCircleView.layer.cornerRadius = 26
        iconCircleView.widthAnchor.constraint(equalToConstant: 52).isActive = true
        iconCircleView.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let iconLabel = UILabel() 
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = title == "Tamamlanan Program" ? "😊" : (title == "Aktif Günler" ? "🔥" : "⭐️")
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.textAlignment = .center

        iconCircleView.addSubview(iconLabel)

        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor)
        ])

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 30, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75

        let stack = UIStackView(arrangedSubviews: [iconCircleView, valueLabel, titleLabel]) // DÜZELTTİM
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -8)
        ])

        DispatchQueue.main.async {
            view.layoutIfNeeded()
            gradientLayer.frame = view.bounds
        }

        return view
    }
    
    private func makeBadgeIcon(imageName: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.clipsToBounds = false

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 56),
            container.heightAnchor.constraint(equalToConstant: 56)
        ])

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 28
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = .clear

        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }
    
    private func makePlusBadgeIcon() -> UIView {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.backgroundColor = UIColor(
            red: 255/255,
            green: 232/255,
            blue: 244/255,
            alpha: 1
        )

        button.setTitle("+", for: .normal)
        button.setTitleColor(
            UIColor(
                red: 230/255,
                green: 112/255,
                blue: 174/255,
                alpha: 1
            ),
            for: .normal
        )

        button.titleLabel?.font = .systemFont(ofSize: 28, weight: .semibold)

        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(
            red: 244/255,
            green: 180/255,
            blue: 216/255,
            alpha: 1
        ).cgColor

        button.clipsToBounds = true

        button.addTarget(
            self,
            action: #selector(didTapAddProgram),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 68),
            button.heightAnchor.constraint(equalToConstant: 68)
        ])

        button.layer.cornerRadius = 34

        return button
    }
    
    @objc
    private func didTapAddProgram() {
        onTapAddProgram?()
    }

}
