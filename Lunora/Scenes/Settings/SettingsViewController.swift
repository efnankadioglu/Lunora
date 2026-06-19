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
//                SettingsRow(icon: "key", title: "Şifre Değiştir", isDestructive: false)
            ]
        ),
        SettingsSection(
            title: "Tercihler",
            rows: [
                SettingsRow(icon: "bell", title: "Bildirimler", isDestructive: false),
                SettingsRow(icon: "globe", title: "Dil", isDestructive: false)
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
            showComingSoonAlert(title: "Profili Düzenle")

        case "Bildirimler":
            showComingSoonAlert(title: "Bildirimler")

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
            showDeleteAccountWarning()

        case "Bize Ulaş":
            showComingSoonAlert(title: "Bize Ulaş")

        case "Sorun Bildir":
            showComingSoonAlert(title: "Sorun Bildir")

        case "Lunora Hakkında":
            showInfoAlert(
                title: "Lunora Hakkında",
                message: "Lunora, kişisel farkındalık ve içsel gelişim yolculuklarını destekleyen bir rehber uygulamasıdır."
            )

        case "Uygulama Sürümü":
            showAppVersion()

        case "Çıkış Yap":
            showLogoutConfirmation()

        default:
            showComingSoonAlert(title: title)
        }
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
            title: "Hesabımı Sil",
            message: "Bu işlem ileride hesabını ve Lunora’daki kişisel verilerini kalıcı olarak silmek için kullanılacak. Şu anda bu alan hazırlık aşamasında.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        alert.addAction(UIAlertAction(title: "Anladım", style: .destructive))

        present(alert, animated: true)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let loginViewController = storyboard.instantiateViewController(
            withIdentifier: "LoginViewController"
        ) as? LoginViewController else {
            print("🔴 LoginViewController bulunamadı. Storyboard ID kontrol edilmeli.")
            return
        }

        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.setNavigationBarHidden(true, animated: false)

        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        } else {
            view.window?.rootViewController = navigationController
            view.window?.makeKeyAndVisible()
        }
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
