//
//  FirstExperienceHandoffViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.08.2026.
//

import UIKit

final class FirstExperienceHandoffViewController: UIViewController {

    // MARK: - Properties

    private let coordinator: FirstExperienceCoordinator

    var onBack: (() -> Void)?
    var onContinue: (() -> Void)?

    // MARK: - Background

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(
            named: "welcome_background_phone"
        )

        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let overlayView: UIView = {
        let view = UIView()

        view.backgroundColor =
            UIColor.white.withAlphaComponent(0.10)

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    // MARK: - Back Button

    private let backButton: UIButton = {
        let button = UIButton(type: .system)

        let configuration = UIImage.SymbolConfiguration(
            pointSize: 18,
            weight: .semibold
        )

        button.setImage(
            UIImage(
                systemName: "chevron.left",
                withConfiguration: configuration
            ),
            for: .normal
        )

        button.tintColor = UIColor(
            red: 55/255,
            green: 40/255,
            blue: 60/255,
            alpha: 1
        )

        button.backgroundColor =
            UIColor.white.withAlphaComponent(0.55)

        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Step Badge

    private let stepBadgeView: UIView = {
        let view = UIView()

        view.backgroundColor =
            UIColor.white.withAlphaComponent(0.45)

        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let stepLabel: UILabel = {
        let label = UILabel()

        label.text = "3 / 3"

        label.font = .systemFont(
            ofSize: 13,
            weight: .semibold
        )

        label.textColor = UIColor(
            red: 83/255,
            green: 67/255,
            blue: 92/255,
            alpha: 1
        )

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Main Content

    private let eyebrowLabel: UILabel = {
        let label = UILabel()

        label.text = "SON BİR ADIM"

        label.font = .systemFont(
            ofSize: 13,
            weight: .bold
        )

        label.textColor = UIColor(
            red: 239/255,
            green: 67/255,
            blue: 151/255,
            alpha: 1
        )

        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.text =
            "Şimdi Lunora’yı birlikte keşfedelim "

        label.font = .systemFont(
            ofSize: 34,
            weight: .bold
        )

        label.textColor = UIColor(
            red: 44/255,
            green: 31/255,
            blue: 49/255,
            alpha: 1
        )

        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()

        label.text =
            """
            Günün enerjisinden ilişkilerine, kendine ayıracağın zamandan ilerlemek istediğin konulara kadar Lunora sana günlük bir başlangıç noktası sunar.
            """

        label.font = .systemFont(
            ofSize: 18,
            weight: .regular
        )

        label.textColor = UIColor(
            red: 95/255,
            green: 82/255,
            blue: 100/255,
            alpha: 1
        )

        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Transition Area

    private let sparkleContainerView: UIView = {
        let view = UIView()

        view.backgroundColor =
            UIColor.white.withAlphaComponent(0.42)

        view.layer.cornerRadius = 38
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let sparkleImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(
            systemName: "sparkles"
        )

        imageView.tintColor = UIColor(
            red: 242/255,
            green: 92/255,
            blue: 184/255,
            alpha: 1
        )

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let transitionLabel: UILabel = {
        let label = UILabel()

        label.text =
            """
            Lunora, kendin için çıktığın bu yolda sana eşlik etmek için burada ✨
            """

        label.font = .systemFont(
            ofSize: 17,
            weight: .medium
        )

        label.textColor = UIColor(
            red: 78/255,
            green: 62/255,
            blue: 86/255,
            alpha: 1
        )

        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let smallHintLabel: UILabel = {
        let label = UILabel()

        label.text =
            "İhtiyacına göre bazen bugünü anlamana, bazen de adım adım ilerlemene yardımcı olabilir "

        label.font = .systemFont(
            ofSize: 14,
            weight: .regular
        )

        label.textColor = UIColor(
            red: 111/255,
            green: 94/255,
            blue: 117/255,
            alpha: 1
        )

        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Continue Button

    private let continueButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton()

        button.setTitle(
            "Lunora’yı keşfet",
            for: .normal
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Init

    init(
        coordinator: FirstExperienceCoordinator
    ) {
        self.coordinator = coordinator

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupLayout()
        setupActions()
    }

    // MARK: - Setup

    private func setupView() {

        view.backgroundColor = .black

        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)

        view.addSubview(scrollView)
        view.addSubview(continueButton)

        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)

        contentView.addSubview(stepBadgeView)
        stepBadgeView.addSubview(stepLabel)

        contentView.addSubview(eyebrowLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)

        contentView.addSubview(sparkleContainerView)
        sparkleContainerView.addSubview(sparkleImageView)

        contentView.addSubview(transitionLabel)
        contentView.addSubview(smallHintLabel)
    }

    private func setupActions() {

        backButton.addTarget(
            self,
            action: #selector(backTapped),
            for: .touchUpInside
        )

        continueButton.addTarget(
            self,
            action: #selector(continueTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Layout

    private func setupLayout() {

        NSLayoutConstraint.activate([

            // MARK: Background

            backgroundImageView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            backgroundImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            backgroundImageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            backgroundImageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            overlayView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            overlayView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            overlayView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            overlayView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            // MARK: Bottom CTA

            continueButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),

            continueButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            continueButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),

            continueButton.heightAnchor.constraint(
                equalToConstant: 62
            ),

            // MARK: Scroll

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
                equalTo: continueButton.topAnchor,
                constant: -12
            ),

            // MARK: Content

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

            // MARK: Header

            backButton.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 18
            ),

            backButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),

            backButton.widthAnchor.constraint(
                equalToConstant: 40
            ),

            backButton.heightAnchor.constraint(
                equalToConstant: 40
            ),

            stepBadgeView.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            ),

            stepBadgeView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),

            stepBadgeView.heightAnchor.constraint(
                equalToConstant: 38
            ),

            stepLabel.topAnchor.constraint(
                equalTo: stepBadgeView.topAnchor,
                constant: 8
            ),

            stepLabel.bottomAnchor.constraint(
                equalTo: stepBadgeView.bottomAnchor,
                constant: -8
            ),

            stepLabel.leadingAnchor.constraint(
                equalTo: stepBadgeView.leadingAnchor,
                constant: 14
            ),

            stepLabel.trailingAnchor.constraint(
                equalTo: stepBadgeView.trailingAnchor,
                constant: -14
            ),

            // MARK: Eyebrow

            eyebrowLabel.topAnchor.constraint(
                equalTo: backButton.bottomAnchor,
                constant: 58
            ),

            eyebrowLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),

            eyebrowLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),

            // MARK: Title

            titleLabel.topAnchor.constraint(
                equalTo: eyebrowLabel.bottomAnchor,
                constant: 14
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),

            // MARK: Body

            bodyLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 20
            ),

            bodyLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),

            bodyLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),

