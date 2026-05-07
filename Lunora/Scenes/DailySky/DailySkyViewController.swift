//
//  DailySkyViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.05.2026.
//

import UIKit

final class DailySkyViewController: UIViewController {

    private let displayData: DailySkyDisplayData

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    init(displayData: DailySkyDisplayData) {
        self.displayData = displayData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "lunoraPink") ?? UIColor(
            red: 246/255,
            green: 238/255,
            blue: 244/255,
            alpha: 1
        )

        setupScrollView()
        setupContent()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupContent() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])

        addHeroCard()
        addDailyCommentCard()
        addMoonSignCard()
        addExtraEvents()
    }

    private func addHeroCard() {
        let daily = displayData.dailyAstrology

        let title = "Bugünün Gökyüzü"
        let subtitle = "\(daily.moonPhase) · Ay \(daily.moonSign) burcunda"
        let scoreText = "\(daily.suitabilityScore)/10 enerji uyumu"

        stackView.addArrangedSubview(
            makeCard(
                title: title,
                subtitle: subtitle,
                body: scoreText
            )
        )
    }

    private func addDailyCommentCard() {
        let daily = displayData.dailyAstrology

        stackView.addArrangedSubview(
            makeCard(
                title: "Günün Mesajı",
                subtitle: "Kısa gökyüzü yorumu",
                body: daily.dailyComment
            )
        )
    }

    private func addMoonSignCard() {
        guard let insight = displayData.moonSignInsight else {
            stackView.addArrangedSubview(
                makeCard(
                    title: "Ay Burcu Yorumu",
                    subtitle: "Bugünün ay burcu için yorum hazırlanıyor.",
                    body: "Ay burcu verisi var ancak detay yorumu eşleşmedi."
                )
            )
            return
        }

        stackView.addArrangedSubview(
            makeCard(
                title: insight.title,
                subtitle: insight.subtitle,
                body: insight.content.feeling
            )
        )
    }

    private func addExtraEvents() {
        if displayData.extraEventInsights.isEmpty {
            stackView.addArrangedSubview(
                makeCard(
                    title: "Gökyüzünde Ek Olay Yok",
                    subtitle: "Bugün ana rehberin Ay burcu enerjisi.",
                    body: "Ayın ritmini takip ederek gününü daha sakin ve bilinçli şekilde yönlendirebilirsin."
                )
            )
            return
        }

        let sectionLabel = UILabel()
        sectionLabel.text = "Gökyüzünde ayrıca"
        sectionLabel.font = .systemFont(ofSize: 22, weight: .bold)
        sectionLabel.textColor = UIColor(hex: "#2D2430")
        sectionLabel.numberOfLines = 0

        stackView.addArrangedSubview(sectionLabel)

        for event in displayData.extraEventInsights {
            stackView.addArrangedSubview(
                makeCard(
                    title: event.title,
                    subtitle: event.subtitle,
                    body: event.content.meaning
                )
            )
        }
    }

    private func makeCard(
        title: String,
        subtitle: String,
        body: String
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel.textColor = UIColor(hex: "#9A7FA3")
        subtitleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        bodyLabel.textColor = UIColor(hex: "#5F5265")
        bodyLabel.numberOfLines = 0

        let innerStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            bodyLabel
        ])
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        innerStack.axis = .vertical
        innerStack.spacing = 8

        card.addSubview(innerStack)

        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            innerStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            innerStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            innerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])

        return card
    }
}
