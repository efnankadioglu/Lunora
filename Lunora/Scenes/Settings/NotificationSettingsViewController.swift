//
//  NotificationSettingsViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import UIKit
import UserNotifications

final class NotificationSettingsViewController: UIViewController {

    // MARK: - Colors

    private let pageBackgroundColor = UIColor(named: "lunoraPink") ?? UIColor(
        red: 246/255,
        green: 238/255,
        blue: 244/255,
        alpha: 1
    )

    private let accentColor = UIColor(hex: "#E85A9F")
    private let primaryTextColor = UIColor(hex: "#2D2430")
    private let secondaryTextColor = UIColor(hex: "#7C6F7F")
    private let rowBackgroundColor = UIColor(hex: "#FFF7FC")


    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private let mainStackView = UIStackView()

    private let systemStatusLabel = UILabel()
    private let systemDescriptionLabel = UILabel()
    private let systemActionButton = UIButton(type: .system)

    private let programSwitch = UISwitch()
    private let astrologySwitch = UISwitch()
    private let beautySwitch = UISwitch()

    private let masterNotificationSwitch = UISwitch()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = pageBackgroundColor

        setupUI()
        configureSwitches()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        refreshSystemNotificationStatus()
    }
    
    


    // MARK: - Setup

    private func setupUI() {

        setupScrollView()
        setupHeader()
        setupMainStackView()

        mainStackView.addArrangedSubview(makeSystemPermissionCard())
        mainStackView.addArrangedSubview(makePreferencesCard())
    }


    private func setupScrollView() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = pageBackgroundColor
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = pageBackgroundColor

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

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
            )
        ])
    }


    private func setupHeader() {

        backButton.translatesAutoresizingMaskIntoConstraints = false

        backButton.setImage(
            UIImage(systemName: "chevron.left"),
            for: .normal
        )

        backButton.tintColor = accentColor
        backButton.backgroundColor = UIColor(hex: "#FFF4FA")
        backButton.layer.cornerRadius = 19
        backButton.clipsToBounds = true

        backButton.addTarget(
            self,
            action: #selector(didTapBack),
            for: .touchUpInside
        )


        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Bildirimler"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = primaryTextColor


        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)


        NSLayoutConstraint.activate([

            backButton.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 24
            ),

            backButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            backButton.widthAnchor.constraint(equalToConstant: 38),
            backButton.heightAnchor.constraint(equalToConstant: 38),

            titleLabel.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: backButton.trailingAnchor,
                constant: 14
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            )
        ])
    }


    private func setupMainStackView() {

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 18
        mainStackView.alignment = .fill

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([

            mainStackView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 26
            ),

            mainStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            mainStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            mainStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -60
            )
        ])
    }


    // MARK: - System Permission Card

    private func makeSystemPermissionCard() -> UIView {

        let cardView = makeCard()


        let titleLabel = UILabel()
        titleLabel.text = "Genel Bildirimler"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = primaryTextColor


        let descriptionLabel = UILabel()
        descriptionLabel.text =
            "Lunora'dan bildirim almak isteyip istemediğini buradan belirleyebilirsin."

        descriptionLabel.font = .systemFont(
            ofSize: 13,
            weight: .regular
        )

        descriptionLabel.textColor = secondaryTextColor
        descriptionLabel.numberOfLines = 0


        masterNotificationSwitch.onTintColor = accentColor


        let headerStack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                UIView(),
                masterNotificationSwitch
            ]
        )

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12


        let stack = UIStackView(
            arrangedSubviews: [
                headerStack,
                descriptionLabel,
                systemDescriptionLabel,
                systemActionButton
            ]
        )

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10


        systemDescriptionLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )

        systemDescriptionLabel.textColor = UIColor(hex: "#D94D6A")
        systemDescriptionLabel.numberOfLines = 0
        systemDescriptionLabel.isHidden = true


        systemActionButton.setTitleColor(
            accentColor,
            for: .normal
        )

        systemActionButton.titleLabel?.font = .systemFont(
            ofSize: 14,
            weight: .semibold
        )

        systemActionButton.contentHorizontalAlignment = .leading
        systemActionButton.isHidden = true

        systemActionButton.addTarget(
            self,
            action: #selector(didTapSystemNotificationAction),
            for: .touchUpInside
        )


        cardView.addSubview(stack)

        NSLayoutConstraint.activate([

            stack.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 20
            ),

            stack.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 20
            ),

            stack.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -20
            ),

            stack.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -20
            )
        ])

        return cardView
    }


    // MARK: - Preferences Card

    private func makePreferencesCard() -> UIView {

        let cardView = makeCard()

        let cardTitleLabel = UILabel()
        cardTitleLabel.text = "Bildirim Türleri"
        cardTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        cardTitleLabel.textColor = primaryTextColor


        let descriptionLabel = UILabel()

        descriptionLabel.text =
            "Hangi konularda Lunora'dan bildirim almak istediğini seçebilirsin."

        descriptionLabel.font = .systemFont(
            ofSize: 13,
            weight: .regular
        )

        descriptionLabel.textColor = secondaryTextColor
        descriptionLabel.numberOfLines = 0


        let stack = UIStackView()

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12

        stack.addArrangedSubview(cardTitleLabel)
        stack.addArrangedSubview(descriptionLabel)

        stack.setCustomSpacing(16, after: descriptionLabel)


        stack.addArrangedSubview(
            makeSwitchRow(
                icon: "checkmark.circle",
                title: "Program Bildirimleri",
                subtitle: "Günlük görevlerin, ilerlemen ve programındaki önemli anlar için hatırlatmalar al.",
                toggle: programSwitch
            )
        )


        stack.addArrangedSubview(
            makeSwitchRow(
                icon: "moon.stars",
                title: "Astroloji Bildirimleri",
                subtitle: "Yaklaşan önemli gökyüzü hareketlerini ve astrolojik dönemleri önceden öğren.",
                toggle: astrologySwitch
            )
        )


        stack.addArrangedSubview(
            makeSwitchRow(
                icon: "sparkles",
                title: "Güzellik & Bakım",
                subtitle: "Güzellik ve bakım rutinlerin için önemli zamanlamaları önceden öğren.",
                toggle: beautySwitch
            )
        )


        cardView.addSubview(stack)

        NSLayoutConstraint.activate([

            stack.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 20
            ),

            stack.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 20
            ),

            stack.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -20
            ),

            stack.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -20
            )
        ])

        return cardView
    }


    private func makeCard() -> UIView {

        let cardView = UIView()

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 26

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 14
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        return cardView
    }


    private func makeSwitchRow(
        icon: String,
        title: String,
        subtitle: String,
        toggle: UISwitch
    ) -> UIView {

        let rowView = UIView()

        rowView.backgroundColor = rowBackgroundColor
        rowView.layer.cornerRadius = 18


        let iconImageView = UIImageView()

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = accentColor
        iconImageView.contentMode = .scaleAspectFit


        let titleLabel = UILabel()

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#3A2A3F")


        let subtitleLabel = UILabel()

        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
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


        toggle.onTintColor = accentColor


        let horizontalStack = UIStackView(
            arrangedSubviews: [
                iconImageView,
                textStack,
                UIView(),
                toggle
            ]
        )

        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.spacing = 12


        rowView.addSubview(horizontalStack)


        NSLayoutConstraint.activate([

            rowView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 72
            ),

            iconImageView.widthAnchor.constraint(
                equalToConstant: 22
            ),

            iconImageView.heightAnchor.constraint(
                equalToConstant: 22
            ),

            horizontalStack.topAnchor.constraint(
                equalTo: rowView.topAnchor,
                constant: 12
            ),

            horizontalStack.leadingAnchor.constraint(
                equalTo: rowView.leadingAnchor,
                constant: 16
            ),

            horizontalStack.trailingAnchor.constraint(
                equalTo: rowView.trailingAnchor,
                constant: -16
            ),

            horizontalStack.bottomAnchor.constraint(
                equalTo: rowView.bottomAnchor,
                constant: -12
            )
        ])

        return rowView
    }


    // MARK: - Switches

    private func configureSwitches() {

        masterNotificationSwitch.isOn =
            NotificationPreferences.shared.areNotificationsEnabled

        programSwitch.isOn =
            NotificationPreferences.shared.isEnabled(.program)

        astrologySwitch.isOn =
            NotificationPreferences.shared.isEnabled(.astrology)

        beautySwitch.isOn =
            NotificationPreferences.shared.isEnabled(.beauty)


        masterNotificationSwitch.addTarget(
            self,
            action: #selector(masterNotificationSwitchChanged),
            for: .valueChanged
        )

        programSwitch.addTarget(
            self,
            action: #selector(programSwitchChanged),
            for: .valueChanged
        )

        astrologySwitch.addTarget(
            self,
            action: #selector(astrologySwitchChanged),
            for: .valueChanged
        )

        beautySwitch.addTarget(
            self,
            action: #selector(beautySwitchChanged),
            for: .valueChanged
        )


        updateCategorySwitchState()
    }
    
    @objc private func masterNotificationSwitchChanged() {

        let isEnabled = masterNotificationSwitch.isOn

        NotificationPreferences.shared
            .setNotificationsEnabled(isEnabled)
        
        NotificationPreferencesSyncService.shared.syncCurrentPreferences()


        programSwitch.setOn(
            isEnabled,
            animated: true
        )

        astrologySwitch.setOn(
            isEnabled,
            animated: true
        )

        beautySwitch.setOn(
            isEnabled,
            animated: true
        )


        updateCategorySwitchState()
    }
    
    private func updateCategorySwitchState() {

        let masterEnabled = masterNotificationSwitch.isOn

        programSwitch.isEnabled = masterEnabled
        astrologySwitch.isEnabled = masterEnabled
        beautySwitch.isEnabled = masterEnabled

        programSwitch.alpha = masterEnabled ? 1.0 : 0.45
        astrologySwitch.alpha = masterEnabled ? 1.0 : 0.45
        beautySwitch.alpha = masterEnabled ? 1.0 : 0.45
    }


    @objc private func programSwitchChanged() {
        NotificationPreferences.shared.setEnabled(
            programSwitch.isOn,
            for: .program
        )

        NotificationPreferencesSyncService.shared.syncCurrentPreferences()
    }


    @objc private func astrologySwitchChanged() {
        NotificationPreferences.shared.setEnabled(
            astrologySwitch.isOn,
            for: .astrology
        )

        NotificationPreferencesSyncService.shared.syncCurrentPreferences()
    }


    @objc private func beautySwitchChanged() {
        NotificationPreferences.shared.setEnabled(
            beautySwitch.isOn,
            for: .beauty
        )

        NotificationPreferencesSyncService.shared.syncCurrentPreferences()
    }


    // MARK: - System Notification Status

    private func refreshSystemNotificationStatus() {

        NotificationManager.shared.getNotificationAuthorizationStatus {
            [weak self] status in

            guard let self else { return }

            switch status {

            case .authorized, .provisional, .ephemeral:

                self.systemStatusLabel.text = "Açık"
                self.systemStatusLabel.textColor = UIColor(
                    hex: "#4E9B72"
                )

                self.systemActionButton.isHidden = true


            case .denied:

                self.systemStatusLabel.text =
                    "iPhone ayarlarından kapalı"

                self.systemStatusLabel.textColor = UIColor(
                    hex: "#D94D6A"
                )

                self.systemActionButton.setTitle(
                    "iPhone Ayarlarına Git",
                    for: .normal
                )

                self.systemActionButton.isHidden = false


            case .notDetermined:

                self.systemStatusLabel.text =
                    "Henüz izin verilmedi"

                self.systemStatusLabel.textColor =
                    secondaryTextColor

                self.systemActionButton.setTitle(
                    "Bildirimleri Aç",
                    for: .normal
                )

                self.systemActionButton.isHidden = false


            @unknown default:

                self.systemStatusLabel.text =
                    "Durum belirlenemedi"

                self.systemActionButton.isHidden = true
            }
        }
    }


    // MARK: - Actions

    @objc private func didTapSystemNotificationAction() {

        NotificationManager.shared.getNotificationAuthorizationStatus {
            [weak self] status in

            guard let self else { return }

            switch status {

            case .notDetermined:

                NotificationManager.shared
                    .requestNotificationPermission {
                        [weak self] _ in

                        self?.refreshSystemNotificationStatus()
                    }


            case .denied:

                NotificationManager.shared
                    .openSystemNotificationSettings()


            default:

                break
            }
        }
    }


    @objc private func didTapBack() {

        navigationController?.popViewController(
            animated: true
        )
    }
}
