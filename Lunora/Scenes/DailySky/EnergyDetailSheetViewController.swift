//
//  EnergyDetailSheetViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 22.08.2026.
//

import UIKit

final class EnergyDetailSheetViewController: UIViewController {

    private let titleText: String
    private let bodyText: String

    init(
        title: String,
        body: String
    ) {
        self.titleText = title
        self.bodyText = body

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

        // MARK: Icon

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(
            image: UIImage(named: "astro_daily_energy_icon")
        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit

        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(
                equalToConstant: 64
            ),

            iconContainer.heightAnchor.constraint(
                equalToConstant: 64
            ),

            iconImageView.topAnchor.constraint(
                equalTo: iconContainer.topAnchor
            ),

            iconImageView.leadingAnchor.constraint(
                equalTo: iconContainer.leadingAnchor
            ),

            iconImageView.trailingAnchor.constraint(
                equalTo: iconContainer.trailingAnchor
            ),

            iconImageView.bottomAnchor.constraint(
                equalTo: iconContainer.bottomAnchor
            )
        ])


        // MARK: Title

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .systemFont(
            ofSize: 25,
            weight: .bold
        )
        titleLabel.textColor =
            UIColor(hex: "#2D2430")
        titleLabel.numberOfLines = 0


        // MARK: Detail title

        let detailTitleLabel = UILabel()
        detailTitleLabel.text = "BUGÜNÜN DETAYI"
        detailTitleLabel.font = .systemFont(
            ofSize: 13,
            weight: .bold
        )
        detailTitleLabel.textColor =
            UIColor(hex: "#F05FAF")


        // MARK: Body

        let bodyLabel = UILabel()
        bodyLabel.text = bodyText
        bodyLabel.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )
        bodyLabel.textColor =
            UIColor(hex: "#5F5265")
        bodyLabel.numberOfLines = 0


        let headerStack = UIStackView(
            arrangedSubviews: [
                iconContainer,
                titleLabel
            ]
        )

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 14

        let stack = UIStackView(
            arrangedSubviews: [
                headerStack,
                detailTitleLabel,
                bodyLabel
            ]
        )

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16

        stack.setCustomSpacing(
            26,
            after: headerStack
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

        ])
    }
}
