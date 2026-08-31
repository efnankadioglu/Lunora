//
//  UpcomingAstroEventDetailSheetViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.08.2026.
//

import UIKit

final class UpcomingAstroEventDetailSheetViewController:
    UIViewController {

    private let event: UpcomingAstroEvent

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    init(event: UpcomingAstroEvent) {
        self.event = event
        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor =
            UIColor(hex: "#FDEAF5")

        setupLayout()
        setupContent()
    }

    // MARK: - Layout

    private func setupLayout() {

        scrollView
            .translatesAutoresizingMaskIntoConstraints =
            false

        contentView
            .translatesAutoresizingMaskIntoConstraints =
            false

        stackView
            .translatesAutoresizingMaskIntoConstraints =
            false

        scrollView
            .showsVerticalScrollIndicator =
            false

        stackView.axis =
            .vertical

        stackView.spacing =
            16

        view.addSubview(
            scrollView
        )

        scrollView.addSubview(
            contentView
        )

        contentView.addSubview(
            stackView
        )

        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(
                equalTo:
                    view.topAnchor
            ),

            scrollView.leadingAnchor.constraint(
                equalTo:
                    view.leadingAnchor
            ),

            scrollView.trailingAnchor.constraint(
                equalTo:
                    view.trailingAnchor
            ),

            scrollView.bottomAnchor.constraint(
                equalTo:
                    view.bottomAnchor
            ),

            contentView.topAnchor.constraint(
                equalTo:
                    scrollView
                    .contentLayoutGuide
                    .topAnchor
            ),

            contentView.leadingAnchor.constraint(
                equalTo:
                    scrollView
                    .contentLayoutGuide
                    .leadingAnchor
            ),

            contentView.trailingAnchor.constraint(
                equalTo:
                    scrollView
                    .contentLayoutGuide
                    .trailingAnchor
            ),

            contentView.bottomAnchor.constraint(
                equalTo:
                    scrollView
                    .contentLayoutGuide
                    .bottomAnchor
            ),

            contentView.widthAnchor.constraint(
                equalTo:
                    scrollView
                    .frameLayoutGuide
                    .widthAnchor
            ),

            stackView.topAnchor.constraint(
                equalTo:
                    contentView.topAnchor,
                constant: 24
            ),

            stackView.leadingAnchor.constraint(
                equalTo:
                    contentView.leadingAnchor,
                constant: 20
            ),

            stackView.trailingAnchor.constraint(
                equalTo:
                    contentView.trailingAnchor,
                constant: -20
            ),

            stackView.bottomAnchor.constraint(
                equalTo:
                    contentView.bottomAnchor,
                constant: -40
            )
        ])
    }

    // MARK: - Content

    private func setupContent() {

        addHeader()

        addSectionCard(
            title:
                "Bu dönem sana ne anlatabilir?",
            body:
                event
                .content
                .display
                .detail
        )

        addActionsCard()

        addSectionCard(
            title:
                "Aklında olsun",
            body:
                event
                .content
                .display
                .keepInMind
        )

        addReflectionCard()
    }

    // MARK: - Header

    private func addHeader() {

        let accent =
            accentColor(
                for: event.key
            )

        let iconCircle =
            UIView()

        iconCircle
            .translatesAutoresizingMaskIntoConstraints =
            false

        iconCircle.backgroundColor =
            accent.withAlphaComponent(
                0.13
            )

        iconCircle.layer.cornerRadius =
            30

        let iconLabel =
            UILabel()

        iconLabel
            .translatesAutoresizingMaskIntoConstraints =
            false

        iconLabel.text =
            glyph(
                for: event.key
            )

        iconLabel.font =
            .systemFont(
                ofSize: 28,
                weight: .medium
            )

        iconLabel.textAlignment =
            .center

        iconLabel.textColor =
            accent

        iconCircle.addSubview(
            iconLabel
        )

        NSLayoutConstraint.activate([

            iconCircle.widthAnchor.constraint(
                equalToConstant: 60
            ),

            iconCircle.heightAnchor.constraint(
                equalToConstant: 60
            ),

            iconLabel.centerXAnchor.constraint(
                equalTo:
                    iconCircle.centerXAnchor
            ),

            iconLabel.centerYAnchor.constraint(
                equalTo:
                    iconCircle.centerYAnchor
            )
        ])

        let titleLabel =
            UILabel()

        titleLabel.text =
            event
            .content
            .display
            .title

        titleLabel.font =
            .systemFont(
                ofSize: 27,
                weight: .bold
            )

        titleLabel.textColor =
            UIColor(hex: "#2D2430")

        titleLabel
            .numberOfLines =
            0

        let dateLabel =
            UILabel()

        dateLabel.text =
            dateText()

        dateLabel.font =
            .systemFont(
                ofSize: 15,
                weight: .semibold
            )

        dateLabel.textColor =
            accent

        let titleStack =
            UIStackView(
                arrangedSubviews: [
                    titleLabel,
                    dateLabel
                ]
            )

        titleStack.axis =
            .vertical

        titleStack.spacing =
            5

        let topStack =
            UIStackView(
                arrangedSubviews: [
                    iconCircle,
                    titleStack
                ]
            )

        topStack.axis =
            .horizontal

        topStack.alignment =
            .center

        topStack.spacing =
            15

        stackView.addArrangedSubview(
            topStack
        )

        let themesLabel =
            UILabel()

        themesLabel.text =
            event
            .content
            .display
            .themes
            .joined(
                separator: "  •  "
            )

        themesLabel.font =
            .systemFont(
                ofSize: 14,
                weight: .semibold
            )

        themesLabel.textColor =
            UIColor(hex: "#8A728E")

        themesLabel
            .numberOfLines =
            0

        stackView.addArrangedSubview(
            themesLabel
        )

        let previewLabel =
            UILabel()

        previewLabel.text =
            event
            .content
            .display
            .preview

        previewLabel.font =
            .systemFont(
                ofSize: 16,
                weight: .medium
            )

        previewLabel.textColor =
            UIColor(hex: "#4B3C4E")

        previewLabel
            .numberOfLines =
            0

        previewLabel
            .lineBreakMode =
            .byWordWrapping

        stackView.addArrangedSubview(
            previewLabel
        )

        stackView.setCustomSpacing(
            24,
            after: previewLabel
        )
    }

    // MARK: - Text Section

    private func addSectionCard(
        title: String,
        body: String
    ) {

        let card =
            UIView()

        card.backgroundColor =
            UIColor.white
            .withAlphaComponent(
                0.88
            )

        card.layer.cornerRadius =
            22

        let titleLabel =
            UILabel()

        titleLabel.text =
            title

        titleLabel.font =
            .systemFont(
                ofSize: 17,
                weight: .bold
            )

        titleLabel.textColor =
            UIColor(hex: "#2D2430")

        let bodyLabel =
            UILabel()

        bodyLabel.text =
            body

        bodyLabel.font =
            .systemFont(
                ofSize: 15.5,
                weight: .regular
            )

        bodyLabel.textColor =
            UIColor(hex: "#5F5262")

        bodyLabel
            .numberOfLines =
            0

        let innerStack =
            UIStackView(
                arrangedSubviews: [
                    titleLabel,
                    bodyLabel
                ]
            )

        innerStack
            .translatesAutoresizingMaskIntoConstraints =
            false

        innerStack.axis =
            .vertical

        innerStack.spacing =
            9

        card.addSubview(
            innerStack
        )

        NSLayoutConstraint.activate([

            innerStack.topAnchor.constraint(
                equalTo:
                    card.topAnchor,
                constant: 18
            ),

            innerStack.leadingAnchor.constraint(
                equalTo:
                    card.leadingAnchor,
                constant: 18
            ),

            innerStack.trailingAnchor.constraint(
                equalTo:
                    card.trailingAnchor,
                constant: -18
            ),

            innerStack.bottomAnchor.constraint(
                equalTo:
                    card.bottomAnchor,
                constant: -18
            )
        ])

        stackView.addArrangedSubview(
            card
        )
    }

    // MARK: - Actions

    private func addActionsCard() {

        let accent =
            accentColor(
                for: event.key
            )

        let card =
            UIView()

        card.backgroundColor =
            accent.withAlphaComponent(
                0.08
            )

        card.layer.cornerRadius =
            22

        let titleLabel =
            UILabel()

        titleLabel.text =
            event
            .content
            .display
            .actionTitle

        titleLabel.font =
            .systemFont(
                ofSize: 17,
                weight: .bold
            )

        titleLabel.textColor =
            UIColor(hex: "#2D2430")

        let actionsStack =
            UIStackView()

        actionsStack.axis =
            .vertical

        actionsStack.spacing =
            11

        for action
        in event
            .content
            .display
            .actions {

            let bulletLabel =
                UILabel()

            bulletLabel.text =
                "✦"

            bulletLabel.font =
                .systemFont(
                    ofSize: 14,
                    weight: .bold
                )

            bulletLabel.textColor =
                accent

            bulletLabel
                .setContentHuggingPriority(
                    .required,
                    for: .horizontal
                )

            let textLabel =
                UILabel()

            textLabel.text =
                action

            textLabel.font =
                .systemFont(
                    ofSize: 15.5,
                    weight: .regular
                )

            textLabel.textColor =
                UIColor(hex: "#554858")

            textLabel
                .numberOfLines =
                0

            let row =
                UIStackView(
                    arrangedSubviews: [
                        bulletLabel,
                        textLabel
                    ]
                )

            row.axis =
                .horizontal

            row.alignment =
                .top

            row.spacing =
                10

            actionsStack
                .addArrangedSubview(
                    row
                )
        }

        let innerStack =
            UIStackView(
                arrangedSubviews: [
                    titleLabel,
                    actionsStack
                ]
            )

        innerStack
            .translatesAutoresizingMaskIntoConstraints =
            false

        innerStack.axis =
            .vertical

        innerStack.spacing =
            13

        card.addSubview(
            innerStack
        )

        NSLayoutConstraint.activate([

            innerStack.topAnchor.constraint(
                equalTo:
                    card.topAnchor,
                constant: 18
            ),

            innerStack.leadingAnchor.constraint(
                equalTo:
                    card.leadingAnchor,
                constant: 18
            ),

            innerStack.trailingAnchor.constraint(
                equalTo:
                    card.trailingAnchor,
                constant: -18
            ),

            innerStack.bottomAnchor.constraint(
                equalTo:
                    card.bottomAnchor,
                constant: -18
            )
        ])

        stackView.addArrangedSubview(
            card
        )
    }

    // MARK: - Reflection

    private func addReflectionCard() {

        let accent =
            accentColor(
                for: event.key
            )

        let card =
            UIView()

        card.backgroundColor =
            UIColor(hex: "#FFF4FA")

        card.layer.cornerRadius =
            22

        card.layer.borderWidth =
            1

        card.layer.borderColor =
            accent
            .withAlphaComponent(
                0.15
            )
            .cgColor

        let eyebrowLabel =
            UILabel()

        eyebrowLabel.text =
            "KENDİNE SOR"

        eyebrowLabel.font =
            .systemFont(
                ofSize: 12,
                weight: .bold
            )

        eyebrowLabel.textColor =
            accent

        let questionLabel =
            UILabel()

        questionLabel.text =
            event
            .content
            .display
            .reflectionQuestion

        questionLabel.font =
            .systemFont(
                ofSize: 18,
                weight: .semibold
            )

        questionLabel.textColor =
            UIColor(hex: "#3D303F")

        questionLabel
            .numberOfLines =
            0

        let innerStack =
            UIStackView(
                arrangedSubviews: [
                    eyebrowLabel,
                    questionLabel
                ]
            )

        innerStack
            .translatesAutoresizingMaskIntoConstraints =
            false

        innerStack.axis =
            .vertical

        innerStack.spacing =
            8

        card.addSubview(
            innerStack
        )

        NSLayoutConstraint.activate([

            innerStack.topAnchor.constraint(
                equalTo:
                    card.topAnchor,
                constant: 19
            ),

            innerStack.leadingAnchor.constraint(
                equalTo:
                    card.leadingAnchor,
                constant: 18
            ),

            innerStack.trailingAnchor.constraint(
                equalTo:
                    card.trailingAnchor,
                constant: -18
            ),

            innerStack.bottomAnchor.constraint(
                equalTo:
                    card.bottomAnchor,
                constant: -19
            )
        ])

        stackView.addArrangedSubview(
            card
        )
    }

    // MARK: - Date

    private func dateText()
    -> String {

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "tr_TR"
            )

        formatter.timeZone =
            TimeZone(
                identifier:
                    "Europe/Istanbul"
            )

        formatter.dateFormat =
            "d MMMM"

        let date =
            formatter.string(
                from: event.date
            )

        let prefix: String

        switch event.daysRemaining {

        case 0:
            prefix =
                "Bugün"

        case 1:
            prefix =
                "Yarın"

        default:
            prefix =
                "\(event.daysRemaining) gün sonra"
        }

        return
            "\(prefix)  •  \(date)"
    }

    // MARK: - Visual Helpers

    private func glyph(
        for key: String
    ) -> String {

        switch key {

        case "mercury_retrograde":
            return "☿"

        case "venus_retrograde":
            return "♀"

        case "mars_retrograde":
            return "♂"

        case "new_moon":
            return "●"

        case "full_moon":
            return "○"

        case "solar_eclipse":
            return "◐"

        case "lunar_eclipse":
            return "◑"

        default:
            return "✧"
        }
    }

    private func accentColor(
        for key: String
    ) -> UIColor {

        switch key {

        case "venus_retrograde":
            return
                UIColor(hex: "#E971AE")

        case "mars_retrograde":
            return
                UIColor(hex: "#D77B82")

        case "mercury_retrograde":
            return
                UIColor(hex: "#9873D4")

        case "new_moon":
            return
                UIColor(hex: "#876BBF")

        case "full_moon":
            return
                UIColor(hex: "#B383C7")

        case "solar_eclipse",
             "lunar_eclipse":
            return
                UIColor(hex: "#7359A6")

        default:
            return
                UIColor(hex: "#9A78CC")
        }
    }
}
