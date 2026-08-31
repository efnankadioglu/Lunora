//
//  RelationshipDetailSheetViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 22.08.2026.
//

import UIKit

final class RelationshipDetailSheetViewController: UIViewController {

    private let relationships: RelationshipInterpretation

    init(relationships: RelationshipInterpretation) {
        self.relationships = relationships

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor =
            UIColor(hex: "#FFF9FC")

        setupUI()
    }


    private func setupUI() {

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false


        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false


        // MARK: - Icon

        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor =
            UIColor(hex: "#FBE0F0")
        iconCircle.layer.cornerRadius = 28


        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = "♡"
        iconLabel.font = .systemFont(
            ofSize: 31,
            weight: .medium
        )
        iconLabel.textColor =
            UIColor(hex: "#F05FAF")
        iconLabel.textAlignment = .center

        iconCircle.addSubview(iconLabel)


        // MARK: - Title

        let titleLabel = UILabel()
        titleLabel.text =
            relationships.general.title

        titleLabel.font = .systemFont(
            ofSize: 25,
            weight: .bold
        )

        titleLabel.textColor =
            UIColor(hex: "#2D2430")

        titleLabel.numberOfLines = 0


        // MARK: - Theme

        let themeLabel = UILabel()

        themeLabel.text =
            relationships.theme.displayKeywords
                .joined(separator: "  •  ")

        themeLabel.font = .systemFont(
            ofSize: 14,
            weight: .semibold
        )

        themeLabel.textColor =
            UIColor(hex: "#A060C5")

        themeLabel.numberOfLines = 0


        // MARK: - Detail

        let detailTitle = makeSectionTitle(
            "BUGÜNÜN DETAYI"
        )

        let bodyLabel = makeBodyLabel(
            relationships.general.text,
            weight: .regular
        )


        // MARK: - Good For Today

        let goodBox = UIView()
        goodBox.backgroundColor =
            UIColor(hex: "#FBE2F1")
        goodBox.layer.cornerRadius = 18


        let goodTitle = UILabel()
        goodTitle.text =
            relationships.goodForToday.title

        goodTitle.font = .systemFont(
            ofSize: 16,
            weight: .bold
        )

        goodTitle.textColor =
            UIColor(hex: "#A7437B")

        goodTitle.numberOfLines = 0


        let goodText = makeBodyLabel(
            relationships.goodForToday.text,
            weight: .regular
        )


        let goodStack = UIStackView(
            arrangedSubviews: [
                goodTitle,
                goodText
            ]
        )

        goodStack.translatesAutoresizingMaskIntoConstraints = false
        goodStack.axis = .vertical
        goodStack.spacing = 8

        goodBox.addSubview(goodStack)


        NSLayoutConstraint.activate([

            goodStack.topAnchor.constraint(
                equalTo: goodBox.topAnchor,
                constant: 16
            ),

            goodStack.leadingAnchor.constraint(
                equalTo: goodBox.leadingAnchor,
                constant: 16
            ),

            goodStack.trailingAnchor.constraint(
                equalTo: goodBox.trailingAnchor,
                constant: -16
            ),

            goodStack.bottomAnchor.constraint(
                equalTo: goodBox.bottomAnchor,
                constant: -16
            )
        ])


        // MARK: - Avoid Today

        let avoidTitle =
            makeSectionTitle(
                "BUGÜN DİKKAT"
            )

        let avoidStack = makeAvoidStack(
            relationships.avoidToday
        )


        // MARK: - Main Stack

        let stack = UIStackView(
            arrangedSubviews: [
                iconCircle,
                titleLabel,
                themeLabel,
                detailTitle,
                bodyLabel,
                goodBox,
                avoidTitle,
                avoidStack
            ]
        )

        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16


        stack.setCustomSpacing(
            8,
            after: titleLabel
        )

        stack.setCustomSpacing(
            28,
            after: themeLabel
        )

        stack.setCustomSpacing(
            10,
            after: detailTitle
        )

        stack.setCustomSpacing(
            26,
            after: bodyLabel
        )

        stack.setCustomSpacing(
            26,
            after: goodBox
        )

        stack.setCustomSpacing(
            10,
            after: avoidTitle
        )


        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)


        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(
                equalTo: view.topAnchor
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
                equalTo:
                    scrollView.contentLayoutGuide.topAnchor
            ),

            contentView.leadingAnchor.constraint(
                equalTo:
                    scrollView.contentLayoutGuide.leadingAnchor
            ),

            contentView.trailingAnchor.constraint(
                equalTo:
                    scrollView.contentLayoutGuide.trailingAnchor
            ),

            contentView.bottomAnchor.constraint(
                equalTo:
                    scrollView.contentLayoutGuide.bottomAnchor
            ),

            contentView.widthAnchor.constraint(
                equalTo:
                    scrollView.frameLayoutGuide.widthAnchor
            ),


            stack.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 30
            ),

            stack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),

            stack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),

            stack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -40
            ),


            iconCircle.widthAnchor.constraint(
                equalToConstant: 56
            ),

            iconCircle.heightAnchor.constraint(
                equalToConstant: 56
            ),

            iconLabel.centerXAnchor.constraint(
                equalTo: iconCircle.centerXAnchor
            ),

            iconLabel.centerYAnchor.constraint(
                equalTo: iconCircle.centerYAnchor
            )
        ])
    }


    // MARK: - Helpers

    private func makeSectionTitle(
        _ text: String
    ) -> UILabel {

        let label = UILabel()

        label.text = text

        label.font = .systemFont(
            ofSize: 13,
            weight: .bold
        )

        label.textColor =
            UIColor(hex: "#F05FAF")

        label.numberOfLines = 0

        return label
    }


    private func makeBodyLabel(
        _ text: String,
        weight: UIFont.Weight
    ) -> UILabel {

        let label = UILabel()

        label.text = text
        label.numberOfLines = 0

        label.font = .systemFont(
            ofSize: 17,
            weight: weight
        )

        label.textColor =
            UIColor(hex: "#5F5265")

        return label
    }


    private func makeAvoidStack(
        _ items: [String]
    ) -> UIStackView {

        let stack = UIStackView()

        stack.axis = .vertical
        stack.spacing = 11


        for item in items {

            let bullet = UILabel()

            bullet.text = "•"

            bullet.font = .systemFont(
                ofSize: 19,
                weight: .bold
            )

            bullet.textColor =
                UIColor(hex: "#B68BE1")

            bullet.setContentHuggingPriority(
                .required,
                for: .horizontal
            )


            let textLabel =
                makeBodyLabel(
                    item,
                    weight: .medium
                )


            let row = UIStackView(
                arrangedSubviews: [
                    bullet,
                    textLabel
                ]
            )

            row.axis = .horizontal
            row.alignment = .top
            row.spacing = 9

            stack.addArrangedSubview(row)
        }

        return stack
    }
}