            // MARK: Sparkle

            sparkleContainerView.topAnchor.constraint(
                equalTo: bodyLabel.bottomAnchor,
                constant: 48
            ),

            sparkleContainerView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),

            sparkleContainerView.widthAnchor.constraint(
                equalToConstant: 76
            ),

            sparkleContainerView.heightAnchor.constraint(
                equalToConstant: 76
            ),

            sparkleImageView.centerXAnchor.constraint(
                equalTo: sparkleContainerView.centerXAnchor
            ),

            sparkleImageView.centerYAnchor.constraint(
                equalTo: sparkleContainerView.centerYAnchor
            ),

            sparkleImageView.widthAnchor.constraint(
                equalToConstant: 34
            ),

            sparkleImageView.heightAnchor.constraint(
                equalToConstant: 34
            ),

            // MARK: Transition Copy

            transitionLabel.topAnchor.constraint(
                equalTo: sparkleContainerView.bottomAnchor,
                constant: 24
            ),

            transitionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 38
            ),

            transitionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -38
            ),

            smallHintLabel.topAnchor.constraint(
                equalTo: transitionLabel.bottomAnchor,
                constant: 10
            ),

            smallHintLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 44
            ),

            smallHintLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -44
            ),

            smallHintLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -30
            )
        ])
    }

    // MARK: - Actions

    @objc
    private func backTapped() {

        coordinator.moveBack()
        onBack?()
    }

    @objc
    private func continueTapped() {

        coordinator.completeFirstExperience()
        onContinue?()
    }
}
