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
        stackView.spacing = 14
        stackView.alignment = .fill

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])

        addHeaderView()
        addHeroCard()
        addMoonTransitionCard()
        addEnergyCard()
        addGoodForYouCard()
        addDoTodayCard()
        addBeautyCard()
        addHealthDisclaimerCard()
        addRelationshipsCard()
        addAvoidCard()
        addWritingCard()
        // addExtraEvents()
    }
    
    private func addHeaderView() {
        let titleLabel = UILabel()
        titleLabel.text = "Bugünün Gökyüzü"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let subtitleText = "Bugünün enerjisini daha bilinçli kullanman için\nküçük bir rehber."

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5

        let subtitleLabel = UILabel()
        subtitleLabel.attributedText = NSAttributedString(
            string: subtitleText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(hex: "#7D6B83"),
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let headerStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])
        headerStack.axis = .vertical
        headerStack.spacing = 12
        headerStack.alignment = .fill

        stackView.addArrangedSubview(headerStack)
        stackView.setCustomSpacing(32, after: headerStack)
    }
    
    
    private func addHeroCard() {
        let daily = displayData.dailyAstrology

        let card = UIView()
        card.backgroundColor = UIColor(hex: "#EEDCFF")
        card.layer.cornerRadius = 28
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)

        let moonLabel = UILabel()
        moonLabel.text = "☾"
        moonLabel.font = .systemFont(ofSize: 66, weight: .regular)
        moonLabel.textColor = .white
        moonLabel.textAlignment = .center

        let moonCircle = UIView()
        moonCircle.translatesAutoresizingMaskIntoConstraints = false
        moonCircle.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        moonCircle.layer.cornerRadius = 46

        moonCircle.addSubview(moonLabel)
        moonLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            moonCircle.widthAnchor.constraint(equalToConstant: 92),
            moonCircle.heightAnchor.constraint(equalToConstant: 92),

            moonLabel.centerXAnchor.constraint(equalTo: moonCircle.centerXAnchor),
            moonLabel.centerYAnchor.constraint(equalTo: moonCircle.centerYAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Ay \(daily.moonSignDisplay) burcunda"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")
        titleLabel.numberOfLines = 0

        let phaseLabel = UILabel()
        phaseLabel.text = daily.moonPhase
        phaseLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        phaseLabel.textColor = UIColor(hex: "#9B61C9")
        phaseLabel.numberOfLines = 0

        let energyLabel = UILabel()
        energyLabel.text = "Bugünün enerjisi %\(daily.suitabilityScore * 10) seninle"
        energyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        energyLabel.textColor = UIColor(hex: "#66586C")
        energyLabel.numberOfLines = 0

        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = Float(daily.suitabilityScore) / 10.0
        progressView.progressTintColor = UIColor(hex: "#ED4AA7")
        progressView.trackTintColor = UIColor(hex: "#D9C7E5")
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true

        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            phaseLabel,
            energyLabel,
            progressView
        ])
        textStack.axis = .vertical
        textStack.spacing = 9
        textStack.alignment = .fill

        let mainStack = UIStackView(arrangedSubviews: [
            moonCircle,
            textStack
        ])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .horizontal
        mainStack.spacing = 18
        mainStack.alignment = .center

        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),

            progressView.heightAnchor.constraint(equalToConstant: 7)
        ])

        stackView.addArrangedSubview(card)
    }
    
    

