//
//  BeautyDetailSheetViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 22.08.2026.
//

import UIKit

// MARK: - UI Model

struct BeautyDetailItem {
    let category: String
    let status: String
    let startAt: String?
    let endAt: String?
    let displayText: String
    let goals: [String]

    static func make(
        from value: Any,
        displayText: String
    ) -> BeautyDetailItem {

        BeautyDetailItem(
            category: BeautyValueReader.string(
                in: value,
                keys: ["category"]
            ) ?? "",
            status: BeautyValueReader.string(
                in: value,
                keys: ["recommendation"]
            ) ?? "recommended",
            startAt: BeautyValueReader.string(
                in: value,
                keys: ["startAt", "start_at"]
            ),
            endAt: BeautyValueReader.string(
                in: value,
                keys: ["endAt", "end_at"]
            ),
            displayText: displayText,
            goals: BeautyValueReader.stringArray(
                in: value,
                keys: ["traditionalGoals", "traditional_goals"]
            )
        )
    }
}


// MARK: - Detail Sheet

final class BeautyDetailSheetViewController: UIViewController {

    private let items: [BeautyDetailItem]

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    init(items: [BeautyDetailItem]) {
        self.items = items.sorted {
            BeautyUI.priority(for: $0.status) <
            BeautyUI.priority(for: $1.status)
        }

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        scrollView.translatesAutoresizingMaskIntoConstraints =
            false

        contentView.translatesAutoresizingMaskIntoConstraints =
            false

        stackView.translatesAutoresizingMaskIntoConstraints =
            false

        scrollView.showsVerticalScrollIndicator =
            false

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),

            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),

            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),

            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),

            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),

            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),

            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 20
            ),

            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -32
            )
        ])
    }


    // MARK: - Content

    private func setupContent() {

        addHeader()

        let especially = items.filter {
            $0.status == "especially_recommended"
        }

        let recommended = items.filter {
            $0.status == "recommended"
        }

        let caution = items.filter {
            $0.status == "not_recommended"
        }

        if !especially.isEmpty {
            addSection(
                title: "Özellikle Uygun",
                symbol: "sparkles",
                color: UIColor(hex: "#D94F93"),
                items: especially
            )
        }

        if !recommended.isEmpty {
            addSection(
                title: "Bugün Uygun",
                symbol: "checkmark.circle.fill",
                color: UIColor(hex: "#62835B"),
                items: recommended
            )
        }

        if !caution.isEmpty {
            addSection(
                title: "Dikkat",
                symbol: "exclamationmark.triangle.fill",
                color: UIColor(hex: "#C9782E"),
                items: caution
            )
        }
    }


    private func addHeader() {

        let iconView = UIImageView(
            image: UIImage(systemName: "sparkles")
        )

        iconView.translatesAutoresizingMaskIntoConstraints =
            false

        iconView.tintColor =
            UIColor(hex: "#D94F93")

        iconView.contentMode =
            .scaleAspectFit

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(
                equalToConstant: 26
            ),
            iconView.heightAnchor.constraint(
                equalToConstant: 26
            )
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Güzellik & Bakım"
        titleLabel.font = .systemFont(
            ofSize: 28,
            weight: .bold
        )
        titleLabel.textColor =
            UIColor(hex: "#2D2430")
        titleLabel.numberOfLines = 0

        let titleRow = UIStackView(
            arrangedSubviews: [
                iconView,
                titleLabel
            ]
        )

        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 10

        let subtitleLabel = UILabel()
        subtitleLabel.text =
            "Bugünün gökyüzüne göre öne çıkan bakım zamanları"
        subtitleLabel.font = .systemFont(
            ofSize: 15,
            weight: .medium
        )
        subtitleLabel.textColor =
            UIColor(hex: "#7D6B83")
        subtitleLabel.numberOfLines = 0

        let positiveCount =
            items.filter {
                $0.status != "not_recommended"
            }.count

        let cautionCount =
            items.filter {
                $0.status == "not_recommended"
            }.count

        let summaryLabel = UILabel()

        if cautionCount > 0 {
            summaryLabel.text =
                "\(positiveCount) öneri  •  \(cautionCount) dikkat"
        } else {
            summaryLabel.text =
                "\(positiveCount) öneri"
        }

        summaryLabel.font = .systemFont(
            ofSize: 14,
            weight: .semibold
        )

        summaryLabel.textColor =
            UIColor(hex: "#9E4F78")

        summaryLabel.backgroundColor =
            UIColor(hex: "#FBE7F1")

        summaryLabel.layer.cornerRadius =
            14

        summaryLabel.layer.masksToBounds =
            true

        summaryLabel.textAlignment =
            .center

        summaryLabel.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([
            summaryLabel.heightAnchor.constraint(
                equalToConstant: 32
            )
        ])

        let headerStack = UIStackView(
            arrangedSubviews: [
                titleRow,
                subtitleLabel,
                summaryLabel
            ]
        )

        headerStack.axis = .vertical
        headerStack.spacing = 10

        stackView.addArrangedSubview(
            headerStack
        )

        stackView.setCustomSpacing(
            22,
            after: headerStack
        )
    }


    // MARK: - Section

    private func addSection(
        title: String,
        symbol: String,
        color: UIColor,
        items: [BeautyDetailItem]
    ) {

        let sectionTitleIcon =
            UIImageView(
                image: UIImage(
                    systemName: symbol
                )
            )

        sectionTitleIcon.translatesAutoresizingMaskIntoConstraints =
            false

        sectionTitleIcon.tintColor =
            color

        NSLayoutConstraint.activate([
            sectionTitleIcon.widthAnchor.constraint(
                equalToConstant: 19
            ),
            sectionTitleIcon.heightAnchor.constraint(
                equalToConstant: 19
            )
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(
            ofSize: 18,
            weight: .bold
        )
        titleLabel.textColor = color

        let sectionHeader = UIStackView(
            arrangedSubviews: [
                sectionTitleIcon,
                titleLabel
            ]
        )

        sectionHeader.axis = .horizontal
        sectionHeader.alignment = .center
        sectionHeader.spacing = 8

        stackView.addArrangedSubview(
            sectionHeader
        )

        let group = UIStackView()
        group.axis = .vertical
        group.spacing = 9

        for item in items {
            group.addArrangedSubview(
                makeRecommendationCard(
                    item
                )
            )
        }

        stackView.addArrangedSubview(
            group
        )

        stackView.setCustomSpacing(
            22,
            after: group
        )
    }


    // MARK: - Card

    private func makeRecommendationCard(
        _ item: BeautyDetailItem
    ) -> UIView {

        let accent =
            BeautyUI.accent(
                for: item.status
            )

        let card = UIView()

        card.backgroundColor =
            BeautyUI.background(
                for: item.status
            )

        card.layer.cornerRadius =
            20

        if item.status ==
            "especially_recommended" {

            card.layer.borderWidth = 1

            card.layer.borderColor =
                accent
                    .withAlphaComponent(0.22)
                    .cgColor
        }

        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints =
            false

        iconCircle.backgroundColor =
            accent.withAlphaComponent(0.12)

        iconCircle.layer.cornerRadius =
            23

        let imageView = UIImageView(
            image: UIImage(
                systemName:
                    BeautyUI.symbolName(
                        for: item.category
                    )
            )
        )

        imageView.translatesAutoresizingMaskIntoConstraints =
            false

        imageView.tintColor =
            accent

        imageView.contentMode =
            .scaleAspectFit

        iconCircle.addSubview(
            imageView
        )

        NSLayoutConstraint.activate([

            iconCircle.widthAnchor.constraint(
                equalToConstant: 46
            ),

            iconCircle.heightAnchor.constraint(
                equalToConstant: 46
            ),

            imageView.centerXAnchor.constraint(
                equalTo: iconCircle.centerXAnchor
            ),

            imageView.centerYAnchor.constraint(
                equalTo: iconCircle.centerYAnchor
            ),

            imageView.widthAnchor.constraint(
                equalToConstant: 22
            ),

            imageView.heightAnchor.constraint(
                equalToConstant: 22
            )
        ])

        let titleLabel = UILabel()

        titleLabel.text =
            BeautyUI.title(
                for: item.category
            )

        titleLabel.font =
            .systemFont(
                ofSize: 17,
                weight: .semibold
            )

        titleLabel.textColor =
            UIColor(hex: "#2D2430")

        titleLabel.numberOfLines =
            0

        let timeLabel = UILabel()

        timeLabel.text =
            BeautyUI.timeText(
                startAt: item.startAt,
                endAt: item.endAt,
                displayText:
                    item.displayText
            )

        timeLabel.font =
            .systemFont(
                ofSize: 14,
                weight: .semibold
            )

        timeLabel.textColor =
            accent

        let bodyLabel = UILabel()

        bodyLabel.text =
            BeautyUI.bodyText(
                item.displayText
            )

        bodyLabel.font =
            .systemFont(
                ofSize: 15,
                weight: .regular
            )

        bodyLabel.textColor =
            UIColor(hex: "#665A69")

        bodyLabel.numberOfLines =
            0

        let textStack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                timeLabel,
                bodyLabel
            ]
        )

        textStack.axis =
            .vertical

        textStack.spacing =
            5

        if !item.goals.isEmpty {

            let goalText =
                item.goals
                    .map(
                        BeautyUI.goalText
                    )
                    .joined(
                        separator: "  •  "
                    )

            textStack.addArrangedSubview(
                makeGoalPill(
                    text: goalText,
                    accent: accent
                )
            )
        }

        let row = UIStackView(
            arrangedSubviews: [
                iconCircle,
                textStack
            ]
        )

        row.translatesAutoresizingMaskIntoConstraints =
            false

        row.axis =
            .horizontal

        row.alignment =
            .top

        row.spacing =
            12

        card.addSubview(
            row
        )

        NSLayoutConstraint.activate([

            row.topAnchor.constraint(
                equalTo: card.topAnchor,
                constant: 15
            ),

            row.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 15
            ),

            row.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -15
            ),

            row.bottomAnchor.constraint(
                equalTo: card.bottomAnchor,
                constant: -15
            )
        ])

        return card
    }


    private func makeGoalPill(
        text: String,
        accent: UIColor
    ) -> UIView {

        let container = UIView()

        container.backgroundColor =
            accent.withAlphaComponent(0.09)

        container.layer.cornerRadius =
            11

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints =
            false

        label.text =
            text

        label.font =
            .systemFont(
                ofSize: 12.5,
                weight: .medium
            )

        label.textColor =
            accent

        label.numberOfLines =
            0

        container.addSubview(
            label
        )

        NSLayoutConstraint.activate([

            label.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 6
            ),

            label.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -6
            ),

            label.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 10
            ),

            label.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -10
            )
        ])

        return container
    }
}


