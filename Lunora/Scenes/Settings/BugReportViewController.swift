//
//  BugReportViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class BugReportViewController: UIViewController {

    // MARK: - Types

    private enum IssueCategory: String, CaseIterable {
        case programs = "programs"
        case astrology = "astrology"
        case account = "account"
        case notifications = "notifications"
        case interface = "interface"
        case performance = "performance"
        case other = "other"

        var displayName: String {
            switch self {
            case .programs:
                return "Programlar"

            case .astrology:
                return "Gökyüzü / Astroloji"

            case .account:
                return "Hesap / Profil"

            case .notifications:
                return "Bildirimler"

            case .interface:
                return "Görünüm / Ekran"

            case .performance:
                return "Yavaşlık / Donma"

            case .other:
                return "Diğer"
            }
        }
    }

    // MARK: - Constants

    private let maximumMessageLength = 1500

    // MARK: - State

    private var selectedCategory: IssueCategory?

    private var isSending = false {
        didSet {
            updateSendButtonState()
        }
    }

    // MARK: - Firebase

    private let db = Firestore.firestore()

    // MARK: - Colors

    private let pageBackgroundColor =
        UIColor(named: "lunoraPink")
        ?? UIColor(
            red: 246 / 255,
            green: 238 / 255,
            blue: 244 / 255,
            alpha: 1
        )

    private let primaryPink = UIColor(hex: "#E85A9F")
    private let textColor = UIColor(hex: "#2D2430")
    private let secondaryTextColor = UIColor(hex: "#8A768E")
    private let fieldBackgroundColor = UIColor(hex: "#FFF7FC")

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()

    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private let introCard = UIView()
    private let introIconView = UIImageView()
    private let introTitleLabel = UILabel()
    private let introDescriptionLabel = UILabel()

    private let formCard = UIView()

    private let categoryTitleLabel = UILabel()
    private let categoryButton = UIButton(type: .system)

    private let messageTitleLabel = UILabel()
    private let messageHelperLabel = UILabel()

    private let messageContainer = UIView()
    private let messageTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let characterCountLabel = UILabel()

    private let sendButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let privacyInfoView = UIView()
    private let privacyIconView = UIImageView()
    private let privacyLabel = UILabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = pageBackgroundColor

        setupUI()
        setupDismissKeyboardGesture()
        updateSendButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )
    }

    // MARK: - Setup

    private func setupUI() {
        setupScrollView()
        setupHeader()
        setupMainStack()
        setupIntroCard()
        setupFormCard()
        setupPrivacyInfo()
    }

    // MARK: - Scroll

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true

        // Klavyeyi parmakla aşağı çekerek kapatabilirsin.
        scrollView.keyboardDismissMode = .interactive

        contentView.translatesAutoresizingMaskIntoConstraints = false

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

            // Klavye açıldığında ekran otomatik küçülür.
            scrollView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor
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

    // MARK: - Header

    private func setupHeader() {
        backButton.translatesAutoresizingMaskIntoConstraints = false

        backButton.setImage(
            UIImage(systemName: "chevron.left"),
            for: .normal
        )

        backButton.tintColor = primaryPink
        backButton.backgroundColor = UIColor(hex: "#FFF4FA")
        backButton.layer.cornerRadius = 19
        backButton.clipsToBounds = true

        backButton.addTarget(
            self,
            action: #selector(didTapBack),
            for: .touchUpInside
        )

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Sorun Bildir"

        titleLabel.font = .systemFont(
            ofSize: 28,
            weight: .bold
        )

        titleLabel.textColor = textColor

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

            backButton.widthAnchor.constraint(
                equalToConstant: 38
            ),

            backButton.heightAnchor.constraint(
                equalToConstant: 38
            ),

            titleLabel.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: backButton.trailingAnchor,
                constant: 14
            ),

            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -20
            )
        ])
    }

    // MARK: - Main Stack

    private func setupMainStack() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.spacing = 18

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 28
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
                constant: -50
            )
        ])
    }

    // MARK: - Intro

    private func setupIntroCard() {
        introCard.backgroundColor = .white
        introCard.layer.cornerRadius = 26

        introCard.layer.shadowColor = UIColor.black.cgColor
        introCard.layer.shadowOpacity = 0.045
        introCard.layer.shadowRadius = 14

        introCard.layer.shadowOffset = CGSize(
            width: 0,
            height: 7
        )

        introIconView.translatesAutoresizingMaskIntoConstraints = false

        introIconView.image = UIImage(
            systemName: "exclamationmark.bubble"
        )

        introIconView.tintColor = primaryPink
        introIconView.contentMode = .scaleAspectFit

        introTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        introTitleLabel.text = "Bunu birlikte çözelim 💗"

        introTitleLabel.font = .systemFont(
            ofSize: 18,
            weight: .bold
        )

        introTitleLabel.textColor = textColor
        introTitleLabel.numberOfLines = 0

        introDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        introDescriptionLabel.text =
        """
        Yaşadığın sorunu bize mümkün olduğunca açık anlat. Her bildirimi dikkatle inceliyor ve ne olduğunu anlamaya çalışıyoruz.
        """

        introDescriptionLabel.font = .systemFont(
            ofSize: 14,
            weight: .regular
        )

        introDescriptionLabel.textColor = secondaryTextColor
        introDescriptionLabel.numberOfLines = 0

        let textStack = UIStackView(
            arrangedSubviews: [
                introTitleLabel,
                introDescriptionLabel
            ]
        )

        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 6

        introCard.addSubview(introIconView)
        introCard.addSubview(textStack)

        NSLayoutConstraint.activate([
            introIconView.leadingAnchor.constraint(
                equalTo: introCard.leadingAnchor,
                constant: 20
            ),

            introIconView.topAnchor.constraint(
                equalTo: introCard.topAnchor,
                constant: 22
            ),

            introIconView.widthAnchor.constraint(
                equalToConstant: 30
            ),

            introIconView.heightAnchor.constraint(
                equalToConstant: 30
            ),

            textStack.topAnchor.constraint(
                equalTo: introCard.topAnchor,
                constant: 20
            ),

            textStack.leadingAnchor.constraint(
                equalTo: introIconView.trailingAnchor,
                constant: 14
            ),

            textStack.trailingAnchor.constraint(
                equalTo: introCard.trailingAnchor,
                constant: -20
            ),

            textStack.bottomAnchor.constraint(
                equalTo: introCard.bottomAnchor,
                constant: -20
            )
        ])

        mainStackView.addArrangedSubview(introCard)
    }

    // MARK: - Form

    private func setupFormCard() {
        formCard.backgroundColor = .white
        formCard.layer.cornerRadius = 26

        formCard.layer.shadowColor = UIColor.black.cgColor
        formCard.layer.shadowOpacity = 0.045
        formCard.layer.shadowRadius = 14

        formCard.layer.shadowOffset = CGSize(
            width: 0,
            height: 7
        )

        let formStack = UIStackView()

        formStack.translatesAutoresizingMaskIntoConstraints = false
        formStack.axis = .vertical
        formStack.spacing = 12

        // Category

        categoryTitleLabel.text = "Sorun hangi alanda?"

        categoryTitleLabel.font = .systemFont(
            ofSize: 15,
            weight: .semibold
        )

        categoryTitleLabel.textColor = textColor

        setupCategoryButton()

        // Message

        messageTitleLabel.text = "Ne oldu?"

        messageTitleLabel.font = .systemFont(
            ofSize: 15,
            weight: .semibold
        )

        messageTitleLabel.textColor = textColor

        messageHelperLabel.text =
        "Ne yapmaya çalıştığını ve neyin beklediğin gibi çalışmadığını anlatabilirsin."

        messageHelperLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )

        messageHelperLabel.textColor = secondaryTextColor
        messageHelperLabel.numberOfLines = 0

        setupMessageContainer()
        setupSendButton()

        formStack.addArrangedSubview(categoryTitleLabel)
        formStack.addArrangedSubview(categoryButton)

        formStack.setCustomSpacing(
            22,
            after: categoryButton
        )

        formStack.addArrangedSubview(messageTitleLabel)
        formStack.addArrangedSubview(messageHelperLabel)

        formStack.setCustomSpacing(
            10,
            after: messageHelperLabel
        )

        formStack.addArrangedSubview(messageContainer)

        formStack.setCustomSpacing(
            22,
            after: messageContainer
        )

        formStack.addArrangedSubview(sendButton)

        formCard.addSubview(formStack)

        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(
                equalTo: formCard.topAnchor,
                constant: 22
            ),

            formStack.leadingAnchor.constraint(
                equalTo: formCard.leadingAnchor,
                constant: 20
            ),

            formStack.trailingAnchor.constraint(
                equalTo: formCard.trailingAnchor,
                constant: -20
            ),

            formStack.bottomAnchor.constraint(
                equalTo: formCard.bottomAnchor,
                constant: -22
            )
        ])

        mainStackView.addArrangedSubview(formCard)
    }

    // MARK: - Category

    private func setupCategoryButton() {
        categoryButton.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()

        configuration.title = "Alan seç"

        configuration.image = UIImage(
            systemName: "chevron.down"
        )

        configuration.imagePlacement = .trailing
        configuration.imagePadding = 12

        configuration.contentInsets =
            NSDirectionalEdgeInsets(
                top: 0,
                leading: 16,
                bottom: 0,
                trailing: 16
            )

        configuration.baseForegroundColor = secondaryTextColor

        categoryButton.configuration = configuration

        categoryButton.backgroundColor = fieldBackgroundColor
        categoryButton.layer.cornerRadius = 18

        categoryButton.contentHorizontalAlignment = .fill

        categoryButton.heightAnchor
            .constraint(equalToConstant: 58)
            .isActive = true

        updateCategoryMenu()
    }

    private func updateCategoryMenu() {
        let actions = IssueCategory.allCases.map { category in

            UIAction(
                title: category.displayName,
                state: selectedCategory == category
                    ? .on
                    : .off
            ) { [weak self] _ in

                guard let self else {
                    return
                }

                self.selectedCategory = category

                self.updateCategoryButton()
                self.updateCategoryMenu()
                self.updateSendButtonState()
            }
        }

        categoryButton.menu = UIMenu(
            title: "Sorun hangi alanda?",
            children: actions
        )

        categoryButton.showsMenuAsPrimaryAction = true
    }

    private func updateCategoryButton() {
        var configuration = categoryButton.configuration

        configuration?.title =
            selectedCategory?.displayName ?? "Alan seç"

        configuration?.baseForegroundColor =
            selectedCategory == nil
            ? secondaryTextColor
            : textColor

        categoryButton.configuration = configuration
    }

    // MARK: - Message

    private func setupMessageContainer() {
        messageContainer.backgroundColor = fieldBackgroundColor
        messageContainer.layer.cornerRadius = 18

        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.backgroundColor = .clear

        messageTextView.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        messageTextView.textColor = textColor
        messageTextView.tintColor = primaryPink

        messageTextView.delegate = self

        messageTextView.textContainerInset =
            UIEdgeInsets(
                top: 16,
                left: 12,
                bottom: 32,
                right: 12
            )

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        placeholderLabel.text =
        "Sorunu mümkün olduğunca detaylı anlat..."

        placeholderLabel.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        placeholderLabel.textColor = secondaryTextColor
        placeholderLabel.numberOfLines = 2

        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false

        characterCountLabel.text =
            "0 / \(maximumMessageLength)"

        characterCountLabel.font = .systemFont(
            ofSize: 12,
            weight: .medium
        )

        characterCountLabel.textColor = secondaryTextColor
        characterCountLabel.textAlignment = .right

        messageContainer.addSubview(messageTextView)
        messageContainer.addSubview(placeholderLabel)
        messageContainer.addSubview(characterCountLabel)

        NSLayoutConstraint.activate([
            messageContainer.heightAnchor.constraint(
                equalToConstant: 220
            ),

            messageTextView.topAnchor.constraint(
                equalTo: messageContainer.topAnchor
            ),

            messageTextView.leadingAnchor.constraint(
                equalTo: messageContainer.leadingAnchor
            ),

            messageTextView.trailingAnchor.constraint(
                equalTo: messageContainer.trailingAnchor
            ),

            messageTextView.bottomAnchor.constraint(
                equalTo: messageContainer.bottomAnchor
            ),

            placeholderLabel.topAnchor.constraint(
                equalTo: messageContainer.topAnchor,
                constant: 17
            ),

            placeholderLabel.leadingAnchor.constraint(
                equalTo: messageContainer.leadingAnchor,
                constant: 17
            ),

            placeholderLabel.trailingAnchor.constraint(
                equalTo: messageContainer.trailingAnchor,
                constant: -17
            ),

            characterCountLabel.trailingAnchor.constraint(
                equalTo: messageContainer.trailingAnchor,
                constant: -16
            ),

            characterCountLabel.bottomAnchor.constraint(
                equalTo: messageContainer.bottomAnchor,
                constant: -12
            )
        ])
    }

    // MARK: - Send Button

    private func setupSendButton() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setTitle(
            "Sorunu Gönder",
            for: .normal
        )

        sendButton.setTitleColor(
            .white,
            for: .normal
        )

        sendButton.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .bold
        )

        sendButton.backgroundColor = primaryPink
        sendButton.layer.cornerRadius = 18

        sendButton.addTarget(
            self,
            action: #selector(didTapSend),
            for: .touchUpInside
        )

        sendButton.heightAnchor
            .constraint(equalToConstant: 56)
            .isActive = true

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        sendButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(
                equalTo: sendButton.centerXAnchor
            ),

            activityIndicator.centerYAnchor.constraint(
                equalTo: sendButton.centerYAnchor
            )
        ])
    }

    // MARK: - Technical Info

    private func setupPrivacyInfo() {
        privacyInfoView.backgroundColor =
            UIColor.white.withAlphaComponent(0.55)

        privacyInfoView.layer.cornerRadius = 18

        privacyIconView.translatesAutoresizingMaskIntoConstraints = false

        privacyIconView.image = UIImage(
            systemName: "info.circle"
        )

        privacyIconView.tintColor = primaryPink
        privacyIconView.contentMode = .scaleAspectFit

        privacyLabel.translatesAutoresizingMaskIntoConstraints = false

        privacyLabel.text =
        """
        Sorunu daha hızlı anlayabilmemiz için Lunora sürümü ve iOS sürümü gibi teknik bilgiler bildirime otomatik olarak eklenir.
        """

        privacyLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )

        privacyLabel.textColor = secondaryTextColor
        privacyLabel.numberOfLines = 0

        privacyInfoView.addSubview(privacyIconView)
        privacyInfoView.addSubview(privacyLabel)

        NSLayoutConstraint.activate([
            privacyIconView.leadingAnchor.constraint(
                equalTo: privacyInfoView.leadingAnchor,
                constant: 16
            ),

            privacyIconView.topAnchor.constraint(
                equalTo: privacyInfoView.topAnchor,
                constant: 17
            ),

            privacyIconView.widthAnchor.constraint(
                equalToConstant: 19
            ),

            privacyIconView.heightAnchor.constraint(
                equalToConstant: 19
            ),

            privacyLabel.topAnchor.constraint(
                equalTo: privacyInfoView.topAnchor,
                constant: 15
            ),

            privacyLabel.leadingAnchor.constraint(
                equalTo: privacyIconView.trailingAnchor,
                constant: 10
            ),

            privacyLabel.trailingAnchor.constraint(
                equalTo: privacyInfoView.trailingAnchor,
                constant: -16
            ),

            privacyLabel.bottomAnchor.constraint(
                equalTo: privacyInfoView.bottomAnchor,
                constant: -15
            )
        ])

        mainStackView.addArrangedSubview(privacyInfoView)
    }

    // MARK: - Actions

    @objc
    private func didTapBack() {
        navigationController?.popViewController(
            animated: true
        )
    }

    @objc
    private func didTapSend() {
        view.endEditing(true)

        guard !isSending else {
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            InternetRequiredAlert.show(on: self)
            return
        }

        guard let category = selectedCategory else {
            showInfoAlert(
                title: "Bir alan seç",
                message:
                    "Sorunun hangi alanla ilgili olduğunu seçebilir misin?"
            )

            return
        }

        let message =
            messageTextView.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard message.count >= 10 else {
            showInfoAlert(
                title: "Biraz daha anlatabilir misin?",
                message:
                    "Sorunu anlayabilmemiz için birkaç ayrıntı daha paylaşman bize yardımcı olur."
            )

            return
        }

        guard let user = Auth.auth().currentUser else {
            showInfoAlert(
                title: "Oturum bulunamadı",
                message:
                    "Sorun bildirebilmek için tekrar giriş yapman gerekiyor."
            )

            return
        }

        sendBugReport(
            user: user,
            category: category,
            message: message
        )
    }

    // MARK: - Firestore

    private func sendBugReport(
        user: User,
        category: IssueCategory,
        message: String
    ) {
        setSending(true)

        let appVersion =
            Bundle.main.infoDictionary?[
                "CFBundleShortVersionString"
            ] as? String ?? "unknown"

        let buildNumber =
            Bundle.main.infoDictionary?[
                "CFBundleVersion"
            ] as? String ?? "unknown"

        let device = UIDevice.current

        let data: [String: Any] = [
            "userId": user.uid,
            "userEmail": user.email ?? "",

            "category": category.rawValue,
            "message": message,

            "status": "new",
            "source": "ios",

            "deviceModel": device.model,
            "systemName": device.systemName,
            "iOSVersion": device.systemVersion,

            "appVersion": appVersion,
            "buildNumber": buildNumber,

            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("bugReports")
            .addDocument(data: data) { [weak self] error in

                DispatchQueue.main.async {

                    guard let self else {
                        return
                    }

                    self.setSending(false)

                    if let error {
                        print(
                            "Bug report error:",
                            error.localizedDescription
                        )

                        self.showInfoAlert(
                            title: "Bildirim gönderilemedi",
                            message:
                                "Bir sorun oluştu. Lütfen biraz sonra tekrar dene."
                        )

                        return
                    }

                    self.showSuccess()
                }
            }
    }

    // MARK: - Success

    private func showSuccess() {
        let alert = UIAlertController(
            title: "Bildirimin bize ulaştı 💗",
            message:
            """
            Paylaştığın için teşekkür ederiz. Sorununu dikkatle inceleyeceğiz.
            """,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Tamam",
                style: .default
            ) { [weak self] _ in

                self?
                    .navigationController?
                    .popViewController(
                        animated: true
                    )
            }
        )

        present(
            alert,
            animated: true
        )
    }

    // MARK: - Sending State

    private func updateSendButtonState() {
        let message =
            messageTextView.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let isValid =
            selectedCategory != nil
            && message.count >= 10
            && !isSending

        sendButton.isEnabled = isValid

        sendButton.alpha =
            isValid
            ? 1
            : 0.45
    }

    private func setSending(_ sending: Bool) {
        isSending = sending

        if sending {
            sendButton.setTitle(
                "",
                for: .normal
            )

            activityIndicator.startAnimating()

        } else {
            activityIndicator.stopAnimating()

            sendButton.setTitle(
                "Sorunu Gönder",
                for: .normal
            )
        }
    }

    // MARK: - Alerts

    private func showInfoAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Tamam",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }

    // MARK: - Keyboard

    private func setupDismissKeyboardGesture() {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        gesture.cancelsTouchesInView = false

        view.addGestureRecognizer(gesture)
    }

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension BugReportViewController: UITextViewDelegate {

    func textViewDidBeginEditing(
        _ textView: UITextView
    ) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.15
        ) { [weak self] in

            guard let self else {
                return
            }

            let rect = textView.convert(
                textView.bounds,
                to: self.scrollView
            )

            self.scrollView.scrollRectToVisible(
                rect.insetBy(
                    dx: 0,
                    dy: -30
                ),
                animated: true
            )
        }
    }

    func textViewDidChange(
        _ textView: UITextView
    ) {
        placeholderLabel.isHidden =
            !textView.text.isEmpty

        characterCountLabel.text =
            "\(textView.text.count) / \(maximumMessageLength)"

        updateSendButtonState()
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {

        guard
            let currentText = textView.text,
            let textRange = Range(
                range,
                in: currentText
            )
        else {
            return true
        }

        let updatedText =
            currentText.replacingCharacters(
                in: textRange,
                with: text
            )

        return updatedText.count
            <= maximumMessageLength
    }
}