//    private func addDailyCommentCard() {
//        let daily = displayData.dailyAstrology
//
//        stackView.addArrangedSubview(
//            makeIconCard(
//                icon: "✦",
//                iconBackgroundColor: UIColor(hex: "#F58AC5"),
//                title: "Günün Mesajı",
//                subtitle: "Kısa gökyüzü yorumu",
//                body: daily.dailyComment,
//                backgroundColor: UIColor.white.withAlphaComponent(0.82),
//                bulletItems: nil,
//                bulletColor: nil
//            )
//        )
//    }
//    private func addMoonSignCard() {
//        guard let insight = displayData.moonSignInsight else {
//            stackView.addArrangedSubview(
//                makeIconCard(
//                    icon: "☾",
//                    iconBackgroundColor: UIColor(hex: "#C89AF5"),
//                    title: "Ay Burcu Yorumu",
//                    subtitle: "Bugünün ay burcu için yorum hazırlanıyor.",
//                    body: "Ay burcu verisi var ancak detay yorumu eşleşmedi.",
//                    backgroundColor: UIColor.white.withAlphaComponent(0.82),
//                    bulletItems: nil,
//                    bulletColor: nil
//                )
//            )
//            return
//        }
//
//        stackView.addArrangedSubview(
//            makeIconCard(
//                icon: moonSymbol(for: displayData.dailyAstrology.moonSign),
//                iconBackgroundColor: UIColor(hex: "#C89AF5"),
//                title: insight.title,
//                subtitle: insight.subtitle,
//                body: insight.content.feeling,
//                backgroundColor: UIColor.white.withAlphaComponent(0.82),
//                bulletItems: nil,
//                bulletColor: nil
//            )
//        )
//    }
//
//
//private func addActionsCard() {
//    guard let insight = displayData.moonSignInsight else { return }
//
//    stackView.addArrangedSubview(
//        makeIconCard(
//            icon: "♡",
//            iconBackgroundColor: UIColor(hex: "#F58AC5"),
//            title: "Bugün sana iyi gelebilecekler",
//            subtitle: nil,
//            body: nil,
//            backgroundColor: UIColor(hex: "#FFF2FA"),
//            bulletItems: insight.content.actions,
//            bulletColor: UIColor(hex: "#ED4AA7")
//        )
//    )
//}
//    private func addAvoidCard() {
//        guard let insight = displayData.moonSignInsight else { return }
//
//        stackView.addArrangedSubview(
//            makeIconCard(
//                icon: "☁︎",
//                iconBackgroundColor: UIColor(hex: "#C89AF5"),
//                title: "Bugün uzak durman iyi olur",
//                subtitle: nil,
//                body: nil,
//                backgroundColor: UIColor(hex: "#F7EFFF"),
//                bulletItems: insight.content.avoid,
//                bulletColor: UIColor(hex: "#A76DE0")
//            )
//        )
//    }
//    private func addRitualCard() {
//        guard let insight = displayData.moonSignInsight else { return }
//
//        stackView.addArrangedSubview(
//            makeIconCard(
//                icon: "✦",
//                iconBackgroundColor: UIColor(hex: "#F58AC5"),
//                title: "Mini ritüel",
//                subtitle: nil,
//                body: insight.content.ritual,
//                backgroundColor: UIColor(hex: "#FFF0F7"),
//                bulletItems: nil,
//                bulletColor: nil
//            )
//        )
//    }
//    private func addBeautyCard() {
//        guard let insight = displayData.moonSignInsight else { return }
//
//        let beautyText = insight.content.beauty.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !beautyText.isEmpty else { return }
//
//        stackView.addArrangedSubview(
//            makeIconCard(
//                icon: "✿",
//                iconBackgroundColor: UIColor(hex: "#F58AC5"),
//                title: "Güzellik önerisi",
//                subtitle: nil,
//                body: beautyText,
//                backgroundColor: UIColor.white.withAlphaComponent(0.82),
//                bulletItems: nil,
//                bulletColor: nil
//            )
//        )
//    }
    
    
    
    private func addMoonTransitionCard() {
        let daily = displayData.dailyAstrology

        guard daily.hasMoonTransition,
              !daily.moonTransitionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "☾",
                iconBackgroundColor: UIColor(hex: "#C89AF5"),
                title: "Ay Geçişi",
                subtitle: daily.moonSignDisplay,
                body: daily.moonTransitionText,
                backgroundColor: UIColor.white.withAlphaComponent(0.82),
                bulletItems: nil,
                bulletColor: nil
            )
        )
    }

    private func addEnergyCard() {
        let sections = displayData.dailyAstrology.sections

        guard !sections.bugununEnerjisi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "✦",
                iconBackgroundColor: UIColor(hex: "#F58AC5"),
                title: "Bugünün Enerjisi",
                subtitle: nil,
                body: sections.bugununEnerjisi,
                backgroundColor: UIColor.white.withAlphaComponent(0.82),
                bulletItems: nil,
                bulletColor: nil
            )
        )
    }

    private func addGoodForYouCard() {
        let sections = displayData.dailyAstrology.sections

        guard !sections.bugunSanaIyiGelebilecekSeyler.isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "♡",
                iconBackgroundColor: UIColor(hex: "#F58AC5"),
                title: "Bugün sana iyi gelebilecekler",
                subtitle: nil,
                body: nil,
                backgroundColor: UIColor(hex: "#FFF2FA"),
                bulletItems: sections.bugunSanaIyiGelebilecekSeyler,
                bulletColor: UIColor(hex: "#ED4AA7")
            )
        )
    }

    private func addDoTodayCard() {
        let sections = displayData.dailyAstrology.sections

        guard !sections.bugunBunlariYapabilirsin.isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "☀︎",
                iconBackgroundColor: UIColor(hex: "#F58AC5"),
                title: "Bugün bunları yapabilirsin",
                subtitle: nil,
                body: nil,
                backgroundColor: UIColor.white.withAlphaComponent(0.82),
                bulletItems: sections.bugunBunlariYapabilirsin,
                bulletColor: UIColor(hex: "#ED4AA7")
            )
        )
    }

    private func addBeautyCard() {
        let beautyText = displayData.dailyAstrology.sections.guzellikBakimOnerisi
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !beautyText.isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "✿",
                iconBackgroundColor: UIColor(hex: "#F58AC5"),
                title: "Güzellik & Bakım Önerisi",
                subtitle: nil,
                body: beautyText,
                backgroundColor: UIColor.white.withAlphaComponent(0.82),
                bulletItems: nil,
                bulletColor: nil
            )
        )
    }

    private func addRelationshipsCard() {
        let relationText = displayData.dailyAstrology.sections.iliskilerdeBugun
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !relationText.isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "☽",
                iconBackgroundColor: UIColor(hex: "#C89AF5"),
                title: "İlişkilerde Bugün",
                subtitle: nil,
                body: relationText,
                backgroundColor: UIColor(hex: "#F7EFFF"),
                bulletItems: nil,
                bulletColor: nil
            )
        )
    }

    private func addAvoidCard() {
        let sections = displayData.dailyAstrology.sections

        guard !sections.uzakDurmanGerekenSeyler.isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "☁︎",
                iconBackgroundColor: UIColor(hex: "#C89AF5"),
                title: "Uzak durman gereken şeyler",
                subtitle: nil,
                body: nil,
                backgroundColor: UIColor(hex: "#F7EFFF"),
                bulletItems: sections.uzakDurmanGerekenSeyler,
                bulletColor: UIColor(hex: "#A76DE0")
            )
        )
    }

    private func addWritingCard() {
        let writingText = displayData.dailyAstrology.sections.yazmaCalismasi
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !writingText.isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "✎",
                iconBackgroundColor: UIColor(hex: "#F58AC5"),
                title: "Yazma Çalışması",
                subtitle: nil,
                body: writingText,
                backgroundColor: UIColor(hex: "#FFF0F7"),
                bulletItems: nil,
                bulletColor: nil
            )
        )
    }

    private func addHealthDisclaimerCard() {
        let disclaimer = displayData.dailyAstrology.healthDisclaimer
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !disclaimer.isEmpty else {
            return
        }

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "!",
                iconBackgroundColor: UIColor(hex: "#C89AF5"),
                title: "Sağlık Notu",
                subtitle: nil,
                body: disclaimer,
                backgroundColor: UIColor.white.withAlphaComponent(0.82),
                bulletItems: nil,
                bulletColor: nil
            )
        )
    }
    
    private func addExtraEvents() {
        guard !displayData.extraEventInsights.isEmpty else {
            return
        }

        let sectionLabel = UILabel()
        sectionLabel.text = "Gökyüzünde ayrıca"
        sectionLabel.font = .systemFont(ofSize: 24, weight: .bold)
        sectionLabel.textColor = UIColor(hex: "#2D2430")
        sectionLabel.numberOfLines = 0

        stackView.addArrangedSubview(sectionLabel)
        stackView.setCustomSpacing(14, after: sectionLabel)

        for event in displayData.extraEventInsights {
            addExtraEventFullDetail(event)
        }
    }
    
    private func addExtraEventFullDetail(_ event: AstroInsightEvent) {
        stackView.addArrangedSubview(
            makeIconCard(
                icon: "☾",
                iconBackgroundColor: UIColor(hex: "#C89AF5"),
                title: event.title,
                subtitle: event.subtitle,
                body: event.content.feeling,
                backgroundColor: UIColor.white.withAlphaComponent(0.82),
                bulletItems: nil,
                bulletColor: nil
            )
        )

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "✧",
                iconBackgroundColor: UIColor(hex: "#C89AF5"),
                title: "Günlük etkisi",
                subtitle: nil,
                body: event.content.effect,
                backgroundColor: UIColor(hex: "#F7EFFF"),
                bulletItems: nil,
                bulletColor: nil
            )
        )

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "✦",
                iconBackgroundColor: UIColor(hex: "#F58AC5"),
                title: "Bu enerjinin anlamı",
                subtitle: nil,
                body: event.content.meaning,
                backgroundColor: UIColor(hex: "#FFF2FA"),
                bulletItems: nil,
                bulletColor: nil
            )
        )

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "♡",
                iconBackgroundColor: UIColor(hex: "#F58AC5"),
                title: "Bu etki sana ne iyi gelir?",
                subtitle: nil,
                body: nil,
                backgroundColor: UIColor.white.withAlphaComponent(0.82),
                bulletItems: event.content.actions,
                bulletColor: UIColor(hex: "#ED4AA7")
            )
        )

        stackView.addArrangedSubview(
            makeIconCard(
                icon: "☁︎",
                iconBackgroundColor: UIColor(hex: "#C89AF5"),
                title: "Bu süreçte dikkat etmen iyi olur",
                subtitle: nil,
                body: nil,
                backgroundColor: UIColor(hex: "#F7EFFF"),
                bulletItems: event.content.avoid,
                bulletColor: UIColor(hex: "#A76DE0")
            )
        )