// MARK: - Shared Beauty Formatting

enum BeautyUI {

    static func priority(
        for status: String
    ) -> Int {

        switch status {

        case "especially_recommended":
            return 0

        case "recommended":
            return 1

        case "not_recommended":
            return 2

        default:
            return 3
        }
    }


    static func title(
        for category: String
    ) -> String {

        switch category {

        case "skincare":
            return "Cilt Bakımı"

        case "epilation":
            return "Epilasyon"

        case "hair_lightening":
            return "Saç Rengi Açma"

        case "hair_cut":
            return "Saç Kesimi"

        case "hair_perm":
            return "Perma"

        case "nail_care":
            return "Tırnak Bakımı"

        case "hair_dye":
            return "Saç Boyama"

        case "massage":
            return "Masaj"

        default:
            return "Bakım Önerisi"
        }
    }


    static func symbolName(
        for category: String
    ) -> String {

        switch category {

        case "skincare":
            return "drop"

        case "epilation":
            return "sparkles"

        case "hair_lightening":
            return "paintbrush"

        case "hair_cut":
            return "scissors"

        case "hair_perm":
            return "waveform.path"

        case "nail_care":
            return "hand.raised"

        case "hair_dye":
            return "paintpalette"

        case "massage":
            return "heart"

        default:
            return "sparkles"
        }
    }


