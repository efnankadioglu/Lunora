//
//  FirstExperience.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.08.2026.
//

import UIKit

private final class NeedOptionButton: UIControl {

    let need: FirstExperienceNeed

    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let checkImageView = UIImageView()

    init(need: FirstExperienceNeed) {
        self.need = need
        super.init(frame: .zero)

        setupView()
        setupLayout()
        applyContent()
        updateAppearance(isSelected: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.12
            ) {
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.985, y: 0.985)
                    : .identity
            }
        }
    }

    private func setupView() {

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor.white.withAlphaComponent(0.78)

        layer.cornerRadius = 22

        layer.borderWidth = 1
        layer.borderColor = UIColor.white
            .withAlphaComponent(0.80)
            .cgColor

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.80)
        iconContainerView.layer.cornerRadius = 21
        iconContainerView.isUserInteractionEnabled = false

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(
            red: 242/255,
            green: 92/255,
            blue: 184/255,
            alpha: 1
        )
        iconImageView.isUserInteractionEnabled = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )
        titleLabel.textColor = UIColor(
            red: 55/255,
            green: 40/255,
            blue: 60/255,
            alpha: 1
        )
        titleLabel.numberOfLines = 2
        titleLabel.isUserInteractionEnabled = false

        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.image = UIImage(
            systemName: "checkmark.circle.fill"
        )
        checkImageView.tintColor = UIColor(
            red: 244/255,
            green: 76/255,
            blue: 155/255,
            alpha: 1
        )
        checkImageView.alpha = 0
        checkImageView.isUserInteractionEnabled = false

        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)

        addSubview(titleLabel)
        addSubview(checkImageView)
    }

    private func setupLayout() {

        NSLayoutConstraint.activate([

            heightAnchor.constraint(
                greaterThanOrEqualToConstant: 72
            ),

            iconContainerView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 14
            ),
            iconContainerView.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            iconContainerView.widthAnchor.constraint(
                equalToConstant: 42
            ),
            iconContainerView.heightAnchor.constraint(
                equalToConstant: 42
            ),

            iconImageView.centerXAnchor.constraint(
                equalTo: iconContainerView.centerXAnchor
            ),
            iconImageView.centerYAnchor.constraint(
                equalTo: iconContainerView.centerYAnchor
            ),
            iconImageView.widthAnchor.constraint(
                equalToConstant: 20
            ),
            iconImageView.heightAnchor.constraint(
                equalToConstant: 20
            ),

            checkImageView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -15
            ),
            checkImageView.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            checkImageView.widthAnchor.constraint(
                equalToConstant: 23
            ),
            checkImageView.heightAnchor.constraint(
                equalToConstant: 23
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor,
                constant: 13
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: checkImageView.leadingAnchor,
                constant: -10
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            titleLabel.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 14
            ),
            titleLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -14
            )
        ])
    }

    private func applyContent() {

        iconImageView.image = UIImage(
            systemName: need.symbolName
        )

        titleLabel.text = need.title
    }

    func updateAppearance(
        isSelected: Bool
    ) {

        if isSelected {

            backgroundColor = UIColor.white.withAlphaComponent(0.94)

            layer.borderWidth = 2

            layer.borderColor = UIColor(
                red: 244/255,
                green: 76/255,
                blue: 155/255,
                alpha: 1
            ).cgColor

            iconContainerView.backgroundColor = UIColor(
                red: 255/255,
                green: 235/255,
                blue: 246/255,
                alpha: 1
            )

            checkImageView.alpha = 1

        } else {

            backgroundColor = UIColor.white.withAlphaComponent(0.76)

            layer.borderWidth = 1

            layer.borderColor = UIColor.white
                .withAlphaComponent(0.80)
                .cgColor

            iconContainerView.backgroundColor = UIColor.white
                .withAlphaComponent(0.80)

            checkImageView.alpha = 0
        }
    }
}

final class FirstExperienceNeedViewController: UIViewController {

    // MARK: - Properties

    private let coordinator: FirstExperienceCoordinator
    private var selectedNeed: FirstExperienceNeed?

    var onContinue: ((FirstExperienceNeed) -> Void)?

    private var optionButtons: [NeedOptionButton] = []

    // MARK: - UI

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "welcome_background_phone")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stepBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.40)
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stepLabel: UILabel = {
        let label = UILabel()
        label.text = "1 / 3"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(
            red: 83/255,
            green: 67/255,
            blue: 92/255,
            alpha: 1
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Şu an sana en çok hangisi iyi gelirdi?"
        label.font = .systemFont(ofSize: 38, weight: .bold)
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

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sadece Lunora’yı nereden keşfetmeye başlayacağını seç."
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(
            red: 101/255,
            green: 84/255,
            blue: 109/255,
            alpha: 1
        )
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let continueButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Buradan başlayalım", for: .normal)
        button.alpha = 0.45
        button.isUserInteractionEnabled = false
        return button
    }()

    // MARK: - Init

    init(coordinator: FirstExperienceCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        createOptionButtons()
        restoreSelectionIfNeeded()
        continueButton.addTarget(
            self,
            action: #selector(continueTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .black

        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(scrollView)
        view.addSubview(continueButton)

        scrollView.addSubview(contentView)

        contentView.addSubview(stepBadgeView)
        stepBadgeView.addSubview(stepLabel)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(optionsStackView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([

            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 62),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -18),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stepBadgeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            stepBadgeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            stepLabel.topAnchor.constraint(equalTo: stepBadgeView.topAnchor, constant: 8),
            stepLabel.leadingAnchor.constraint(equalTo: stepBadgeView.leadingAnchor, constant: 12),
            stepLabel.trailingAnchor.constraint(equalTo: stepBadgeView.trailingAnchor, constant: -12),
            stepLabel.bottomAnchor.constraint(equalTo: stepBadgeView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: stepBadgeView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            optionsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Options

    private func createOptionButtons() {
        FirstExperienceNeed.allCases.forEach { need in
            let button = NeedOptionButton(need: need)
            button.addTarget(
                self,
                action: #selector(optionTapped(_:)),
                for: .touchUpInside
            )
            optionButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }

    @objc
    private func optionTapped(_ sender: NeedOptionButton) {
        selectedNeed = sender.need
        updateSelectionUI()
        updateContinueButton()
    }

    private func updateSelectionUI() {
        optionButtons.forEach { button in
            let isSelected = button.need == selectedNeed
            button.updateAppearance(isSelected: isSelected)
        }
    }

    private func updateContinueButton() {
        let hasSelection = selectedNeed != nil
        continueButton.alpha = hasSelection ? 1.0 : 0.45
        continueButton.isUserInteractionEnabled = hasSelection
    }

    private func restoreSelectionIfNeeded() {
        guard let savedNeed = coordinator.state.selectedNeed else {
            return
        }

        selectedNeed = savedNeed
        updateSelectionUI()
        updateContinueButton()
    }

    // MARK: - Actions

    @objc
    private func continueTapped() {

        guard let selectedNeed else {
            return
        }

        coordinator.selectNeed(selectedNeed)

        print(
            "🩷 FIRST EXPERIENCE SELECTED:",
            selectedNeed.rawValue
        )

        onContinue?(selectedNeed)
    }
}