//        stackView.addArrangedSubview(
//            makeIconCard(
//                icon: "✦",
//                iconBackgroundColor: UIColor(hex: "#F58AC5"),
//                title: "Mini ritüel",
//                subtitle: nil,
//                body: event.content.ritual,
//                backgroundColor: UIColor(hex: "#FFF0F7"),
//                bulletItems: nil,
//                bulletColor: nil
//            )
//        )

        let beautyText = event.content.beauty.trimmingCharacters(in: .whitespacesAndNewlines)

        if !beautyText.isEmpty {
            stackView.addArrangedSubview(
                makeIconCard(
                    icon: "✿",
                    iconBackgroundColor: UIColor(hex: "#F58AC5"),
                    title: "Güzellik önerisi",
                    subtitle: nil,
                    body: beautyText,
                    backgroundColor: UIColor.white.withAlphaComponent(0.82),
                    bulletItems: nil,
                    bulletColor: nil
                )
            )
        }

        addExtraEventDivider()
    }
    
    private func addExtraEventDivider() {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        divider.layer.cornerRadius = 1

        stackView.addArrangedSubview(divider)

        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 2)
        ])

        stackView.setCustomSpacing(22, after: divider)
    }


    private func makeIconCard(
        icon: String,
        iconBackgroundColor: UIColor,
        title: String,
        subtitle: String?,
        body: String?,
        backgroundColor: UIColor,
        bulletItems: [String]?,
        bulletColor: UIColor?
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = backgroundColor
        card.layer.cornerRadius = 24
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.04
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 5)

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = iconBackgroundColor
        iconContainer.layer.cornerRadius = 26

        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 28, weight: .regular)
        iconLabel.textColor = .white
        iconLabel.textAlignment = .center

        iconContainer.addSubview(iconLabel)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 52),
            iconContainer.heightAnchor.constraint(equalToConstant: 52),

            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")
        titleLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.alignment = .fill

        if let subtitle, !subtitle.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            subtitleLabel.textColor = UIColor(hex: "#A05ACB")
            subtitleLabel.numberOfLines = 0
            textStack.addArrangedSubview(subtitleLabel)
        }

        if let body, !body.isEmpty {
            let bodyLabel = UILabel()
            bodyLabel.text = body
            bodyLabel.font = .systemFont(ofSize: 15, weight: .medium)
            bodyLabel.textColor = UIColor(hex: "#5F5265")
            bodyLabel.numberOfLines = 0
            bodyLabel.setLineSpacing(4)
            textStack.addArrangedSubview(bodyLabel)
        }

        if let bulletItems, !bulletItems.isEmpty {
            let bulletStack = makeBulletStack(
                items: bulletItems,
                bulletColor: bulletColor ?? UIColor(hex: "#ED4AA7")
            )
            textStack.addArrangedSubview(bulletStack)
        }

        let mainStack = UIStackView(arrangedSubviews: [
            iconContainer,
            textStack
        ])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .horizontal
        mainStack.spacing = 14
        mainStack.alignment = .top

        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])

        return card
    }
    
    private func makeBulletStack(
        items: [String],
        bulletColor: UIColor
    ) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 7
        stack.alignment = .fill

        for item in items {
            let bulletLabel = UILabel()
            bulletLabel.text = "•"
            bulletLabel.font = .systemFont(ofSize: 19, weight: .bold)
            bulletLabel.textColor = bulletColor
            bulletLabel.setContentHuggingPriority(.required, for: .horizontal)

            let itemLabel = UILabel()
            itemLabel.text = item
            itemLabel.font = .systemFont(ofSize: 15, weight: .medium)
            itemLabel.textColor = UIColor(hex: "#5F5265")
            itemLabel.numberOfLines = 0

            let rowStack = UIStackView(arrangedSubviews: [
                bulletLabel,
                itemLabel
            ])
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.alignment = .top

            stack.addArrangedSubview(rowStack)
        }

        return stack
    }
    private func moonSymbol(for moonSign: String) -> String {
        let normalized = moonSign
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        switch normalized {
        case "koç", "koc", "aries":
            return "♈︎"
        case "boğa", "boga", "taurus":
            return "♉︎"
        case "ikizler", "gemini":
            return "♊︎"
        case "yengeç", "yengec", "cancer":
            return "♋︎"
        case "aslan", "leo":
            return "♌︎"
        case "başak", "basak", "virgo":
            return "♍︎"
        case "terazi", "libra":
            return "♎︎"
        case "akrep", "scorpio":
            return "♏︎"
        case "yay", "sagittarius":
            return "♐︎"
        case "oğlak", "oglak", "capricorn":
            return "♑︎"
        case "kova", "aquarius":
            return "♒︎"
        case "balık", "balik", "pisces":
            return "♓︎"
        default:
            return "☾"
        }
    }
}

private extension UILabel {
    func setLineSpacing(_ spacing: CGFloat) {
        guard let text = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        self.attributedText = attributedString
    }
}