    static func accent(
        for status: String
    ) -> UIColor {

        switch status {

        case "especially_recommended":
            return UIColor(hex: "#D94F93")

        case "not_recommended":
            return UIColor(hex: "#C9782E")

        default:
            return UIColor(hex: "#62835B")
        }
    }


    static func background(
        for status: String
    ) -> UIColor {

        switch status {

        case "especially_recommended":
            return UIColor(hex: "#FFF0F7")

        case "not_recommended":
            return UIColor(hex: "#FFF7EF")

        default:
            return UIColor(hex: "#F6FAF4")
        }
    }


    static func goalText(
        _ goal: String
    ) -> String {

        switch goal {

        case "better_color_result":
            return "Daha dengeli renk sonucu"

        case "fuller_appearance":
            return "Daha dolgun görünüm"

        case "longer_lasting_nail_care":
            return "Daha uzun süre kalıcı bakım"

        case "longer_shape_retention":
            return "Formunu daha uzun koruma"

        case "renewing_care":
            return "Yenileyici bakım"

        case "slower_regrowth":
            return "Daha yavaş yeniden uzama"

        default:
            return goal
                .replacingOccurrences(
                    of: "_",
                    with: " "
                )
        }
    }


    // Compatibility overload:
    // DailySkyV2ViewController currently calls timeText(startAt:endAt:).
    static func timeText(
        startAt: String?,
        endAt: String?
    ) -> String {
        timeText(
            startAt: startAt,
            endAt: endAt,
            displayText: ""
        )
    }


