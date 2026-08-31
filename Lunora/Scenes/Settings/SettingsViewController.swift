//
//  SettingsViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 15.06.2026.
//


import UIKit
import FirebaseAuth

final class SettingsViewController: UIViewController {

    // MARK: - Types

    private struct SettingsSection {
        let title: String
        let rows: [SettingsRow]
    }

    private struct SettingsRow {
        let icon: String
        let title: String
        let isDestructive: Bool
    }

    // MARK: - Properties

    private let pageBackgroundColor = UIColor(named: "lunoraPink") ?? UIColor(
        red: 246/255,
        green: 238/255,
        blue: 244/255,
        alpha: 1
    )

    private let sections: [SettingsSection] = [
        SettingsSection(
            title: "Hesap",
            rows: [
                SettingsRow(icon: "person.crop.circle", title: "Profili Düzenle", isDestructive: false),
            ]
        ),
        
        SettingsSection(
            title: "Tercihler",
            rows: [
                SettingsRow(icon: "bell", title: "Bildirimler", isDestructive: false),
                SettingsRow(icon: "globe", title: "Dil", isDestructive: false),
                SettingsRow(icon: "book.closed", title: "Lunora’yı Nasıl Kullanabilirsin?",
                            isDestructive: false)
            ]
        ),
        SettingsSection(
            title: "Gizlilik ve Yasal",
            rows: [
                SettingsRow(icon: "lock.shield", title: "Gizlilik Politikası", isDestructive: false),
                SettingsRow(icon: "doc.text", title: "Kullanım Şartları", isDestructive: false),
                SettingsRow(icon: "trash", title: "Hesabımı Sil", isDestructive: true)
            ]
        ),
        SettingsSection(
            title: "Destek",
            rows: [
                SettingsRow(icon: "envelope", title: "Bize Ulaş", isDestructive: false),
                SettingsRow(icon: "exclamationmark.bubble", title: "Sorun Bildir", isDestructive: false)
            ]
        ),
        SettingsSection(
            title: "Hakkında",
            rows: [
                SettingsRow(icon: "sparkles", title: "Lunora Hakkında", isDestructive: false),
                SettingsRow(icon: "info.circle", title: "Uygulama Sürümü", isDestructive: false)
            ]
        ),
        SettingsSection(
            title: "Oturum",
            rows: [
                SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Çıkış Yap", isDestructive: true)
            ]
        )
    ]

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()

    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = pageBackgroundColor
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Setup UI

