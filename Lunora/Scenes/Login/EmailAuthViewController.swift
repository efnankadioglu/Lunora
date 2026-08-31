//
//  EmailAuthViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.08.2026.
//

import UIKit
import FirebaseAuth

final class EmailAuthViewController: UIViewController {

    // MARK: - Palette

    private enum Palette {

        static let backgroundTop = UIColor(
            red: 255 / 255,
            green: 224 / 255,
            blue: 238 / 255,
            alpha: 1
        )

        static let backgroundBottom = UIColor(
            red: 255 / 255,
            green: 244 / 255,
            blue: 248 / 255,
            alpha: 1
        )

        static let primaryText = UIColor(
            red: 92 / 255,
            green: 58 / 255,
            blue: 112 / 255,
            alpha: 1
        )

        static let secondaryText = UIColor(
            red: 135 / 255,
            green: 105 / 255,
            blue: 139 / 255,
            alpha: 1
        )

        static let link = UIColor(
            red: 226 / 255,
            green: 79 / 255,
            blue: 151 / 255,
            alpha: 1
        )

        static let fieldBackground =
            UIColor.white.withAlphaComponent(0.82)

        static let fieldBorder = UIColor(
            red: 247 / 255,
            green: 180 / 255,
            blue: 214 / 255,
            alpha: 0.65
        )

        static let placeholder = UIColor(
            red: 172 / 255,
            green: 151 / 255,
            blue: 169 / 255,
            alpha: 1
        )
    }

    // MARK: - Callback

    var onAuthenticationSuccess: (() -> Void)?

    // MARK: - State

    private var isRegisterMode = false
    private var isLoading = false

    // MARK: - Background