    static func timeText(
        startAt: String?,
        endAt: String?,
        displayText: String
    ) -> String {

        // display_text doğal Türkçe saat içeriyorsa
        // onu öncelikli kullan.
        let patterns = [
            #"^(\d{2}:\d{2}'(?:den|dan|ten|tan) sonra)"#,
            #"^(\d{2}:\d{2}'(?:e|a|ye|ya) kadar)"#
        ]

        for pattern in patterns {

            if let regex =
                try? NSRegularExpression(
                    pattern: pattern
                ),

               let match =
                regex.firstMatch(
                    in: displayText,
                    range: NSRange(
                        displayText.startIndex...,
                        in: displayText
                    )
                ),

               let range =
                Range(
                    match.range(at: 1),
                    in: displayText
                ) {

                return String(
                    displayText[range]
                )
            }
        }

        guard
            let startAt,
            let endAt,
            let start =
                ISO8601DateFormatter()
                    .date(
                        from: startAt
                    ),
            let end =
                ISO8601DateFormatter()
                    .date(
                        from: endAt
                    )
        else {
            return "Bugün"
        }

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                identifier:
                    "Europe/Istanbul"
            ) ?? .current

        let startComponents =
            calendar.dateComponents(
                [.hour, .minute],
                from: start
            )

        let endComponents =
            calendar.dateComponents(
                [.hour, .minute],
                from: end
            )

        let startsAtMidnight =
            startComponents.hour == 0 &&
            startComponents.minute == 0

        let endsAtMidnight =
            endComponents.hour == 0 &&
            endComponents.minute == 0

        if startsAtMidnight &&
            endsAtMidnight {

            return "Tüm gün"
        }

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "tr_TR"
            )

        formatter.timeZone =
            calendar.timeZone

        formatter.dateFormat =
            "HH:mm"

        if startsAtMidnight {

            return
                "\(formatter.string(from: end))'e kadar"
        }

        if endsAtMidnight {

            return
                "\(formatter.string(from: start))'den sonra"
        }

        return
            "\(formatter.string(from: start))–\(formatter.string(from: end))"
    }


    static func bodyText(
        _ displayText: String
    ) -> String {

        let patterns = [
            #"^\d{2}:\d{2}'(?:den|dan|ten|tan) sonra\s*"#,
            #"^\d{2}:\d{2}'(?:e|a|ye|ya) kadar\s*"#
        ]

        var result =
            displayText

        for pattern in patterns {

            if let regex =
                try? NSRegularExpression(
                    pattern: pattern
                ) {

                result =
                    regex
                        .stringByReplacingMatches(
                            in: result,
                            range: NSRange(
                                result.startIndex...,
                                in: result
                            ),
                            withTemplate: ""
                        )
            }
        }

        result =
            result.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        guard let first =
            result.first
        else {
            return displayText
        }

        return
            first.uppercased() +
            String(
                result.dropFirst()
            )
    }
}


// MARK: - Reflection Reader
//
// Beauty modelinin gerçek Swift type adından bağımsız.
// JSON modelin startAt / start_at gibi hangi isimle
// decode edilirse edilsin UI tarafı çalışabilsin diye kullanılıyor.

private enum BeautyValueReader {

    static func string(
        in value: Any,
        keys: [String]
    ) -> String? {

        for key in keys {

            if let raw =
                reflectedValue(
                    in: value,
                    key: key
                ),

               let unwrapped =
                unwrapOptional(
                    raw
                ) as? String {

                return unwrapped
            }
        }

        return nil
    }


    static func stringArray(
        in value: Any,
        keys: [String]
    ) -> [String] {

        for key in keys {

            guard
                let raw =
                    reflectedValue(
                        in: value,
                        key: key
                    ),

                let unwrapped =
                    unwrapOptional(
                        raw
                    )
            else {
                continue
            }

            if let strings =
                unwrapped as? [String] {

                return strings
            }

            let mirror =
                Mirror(
                    reflecting:
                        unwrapped
                )

            let strings =
                mirror.children
                    .compactMap {
                        unwrapOptional(
                            $0.value
                        ) as? String
                    }

            if !strings.isEmpty {
                return strings
            }
        }

        return []
    }


    private static func reflectedValue(
        in value: Any,
        key: String
    ) -> Any? {

        var mirror: Mirror? =
            Mirror(
                reflecting: value
            )

        while let current =
            mirror {

            for child
                in current.children
                where child.label == key {

                return child.value
            }

            mirror =
                current
                    .superclassMirror
        }

        return nil
    }


    private static func unwrapOptional(
        _ value: Any
    ) -> Any? {

        let mirror =
            Mirror(
                reflecting: value
            )

        guard
            mirror.displayStyle ==
                .optional
        else {
            return value
        }

        return
            mirror.children
                .first?
                .value
    }
}
