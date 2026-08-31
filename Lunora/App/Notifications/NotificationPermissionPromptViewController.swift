//
//  NotificationPermissionPromptViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import UIKit

final class NotificationPermissionPromptViewController: UIViewController {

    // MARK: - Properties

    private let context: NotificationPromptContext

    var onContinue: (() -> Void)?

    private let accentColor = UIColor(hex: "#E85A9F")
    private let primaryTextColor = UIColor(hex: "#2D2430")
    private let secondaryTextColor = UIColor(hex: "#7C6F7F")
    private let softPinkColor = UIColor(hex: "#FFF7FC")


    // MARK: - Init

    init(context: NotificationPromptContext = .general) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupUI()
    }


    // MARK: - UI

    private func setupUI() {

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor(hex: "#FFF1F8")
        iconContainer.layer.cornerRadius = 36

        let iconImageView = UIImageView(
            image: UIImage(systemName: "bell.badge.fill")
        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = accentColor
        iconImageView.contentMode = .scaleAspectFit

        iconContainer.addSubview(iconImageView)


        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        titleLabel.textColor = primaryTextColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0


        let descriptionLabel = UILabel()
        descriptionLabel.text = descriptionText
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = secondaryTextColor
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0


        let featureStack = UIStackView()
        featureStack.axis = .vertical
        featureStack.spacing = 10

        configureFeatures(in: featureStack)


        let footerLabel = UILabel()

        footerLabel.text =
            "Bildirim tercihlerini daha sonra Ayarlar'dan istediğin zaman değiştirebilirsin."

        footerLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )

        footerLabel.textColor = secondaryTextColor
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0


        let continueButton = UIButton(type: .system)

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Devam Et"
        configuration.baseBackgroundColor = accentColor
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large

        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 24,
            bottom: 16,
            trailing: 24
        )

        continueButton.configuration = configuration

        continueButton.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .semibold
        )

        continueButton.addTarget(
            self,
            action: #selector(didTapContinue),
            for: .touchUpInside
        )


        let mainStack = UIStackView(
            arrangedSubviews: [
                iconContainer,
                titleLabel,
                descriptionLabel,
                featureStack,
                footerLabel,
                continueButton
            ]
        )

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 18

        mainStack.setCustomSpacing(22, after: descriptionLabel)
        mainStack.setCustomSpacing(22, after: featureStack)

        view.addSubview(mainStack)


        NSLayoutConstraint.activate([

            iconContainer.widthAnchor.constraint(
                equalToConstant: 72
            ),

            iconContainer.heightAnchor.constraint(
                equalToConstant: 72
            ),

            iconImageView.centerXAnchor.constraint(
                equalTo: iconContainer.centerXAnchor
            ),

            iconImageView.centerYAnchor.constraint(
                equalTo: iconContainer.centerYAnchor
            ),

            iconImageView.widthAnchor.constraint(
                equalToConstant: 30
            ),

            iconImageView.heightAnchor.constraint(
                equalToConstant: 30
            ),

            mainStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 28
            ),

            mainStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),

            mainStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            mainStack.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),

            iconContainer.centerXAnchor.constraint(
                equalTo: mainStack.centerXAnchor
            ),

            continueButton.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 54
            )
        ])
    }


    // MARK: - Feature Rows

    private func configureFeatures(in stack: UIStackView) {

        switch context {

        case .general:

            stack.addArrangedSubview(
                makeFeatureRow(
                    icon: "checkmark.circle.fill",
                    title: "Program",
                    subtitle: "Görevlerin ve önemli ilerleme anların için hatırlatmalar."
                )
            )

            stack.addArrangedSubview(
                makeFeatureRow(
                    icon: "moon.stars.fill",
                    title: "Astroloji",
                    subtitle: "Yeniay, dolunay, retro ve yaklaşan önemli gökyüzü olayları."
                )
            )

            stack.addArrangedSubview(
                makeFeatureRow(
                    icon: "sparkles",
                    title: "Güzellik & Bakım",
                    subtitle: "Bakım ve görünüm rutinlerin için önemli zamanlamalar."
                )
            )


        case .program:

            stack.addArrangedSubview(
                makeFeatureRow(
                    icon: "checkmark.circle.fill",
                    title: "Programını takip et",
                    subtitle: "Eksik günlük görevlerin ve programındaki önemli anlar için zamanında haber al."
                )
            )


        case .astrology:

            stack.addArrangedSubview(
                makeFeatureRow(
                    icon: "moon.stars.fill",
                    title: "Gökyüzünü önceden öğren",
                    subtitle: "Yeniay, dolunay, retro ve önemli astrolojik dönemler yaklaşırken haber al."
                )
            )


        case .beauty:

            stack.addArrangedSubview(
                makeFeatureRow(
                    icon: "sparkles",
                    title: "Bakım zamanlamalarını kaçırma",
                    subtitle: "Güzellik ve bakım rutinlerin için öne çıkan dönemleri önceden öğren."
                )
            )
        }
    }


    private func makeFeatureRow(
        icon: String,
        title: String,
        subtitle: String
    ) -> UIView {

        let container = UIView()
        container.backgroundColor = softPinkColor
        container.layer.cornerRadius = 18


        let iconImageView = UIImageView(
            image: UIImage(systemName: icon)
        )

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = accentColor
        iconImageView.contentMode = .scaleAspectFit


        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = primaryTextColor


        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
        subtitleLabel.textColor = secondaryTextColor
        subtitleLabel.numberOfLines = 0


        let textStack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                subtitleLabel
            ]
        )

        textStack.axis = .vertical
        textStack.spacing = 3


        let horizontalStack = UIStackView(
            arrangedSubviews: [
                iconImageView,
                textStack
            ]
        )

        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.spacing = 13


        container.addSubview(horizontalStack)


        NSLayoutConstraint.activate([

            iconImageView.widthAnchor.constraint(
                equalToConstant: 24
            ),

            iconImageView.heightAnchor.constraint(
                equalToConstant: 24
            ),

            horizontalStack.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 14
            ),

            horizontalStack.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 16
            ),

            horizontalStack.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -16
            ),

            horizontalStack.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -14
            )
        ])

        return container
    }


    // MARK: - Text

    private var titleText: String {

        switch context {

        case .general:
            return "Lunora sana doğru zamanda eşlik etsin ✨"

        case .program:
            return "Programını kaçırmadan devam ettir ✨"

        case .astrology:
            return "Gökyüzündeki önemli anları kaçırma 🌙"

        case .beauty:
            return "Bakım zamanlamalarını önceden öğren ✨"
        }
    }


    private var descriptionText: String {

        switch context {

        case .general:
            return "Senin için gerçekten anlamlı olduğunda küçük hatırlatmalar gönderebiliriz."

        case .program:
            return "Programındaki günlük görevler ve önemli ilerleme anları için sana zamanında haber verebiliriz."

        case .astrology:
            return "Yaklaşan önemli astrolojik olayları gerçekleşmeden önce sana haber verebiliriz."

        case .beauty:
            return "Güzellik ve bakım rutinlerin açısından öne çıkan zamanları önceden sana hatırlatabiliriz."
        }
    }


    // MARK: - Actions

    @objc private func didTapContinue() {

        dismiss(animated: true) { [weak self] in
            self?.onContinue?()
        }
    }
}