    private let backgroundGradientLayer = CAGradientLayer()

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.alwaysBounceVertical = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    // MARK: - Close Button

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)

        button.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 19,
                    weight: .medium
                )
            ),
            for: .normal
        )

        button.tintColor = Palette.primaryText

        button.backgroundColor =
            UIColor.white.withAlphaComponent(0.72)

        button.layer.cornerRadius = 22
        button.layer.cornerCurve = .continuous

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(
            width: 0,
            height: 4
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(
            self,
            action: #selector(closeTapped),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: - Title

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.text = "E-posta ile devam et"
        label.textAlignment = .center
        label.numberOfLines = 0

        label.font = UIFont(
            name: "Georgia",
            size: 30
        ) ?? UIFont.systemFont(
            ofSize: 30,
            weight: .semibold
        )

        label.textColor = Palette.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Subtitle

    private let subtitleLabel: UILabel = {
        let label = UILabel()

        label.text = "Lunora hesabına giriş yap."
        label.textAlignment = .center
        label.numberOfLines = 0

        label.font = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        )

        label.textColor = Palette.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Email

    private lazy var emailTextField: UITextField = {
        let field = makeTextField(
            placeholder: "E-posta"
        )

        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no

        field.returnKeyType = .next
        field.delegate = self

        return field
    }()

    // MARK: - Password

    private lazy var passwordTextField: UITextField = {
        let field = makeTextField(
            placeholder: "Şifre"
        )

        field.isSecureTextEntry = true
        field.textContentType = .password

        field.autocapitalizationType = .none
        field.autocorrectionType = .no

        field.returnKeyType = .done
        field.delegate = self

        let eyeButton = UIButton(type: .system)

        eyeButton.setImage(
            UIImage(systemName: "eye"),
            for: .normal
        )

        eyeButton.tintColor = Palette.secondaryText

        eyeButton.frame = CGRect(
            x: 0,
            y: 0,
            width: 50,
            height: 56
        )

        eyeButton.addTarget(
            self,
            action: #selector(togglePasswordVisibility(_:)),
            for: .touchUpInside
        )

        field.rightView = eyeButton
        field.rightViewMode = .always

        return field
    }()

    // MARK: - Forgot Password

    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)

        button.setAttributedTitle(
            linkTitle("Şifremi unuttum"),
            for: .normal
        )

        button.contentHorizontalAlignment = .trailing

        button.addTarget(
            self,
            action: #selector(forgotPasswordTapped),
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Primary Button

    private lazy var continueButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton(
            frame: .zero
        )

        button.setTitle(
            "Giriş Yap",
            for: .normal
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(
            self,
            action: #selector(continueTapped),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: - Change Mode

    private lazy var changeModeButton: UIButton = {
        let button = UIButton(type: .system)

        button.setAttributedTitle(
            registerModeTitle(
                prefix: "Hesabın yok mu? ",
                action: "Kayıt ol"
            ),
            for: .normal
        )

        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.textAlignment = .center

        button.addTarget(
            self,
            action: #selector(changeModeTapped),
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Form Stack

    private lazy var formStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                emailTextField,
                passwordTextField,
                forgotPasswordButton,
                continueButton,
                changeModeButton
            ]
        )

        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 12

        stack.setCustomSpacing(
            8,
            after: passwordTextField
        )

        stack.setCustomSpacing(
            22,
            after: forgotPasswordButton
        )

        stack.setCustomSpacing(
            20,
            after: continueButton
        )

        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupView()
        setupLayout()
        setupKeyboard()
        setupTapGesture()
        updateContinueButtonState()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundGradientLayer.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Background

    private func setupBackground() {

        backgroundGradientLayer.colors = [
            Palette.backgroundTop.cgColor,
            Palette.backgroundBottom.cgColor
        ]

        backgroundGradientLayer.startPoint = CGPoint(
            x: 0.5,
            y: 0
        )

        backgroundGradientLayer.endPoint = CGPoint(
            x: 0.5,
            y: 1
        )

        view.layer.insertSublayer(
            backgroundGradientLayer,
            at: 0
        )
    }

    // MARK: - Setup View

    private func setupView() {

        view.backgroundColor =
            Palette.backgroundBottom

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formStackView)
    }

    // MARK: - Layout

    private func setupLayout() {

        NSLayoutConstraint.activate([

            // Scroll

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

            // Content

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

            // Close Button

            closeButton.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 24
            ),

            closeButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            closeButton.widthAnchor.constraint(
                equalToConstant: 44
            ),

            closeButton.heightAnchor.constraint(
                equalToConstant: 44
            ),

            // Title

            titleLabel.topAnchor.constraint(
                equalTo: closeButton.bottomAnchor,
                constant: 65
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 28
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -28
            ),

            // Subtitle

            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 12
            ),

            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 30
            ),

            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -30
            ),

            // Form

            formStackView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: 40
            ),

            formStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 30
            ),

            formStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -30
            ),

            formStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -40
            ),

            // Heights

            emailTextField.heightAnchor.constraint(
                equalToConstant: 58
            ),

            passwordTextField.heightAnchor.constraint(
                equalToConstant: 58
            ),

            forgotPasswordButton.heightAnchor.constraint(
                equalToConstant: 32
            ),

            continueButton.heightAnchor.constraint(
                equalToConstant: 58
            ),

            changeModeButton.heightAnchor.constraint(
                equalToConstant: 34
            )
        ])
    }

    // MARK: - Text Field Factory

    private func makeTextField(
        placeholder: String
    ) -> UITextField {

        let field = UITextField()

        field.backgroundColor =
            Palette.fieldBackground

        field.textColor =
            Palette.primaryText

        field.tintColor =
            Palette.link

        field.font = UIFont.systemFont(
            ofSize: 17,
            weight: .regular
        )

        field.layer.cornerRadius = 18
        field.layer.cornerCurve = .continuous

        field.layer.borderWidth = 1

        field.layer.borderColor =
            Palette.fieldBorder.cgColor

        field.layer.shadowColor =
            UIColor.black.cgColor

        field.layer.shadowOpacity = 0.035
        field.layer.shadowRadius = 10

        field.layer.shadowOffset = CGSize(
            width: 0,
            height: 4
        )

        field.attributedPlaceholder =
            NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor:
                        Palette.placeholder
                ]
            )

        let padding = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 18,
                height: 1
            )
        )

        field.leftView = padding
        field.leftViewMode = .always

        field.translatesAutoresizingMaskIntoConstraints = false

        return field
    }

    // MARK: - Link Styling

    private func linkTitle(
        _ text: String
    ) -> NSAttributedString {

        return NSAttributedString(
            string: text,
            attributes: [
                .font:
                    UIFont.systemFont(
                        ofSize: 14,
                        weight: .semibold
                    ),

                .foregroundColor:
                    Palette.link,

                .underlineStyle:
                    NSUnderlineStyle.single.rawValue
            ]
        )
    }

    private func registerModeTitle(
        prefix: String,
        action: String
    ) -> NSAttributedString {

        let result =
            NSMutableAttributedString(
                string: prefix,
                attributes: [
                    .font:
                        UIFont.systemFont(
                            ofSize: 15,
                            weight: .regular
                        ),

                    .foregroundColor:
                        Palette.secondaryText
                ]
            )

        result.append(
            NSAttributedString(
                string: action,
                attributes: [
                    .font:
                        UIFont.systemFont(
                            ofSize: 15,
                            weight: .semibold
                        ),

                    .foregroundColor:
                        Palette.link,

                    .underlineStyle:
                        NSUnderlineStyle.single.rawValue
                ]
            )
        )

        return result
    }

    // MARK: - Close

    @objc
    private func closeTapped() {

        view.endEditing(true)

        dismiss(
            animated: true
        )
    }

    // MARK: - Password Visibility

    @objc
    private func togglePasswordVisibility(
        _ sender: UIButton
    ) {

        passwordTextField.isSecureTextEntry.toggle()

        let imageName =
            passwordTextField.isSecureTextEntry
            ? "eye"
            : "eye.slash"

        sender.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }

    // MARK: - Continue Button State

    private func updateContinueButtonState() {

        continueButton.isEnabled = !isLoading

        continueButton.alpha =
            isLoading ? 0.65 : 1.0

        if isLoading {

            continueButton.setTitle(
                "Lütfen bekle...",
                for: .normal
            )

        } else {

            continueButton.setTitle(
                isRegisterMode
                    ? "Devam Et"
                    : "Giriş Yap",
                for: .normal
            )
        }
    }

    // MARK: - Continue

    @objc
    private func continueTapped() {

        view.endEditing(true)

        guard
            let email =
                emailTextField.text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
            !email.isEmpty
        else {

            showAlert(
                title: "E-posta gerekli",
                message:
                    "Devam etmek için e-posta adresini gir."
            )

            return
        }

        guard
            email.contains("@"),
            email.contains(".")
        else {

            showAlert(
                title: "Geçersiz e-posta",
                message:
                    "Geçerli bir e-posta adresi gir."
            )

            return
        }

        guard
            let password = passwordTextField.text,
            !password.isEmpty
        else {

            showAlert(
                title: "Şifre gerekli",
                message:
                    "Devam etmek için şifreni gir."
            )

            return
        }

        guard password.count >= 6 else {

            showAlert(
                title: "Şifre çok kısa",
                message:
                    "Şifren en az 6 karakter olmalı."
            )

            return
        }

        setLoading(true)

        if isRegisterMode {

            continueToCreateProfile(
                email: email,
                password: password
            )

        } else {

            login(
                email: email,
                password: password
            )
        }    }
    
    
    private func continueToCreateProfile(
        email: String,
        password: String
    ) {

        let credentials = PendingEmailCredentials(
            email: email,
            password: password
        )

        let controller = CreateProfileViewController(
            pendingEmailCredentials: credentials
        )

        controller.modalPresentationStyle = .fullScreen

        present(
            controller,
            animated: true
        ) { [weak self] in
            self?.setLoading(false)
        }
    }

    // MARK: - Login

    private func login(
        email: String,
        password: String
    ) {

        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { [weak self] _, error in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                self.setLoading(false)

                if let error = error {

                    self.showAlert(
                        title: "Giriş yapılamadı",
                        message:
                            self.authErrorMessage(error)
                    )

                    return
                }

                self.completeAuthentication()
            }
        }
    }

    // MARK: - Register

    

    // MARK: - Complete Authentication

    private func completeAuthentication() {

        dismiss(
            animated: true
        ) { [weak self] in

            self?.onAuthenticationSuccess?()
        }
    }

    // MARK: - Login / Register Mode

    @objc
    private func changeModeTapped() {

        view.endEditing(true)

        isRegisterMode.toggle()

        if isRegisterMode {

            titleLabel.text =
                "Hesabını oluştur"

            subtitleLabel.text =
                "E-posta adresin ve şifrenle Lunora'ya katıl."

            forgotPasswordButton.isHidden = true

            passwordTextField.textContentType =
                .newPassword

            passwordTextField.text = ""

            changeModeButton.setAttributedTitle(
                registerModeTitle(
                    prefix: "Zaten hesabın var mı? ",
                    action: "Giriş yap"
                ),
                for: .normal
            )

        } else {

            titleLabel.text =
                "E-posta ile devam et"

            subtitleLabel.text =
                "Lunora hesabına giriş yap."

            forgotPasswordButton.isHidden = false

            passwordTextField.textContentType =
                .password

            passwordTextField.text = ""

            changeModeButton.setAttributedTitle(
                registerModeTitle(
                    prefix: "Hesabın yok mu? ",
                    action: "Kayıt ol"
                ),
                for: .normal
            )
        }

        updateContinueButtonState()
    }

    // MARK: - Forgot Password

    @objc
    private func forgotPasswordTapped() {

        view.endEditing(true)

        guard
            let email =
                emailTextField.text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
            !email.isEmpty
        else {

            showAlert(
                title: "E-posta gerekli",
                message:
                    "Şifre yenileme bağlantısını gönderebilmemiz için önce e-posta adresini gir."
            )

            return
        }

        guard
            email.contains("@"),
            email.contains(".")
        else {

            showAlert(
                title: "Geçersiz e-posta",
                message:
                    "Geçerli bir e-posta adresi gir."
            )

            return
        }

        Auth.auth().sendPasswordReset(
            withEmail: email
        ) { [weak self] error in

            DispatchQueue.main.async {

                if let error = error {

                    self?.showAlert(
                        title: "Gönderilemedi",
                        message:
                            self?.authErrorMessage(error)
                            ?? "Bir hata oluştu."
                    )

                    return
                }

                self?.showAlert(
                    title: "E-posta gönderildi",
                    message:
                        "Şifre yenileme bağlantısını e-posta adresine gönderdik."
                )
            }
        }
    }

    // MARK: - Loading

    private func setLoading(
        _ loading: Bool
    ) {

        isLoading = loading

        emailTextField.isEnabled = !loading
        passwordTextField.isEnabled = !loading
        forgotPasswordButton.isEnabled = !loading
        changeModeButton.isEnabled = !loading

        updateContinueButtonState()
    }

    // MARK: - Firebase Error

    private func authErrorMessage(
        _ error: Error
    ) -> String {

        let nsError = error as NSError

        guard
            let code =
                AuthErrorCode(
                    rawValue: nsError.code
                )
        else {

            return
                "Bir hata oluştu. Lütfen tekrar dene."
        }

        switch code {

        case .invalidEmail:
            return
                "Girdiğin e-posta adresi geçerli görünmüyor."

        case .emailAlreadyInUse:
            return
                "Bu e-posta adresiyle daha önce bir hesap oluşturulmuş."

        case .weakPassword:
            return
                "Bu şifre yeterince güçlü değil. Daha güçlü bir şifre seç."

        case .userNotFound:
            return
                "Bu e-posta adresiyle eşleşen bir hesap bulunamadı."

        case .wrongPassword:
            return
                "E-posta adresin veya şifren hatalı."

        case .invalidCredential:
            return
                "E-posta adresin veya şifren hatalı."

        case .userDisabled:
            return
                "Bu hesap şu anda kullanılamıyor."

        case .networkError:
            return
                "İnternet bağlantını kontrol edip tekrar dene."

        case .tooManyRequests:
            return
                "Çok fazla deneme yapıldı. Bir süre sonra tekrar dene."

        default:
            return
                "İşlem tamamlanamadı. Lütfen tekrar dene."
        }
    }

    // MARK: - Keyboard

    private func setupKeyboard() {

        NotificationCenter.default.addObserver(
            self,
            selector:
                #selector(
                    keyboardWillChangeFrame(_:)
                ),
            name:
                UIResponder
                    .keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector:
                #selector(
                    keyboardWillHide(_:)
                ),
            name:
                UIResponder
                    .keyboardWillHideNotification,
            object: nil
        )
    }

    @objc
    private func keyboardWillChangeFrame(
        _ notification: Notification
    ) {

        guard
            let keyboardFrame =
                notification.userInfo?[
                    UIResponder
                        .keyboardFrameEndUserInfoKey
                ] as? CGRect
        else {
            return
        }

        let frameInView =
            view.convert(
                keyboardFrame,
                from: nil
            )

        let overlap =
            max(
                0,
                view.bounds.maxY
                    - frameInView.minY
            )

        scrollView.contentInset.bottom =
            overlap + 20

        scrollView
            .verticalScrollIndicatorInsets
            .bottom =
            overlap + 20
    }

    @objc
    private func keyboardWillHide(
        _ notification: Notification
    ) {

        scrollView.contentInset.bottom = 0

        scrollView
            .verticalScrollIndicatorInsets
            .bottom = 0
    }

    // MARK: - Tap Outside

    private func setupTapGesture() {

        let tap =
            UITapGestureRecognizer(
                target: self,
                action:
                    #selector(
                        dismissKeyboard
                    )
            )

        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }

    @objc
    private func dismissKeyboard() {

        view.endEditing(true)
    }

    // MARK: - Alert

    private func showAlert(
        title: String,
        message: String
    ) {

        let alert =
            UIAlertController(
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
}

// MARK: - UITextFieldDelegate

extension EmailAuthViewController: UITextFieldDelegate {

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        if textField === emailTextField {

            passwordTextField
                .becomeFirstResponder()

        } else {

            textField.resignFirstResponder()

            continueTapped()
        }

        return true
    }
}
