//
//  ActivityDetailSheetViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 22.08.2026.
//

import UIKit

final class ActivityDetailSheetViewController: UIViewController {

    private let activity: AstroActivity

    init(activity: AstroActivity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#FFF9FC")

        setupUI()
    }

    private func setupUI() {

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - Icon

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(
            image: UIImage(named: "astro_daily_actions_icon")
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

        let titleLabel = UILabel()
        titleLabel.text = activity.title
        titleLabel.font = .systemFont(
            ofSize: 24,
            weight: .bold
        )
        titleLabel.textColor = UIColor(hex: "#2D2430")
        titleLabel.numberOfLines = 0
        
        let headerStack = UIStackView(
            arrangedSubviews: [
                iconContainer,
                titleLabel
            ]
        )

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 14

        let sectionLabel = UILabel()
        sectionLabel.text = "NASIL YAPABİLİRSİN?"
        sectionLabel.font = .systemFont(
            ofSize: 13,
            weight: .bold
        )
        sectionLabel.textColor = UIColor(hex: "#F05FAF")
        sectionLabel.numberOfLines = 1

        let descriptionLabel = UILabel()
        descriptionLabel.text = activity.shortDescription
        descriptionLabel.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )
        descriptionLabel.textColor = UIColor(hex: "#5F5265")
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(
            arrangedSubviews: [
                headerStack,
                sectionLabel,
                descriptionLabel
            ]
        )

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 18

        stack.setCustomSpacing(
            24,
            after: headerStack
        )

        stack.setCustomSpacing(
            24,
            after: titleLabel
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
            )

            
        ])
    }
}