    private func setupUI() {
        setupScrollView()
        setupHeader()
        setupMainStackView()
        setupSections()
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

    private func setupHeader() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(hex: "#E85A9F")
        backButton.backgroundColor = UIColor(hex: "#FFF4FA")
        backButton.layer.cornerRadius = 19
        backButton.clipsToBounds = true
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Ayarlar"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")

        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 38),
            backButton.heightAnchor.constraint(equalToConstant: 38),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupMainStackView() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 18
        mainStackView.alignment = .fill

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120)
        ])
    }

    private func setupSections() {
        for section in sections {
            let sectionView = makeSectionView(section)
            mainStackView.addArrangedSubview(sectionView)
        }
    }

    // MARK: - Reusable Views

    private func makeSectionView(_ section: SettingsSection) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 26
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 14
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        let titleLabel = UILabel()
        titleLabel.text = section.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12

        stack.addArrangedSubview(titleLabel)

        for row in section.rows {
            let rowView = makeSettingsRow(row)
            stack.addArrangedSubview(rowView)
        }

        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])

        return cardView
    }

    private func makeSettingsRow(_ row: SettingsRow) -> UIView {
        let rowView = UIView()
        rowView.backgroundColor = UIColor(hex: "#FFF7FC")
        rowView.layer.cornerRadius = 18
        rowView.isUserInteractionEnabled = true

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: row.icon)
        iconImageView.tintColor = row.isDestructive ? UIColor(hex: "#D94D6A") : UIColor(hex: "#E85A9F")
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = row.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = row.isDestructive ? UIColor(hex: "#D94D6A") : UIColor(hex: "#3A2A3F")

        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = UIColor(hex: "#C9AFCF")
        chevronImageView.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            UIView(),
            chevronImageView
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        rowView.addSubview(stack)

        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(equalToConstant: 56),

            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),

            stack.topAnchor.constraint(equalTo: rowView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSettingsRow(_:)))
        rowView.addGestureRecognizer(tapGesture)
        rowView.accessibilityLabel = row.title

        return rowView
    }

    // MARK: - Actions
    
    private func requireInternet() -> Bool {
        guard NetworkMonitor.shared.isConnected else {
            InternetRequiredAlert.show(on: self)
            return false
        }

        return true
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapSettingsRow(_ gesture: UITapGestureRecognizer) {
        guard let rowView = gesture.view,
              let title = rowView.accessibilityLabel else {
            return
        }

        switch title {
        case "Profili Düzenle":
            guard requireInternet() else { return }
            navigateToEditProfile()
        
        case "Lunora’yı Nasıl Kullanabilirsin?":
            guard requireInternet() else { return }
            openLunoraGuide()

        case "Bildirimler":
            navigateToNotificationSettings()

        case "Dil":
            showInfoAlert(
                title: "Dil",
                message: "Lunora şu anda Türkçe olarak kullanılıyor."
            )

        case "Gizlilik Politikası":
            showComingSoonAlert(title: "Gizlilik Politikası")

        case "Kullanım Şartları":
            showComingSoonAlert(title: "Kullanım Şartları")

        case "Hesabımı Sil":
            guard requireInternet() else { return }
            showDeleteAccountWarning()

        case "Bize Ulaş":
            guard requireInternet() else { return }
            navigateToContactUs()

        case "Sorun Bildir":
            guard requireInternet() else { return }
            navigateToBugReport()

        case "Lunora Hakkında":
            showInfoAlert(
                title: "Lunora Hakkında",
                message: "Lunora, gökyüzünün döngülerinden ilham alan kişisel gelişim programları sunar. Programlar, farkındalık kazanmanı, rutinlerini desteklemeni ve kendine daha bilinçli alan açmanı amaçlar. Uygulamada ayrıca güncel gökyüzü hareketlerine ilişkin genel astrolojik yorumlar yer alır."
            )

        case "Uygulama Sürümü":
            showAppVersion()

        case "Çıkış Yap":
            guard requireInternet() else { return }
            showLogoutConfirmation()

        default:
            showComingSoonAlert(title: title)
        }
    }
    
    // MARK: - Navigation
    
    private func openLunoraGuide() {

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let coordinator = FirstExperienceCoordinator(
            userID: uid
        )

        // MARK: 1 / 3

        let needViewController =
            FirstExperienceNeedViewController(
                coordinator: coordinator
            )

        let guideNavigationController =
            UINavigationController(
                rootViewController: needViewController
            )

        guideNavigationController.setNavigationBarHidden(
            true,
            animated: false
        )

        guideNavigationController.modalPresentationStyle = .fullScreen

        needViewController.onContinue = {
            [weak guideNavigationController] need in

            guard let guideNavigationController else {
                return
            }

            // MARK: 2 / 3

            let previewViewController =
                FirstExperienceSelectedPreviewViewController(
                    coordinator: coordinator,
                    need: need
                )

            previewViewController.onBack = {
                [weak guideNavigationController] in

                guideNavigationController?.popViewController(
                    animated: true
                )
            }

            previewViewController.onContinue = {
                [weak guideNavigationController] in

                guard let guideNavigationController else {
                    return
                }

                // MARK: 3 / 3

                let handoffViewController =
                    FirstExperienceHandoffViewController(
                        coordinator: coordinator
                    )

                handoffViewController.onBack = {
                    [weak guideNavigationController] in

                    guideNavigationController?.popViewController(
                        animated: true
                    )
                }

                handoffViewController.onContinue = {
                    [weak self, weak guideNavigationController] in

                    guard
                        let self,
                        let uid = Auth.auth().currentUser?.uid
                    else {
                        return
                    }

                    // Uygulama içi rehberi en baştan başlat.
                    GuidedOnboardingManager.shared.restart(
                        for: uid
                    )

                    // 3 sayfalık rehberi kapat.
                    guideNavigationController?.dismiss(
                        animated: true
                    ) {
                        // Gerçek uygulamada Programlar sekmesine geç.
                        self.tabBarController?.selectedIndex = 0
                    }
                }

                guideNavigationController
                    .pushViewController(
                        handoffViewController,
                        animated: true
                    )
            }

            guideNavigationController
                .pushViewController(
                    previewViewController,
                    animated: true
                )
        }

        present(
            guideNavigationController,
            animated: true
        )
    }
    
    private func navigateToNotificationSettings() {

        let notificationSettingsViewController =
            NotificationSettingsViewController()

        navigationController?.pushViewController(
            notificationSettingsViewController,
            animated: true
        )
    }

    private func navigateToEditProfile() {
        let editProfileViewController = EditProfileViewController()

        navigationController?.pushViewController(
            editProfileViewController,
            animated: true
        )
    }
    
    private func navigateToBugReport() {
        let bugReportViewController = BugReportViewController()

        navigationController?.pushViewController(
            bugReportViewController,
            animated: true
        )
    }
    
    private func navigateToContactUs() {
        let contactUsViewController = ContactUsViewController()

        navigationController?.pushViewController(
            contactUsViewController,
            animated: true
        )
    }
    
    private func showComingSoonAlert(title: String) {
        showInfoAlert(
            title: title,
            message: "Bu alan yakında hazırlanacak."
        )
    }

    private func showInfoAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func showDeleteAccountWarning() {
        let alert = UIAlertController(
            title: "Hesabını kalıcı olarak sil?",
            message: """
            Hesabın ve hesabına bağlı profil bilgilerin, program ilerlemelerin, günlük kayıtların, kazandığın rozetler ve profil fotoğrafın kalıcı olarak silinecektir. 
            Bu işlem geri alınamaz.
            """,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Vazgeç",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Hesabımı Sil",
                style: .destructive,
                handler: { [weak self] _ in
                    self?.deleteAccount()
                }
            )
        )

        present(alert, animated: true)
    }
    
    private func deleteAccount() {
        AccountDeletionService.shared.deleteAccount { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigateToLoginScreen()

                case .failure(let error):
                    self?.showInfoAlert(
                        title: "Hesap silinemedi",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Hesabından çıkış yapmak istediğine emin misin?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))

        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()
            navigateToLoginScreen()
        } catch {
            showInfoAlert(
                title: "Çıkış Yapılamadı",
                message: "Çıkış yapılırken bir sorun oluştu. Lütfen tekrar dene."
            )
        }
    }

    private func navigateToLoginScreen() {

        let loginViewController = LoginViewController()

        let navigationController = UINavigationController(
            rootViewController: loginViewController
        )

        navigationController.setNavigationBarHidden(
            true,
            animated: false
        )

        guard let sceneDelegate =
            view.window?.windowScene?.delegate as? SceneDelegate
        else {
            return
        }

        sceneDelegate.setRoot(
            navigationController,
            animated: true
        )
    }

    private func showAppVersion() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

        showInfoAlert(
            title: "Uygulama Sürümü",
            message: "Lunora \(version) (\(build))"
        )
    }
    
}
