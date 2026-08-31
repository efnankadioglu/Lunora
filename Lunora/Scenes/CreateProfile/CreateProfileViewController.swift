//
//  CreateProfileViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.10.2025.
//

import UIKit
import TOCropViewController
import FirebaseAuth
import FirebaseFirestore

final class CreateProfileViewController: UIViewController,
                                         UIImagePickerControllerDelegate,
                                         UINavigationControllerDelegate,
                                         TOCropViewControllerDelegate {

    // MARK: - Device

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }


    // MARK: - Colors

    private enum Palette {

        static let primaryPink = UIColor(
            red: 232 / 255,
            green: 87 / 255,
            blue: 160 / 255,
            alpha: 1
        )

        static let titlePink = UIColor(
            red: 188 / 255,
            green: 83 / 255,
            blue: 140 / 255,
            alpha: 1
        )

        static let text = UIColor(
            red: 61 / 255,
            green: 37 / 255,
            blue: 51 / 255,
            alpha: 1
        )

        static let secondaryText = UIColor(
            red: 160 / 255,
            green: 112 / 255,
            blue: 140 / 255,
            alpha: 1
        )
    }


    // MARK: - State

    private let imagePicker = UIImagePickerController()

    private var selectedImage: UIImage?
    private var hasCustomAvatar = false
    
    private var hasAcceptedTerms = false
    private var hasReadPrivacyPolicy = false
    private var hasReadKVKK = false
    
    private let pendingEmailCredentials: PendingEmailCredentials?
    
    init(
        pendingEmailCredentials: PendingEmailCredentials? = nil
    ) {

        self.pendingEmailCredentials =
            pendingEmailCredentials

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {

        self.pendingEmailCredentials = nil

        super.init(coder: coder)
    }
    
    private var saveButtonTitle: String {

        if pendingEmailCredentials != nil {
            return "Hesabımı Oluştur"
        }

        return "Kaydet ve Devam Et"
    }
    
    // MARK: - Legal Consent

    private lazy var termsCheckboxButton: UIButton = {
        makeCheckboxButton(
            action: #selector(termsTapped)
        )
    }()

    private lazy var privacyCheckboxButton: UIButton = {
        makeCheckboxButton(
            action: #selector(privacyTapped)
        )
    }()

    private lazy var kvkkCheckboxButton: UIButton = {
        makeCheckboxButton(
            action: #selector(kvkkTapped)
        )
    }()

    private lazy var termsTextView: UITextView = {
        makeLegalTextView(
            documentName: "Kullanım Koşulları",
            suffix: "'nı okudum ve kabul ediyorum.",
            link: "lunora://terms"
        )
    }()

    private lazy var privacyTextView: UITextView = {
        makeLegalTextView(
            documentName: "Gizlilik Politikası",
            suffix: "'nı okudum ve bilgi edindim.",
            link: "lunora://privacy"
        )
    }()

    private lazy var kvkkTextView: UITextView = {
        makeLegalTextView(
            documentName: "KVKK Aydınlatma Metni",
            suffix: "'ni okudum ve bilgi edindim.",
            link: "lunora://kvkk"
        )
    }()

    private lazy var termsRowView: UIStackView = {
        makeConsentRow(
            checkbox: termsCheckboxButton,
            textView: termsTextView
        )
    }()

    private lazy var privacyRowView: UIStackView = {
        makeConsentRow(
            checkbox: privacyCheckboxButton,
            textView: privacyTextView
        )
    }()

    private lazy var kvkkRowView: UIStackView = {
        makeConsentRow(
            checkbox: kvkkCheckboxButton,
            textView: kvkkTextView
        )
    }()

    private lazy var legalStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                termsRowView,
                privacyRowView,
                kvkkRowView
            ]
        )

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()
    // MARK: - Background

    private let backgroundImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.image = UIImage(
            named: "welcome_background_phone"
        )

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()


    // MARK: - Scroll

    private let scrollView: UIScrollView = {

        let scrollView = UIScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true

        return scrollView
    }()


    private let contentView: UIView = {

        let view = UIView()

        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()


    // MARK: - Main Stack

    private let mainStackView: UIStackView = {

        let stack = UIStackView()

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 22

        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()


    // MARK: - Logo

    private let logoImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.image = UIImage(named: "lunora_logo")
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()


    // MARK: - Intro

    private let titleLabel: UILabel = {

        let label = UILabel()

        label.text = "Profilini oluşturalım"

        label.font = UIFont(
            name: "Georgia",
            size: 28
        ) ?? .systemFont(
            ofSize: 28,
            weight: .semibold
        )

        label.textColor = Palette.text
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()


    private let subtitleLabel: UILabel = {

        let label = UILabel()

        label.text =
            "Lunora deneyimini sana özel hale getirmek için birkaç bilgiye ihtiyacımız var."

        label.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        label.textColor = Palette.secondaryText

        label.textAlignment = .center
        label.numberOfLines = 0

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()


    private lazy var introStackView: UIStackView = {

        let stack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                subtitleLabel
            ]
        )

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        return stack
    }()


    // MARK: - Profile Card

    private let profileCardView: UIView = {

        let view = UIView()

        view.backgroundColor =
            UIColor.white.withAlphaComponent(0.58)

        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = CGSize(
            width: 0,
            height: 10
        )

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()


    // MARK: - Avatar

    private let avatarImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.image = UIImage(
            systemName: "person.crop.circle.fill"
        )

        imageView.tintColor = .systemGray4
        imageView.backgroundColor =
            UIColor.white.withAlphaComponent(0.8)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.layer.borderWidth = 3
        imageView.layer.borderColor =
            UIColor.white.cgColor

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()


    private lazy var cameraButton: UIButton = {

        let button = UIButton(type: .system)

        button.backgroundColor = Palette.primaryPink
        button.tintColor = .white

        let config = UIImage.SymbolConfiguration(
            pointSize: 12,
            weight: .medium
        )

        button.setImage(
            UIImage(
                systemName: "camera.fill",
                withConfiguration: config
            ),
            for: .normal
        )

        button.layer.cornerRadius = 15

        button.layer.borderWidth = 2
        button.layer.borderColor =
            UIColor.white.cgColor

        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(
            self,
            action: #selector(addPhotoButtonTapped),
            for: .touchUpInside
        )

        return button
    }()


    private let addPhotoLabel: UILabel = {

        let label = UILabel()

        label.text = "Profil fotoğrafı ekle"

        label.font = .systemFont(
            ofSize: 14,
            weight: .medium
        )

        label.textColor = Palette.titlePink
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()


    // MARK: - Inputs

    private lazy var nameInputView = ProfileInputView(
        title: "İSİM SOYİSİM",
        placeholder: "İsim soyisim",
        leadingIconName: "person",
        trailingIconName: nil
    )


    private lazy var usernameInputView = ProfileInputView(
        title: "KULLANICI ADI",
        placeholder: "Kullanıcı Adı",
        leadingIconName: "at",
        trailingIconName: nil
    )


    private lazy var motivationInputView = ProfileTextAreaView(
        title: "MOTİVASYON SÖZÜ",
        placeholder:
            "Sana ilham veren kısa bir söz yaz."
    )


    private lazy var formStackView: UIStackView = {

        let stack = UIStackView(
            arrangedSubviews: [
                nameInputView,
                usernameInputView,
                motivationInputView
            ]
        )

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 20

        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    // MARK: - Save Button

    private lazy var saveButton: GradientPrimaryButton = {

        let button = GradientPrimaryButton(type: .custom)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(
            saveButtonTitle,
            for: .normal
        )

        button.addTarget(
            self,
            action: #selector(saveAndContinueButtonTapped),
            for: .touchUpInside
        )

        return button
    }()

    private let footerLabel: UILabel = {

        let label = UILabel()

        label.text =
            "Bu, Lunora’daki yeni yolculuğunun başlangıcı ✨"

        label.font = .systemFont(
            ofSize: 14,
            weight: .regular
        )

        label.textColor = Palette.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImagePicker()
        setupUI()
        setupConstraints()
        configureInputs()
        setupKeyboard()
        updateSaveButtonState()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarImageView.layer.cornerRadius =
            avatarImageView.bounds.width / 2
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    // MARK: - Setup

    private func setupImagePicker() {

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }


    private func setupUI() {

        view.backgroundColor = UIColor(
            red: 1,
            green: 0.92,
            blue: 0.95,
            alpha: 1
        )

        view.addSubview(backgroundImageView)

        view.addSubview(scrollView)

        scrollView.addSubview(contentView)

        contentView.addSubview(mainStackView)

        profileCardView.addSubview(avatarImageView)
        profileCardView.addSubview(cameraButton)
        profileCardView.addSubview(addPhotoLabel)
        profileCardView.addSubview(formStackView)
        profileCardView.addSubview(legalStackView)
        profileCardView.addSubview(saveButton)
        profileCardView.addSubview(footerLabel)

        mainStackView.addArrangedSubview(logoImageView)
        mainStackView.addArrangedSubview(introStackView)
        mainStackView.addArrangedSubview(profileCardView)

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGesture)
    }


    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // MARK: - Background

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


            // MARK: - ScrollView

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


            // MARK: - ContentView

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


            // MARK: - Main Stack ortak

            mainStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: isPad ? 45 : 20
            ),

            mainStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -40
            ),


            // MARK: - Logo

            logoImageView.heightAnchor.constraint(
                equalToConstant: isPad ? 170 : 120
            ),


            // MARK: - Avatar

            avatarImageView.topAnchor.constraint(
                equalTo: profileCardView.topAnchor,
                constant: 30
            ),

            avatarImageView.centerXAnchor.constraint(
                equalTo: profileCardView.centerXAnchor
            ),

            avatarImageView.widthAnchor.constraint(
                equalToConstant: isPad ? 116 : 100
            ),

            avatarImageView.heightAnchor.constraint(
                equalTo: avatarImageView.widthAnchor
            ),


            // MARK: - Camera

            cameraButton.widthAnchor.constraint(
                equalToConstant: 30
            ),

            cameraButton.heightAnchor.constraint(
                equalToConstant: 30
            ),

            cameraButton.centerXAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: -7
            ),

            cameraButton.centerYAnchor.constraint(
                equalTo: avatarImageView.bottomAnchor,
                constant: -7
            ),


            // MARK: - Add Photo

            addPhotoLabel.topAnchor.constraint(
                equalTo: avatarImageView.bottomAnchor,
                constant: 10
            ),

            addPhotoLabel.centerXAnchor.constraint(
                equalTo: profileCardView.centerXAnchor
            ),


            // MARK: - Form

            formStackView.topAnchor.constraint(
                equalTo: addPhotoLabel.bottomAnchor,
                constant: 28
            ),

            formStackView.leadingAnchor.constraint(
                equalTo: profileCardView.leadingAnchor,
                constant: 28
            ),

            formStackView.trailingAnchor.constraint(
                equalTo: profileCardView.trailingAnchor,
                constant: -28
            ),


            // MARK: - Save Button

            legalStackView.topAnchor.constraint(
                equalTo: formStackView.bottomAnchor,
                constant: 24
            ),

            legalStackView.leadingAnchor.constraint(
                equalTo: profileCardView.leadingAnchor,
                constant: 28
            ),

            legalStackView.trailingAnchor.constraint(
                equalTo: profileCardView.trailingAnchor,
                constant: -28
            ),
            
            saveButton.topAnchor.constraint(
                equalTo: legalStackView.bottomAnchor,
                constant: 26
            ),

            saveButton.leadingAnchor.constraint(
                equalTo: profileCardView.leadingAnchor,
                constant: 28
            ),

            saveButton.trailingAnchor.constraint(
                equalTo: profileCardView.trailingAnchor,
                constant: -28
            ),

            saveButton.heightAnchor.constraint(
                equalToConstant: 58
            ),


            // MARK: - Footer

            footerLabel.topAnchor.constraint(
                equalTo: saveButton.bottomAnchor,
                constant: 16
            ),

            footerLabel.leadingAnchor.constraint(
                equalTo: profileCardView.leadingAnchor,
                constant: 30
            ),

            footerLabel.trailingAnchor.constraint(
                equalTo: profileCardView.trailingAnchor,
                constant: -30
            ),

            footerLabel.bottomAnchor.constraint(
                equalTo: profileCardView.bottomAnchor,
                constant: -25
            )
        ])


        // MARK: - iPhone Layout

        if !isPad {

            NSLayoutConstraint.activate([

                mainStackView.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 24
                ),

                mainStackView.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -24
                )
            ])

        }


        // MARK: - iPad Layout

        else {

            NSLayoutConstraint.activate([

                mainStackView.centerXAnchor.constraint(
                    equalTo: contentView.centerXAnchor
                ),

                mainStackView.widthAnchor.constraint(
                    equalToConstant: 560
                ),

                mainStackView.leadingAnchor.constraint(
                    greaterThanOrEqualTo: contentView.leadingAnchor,
                    constant: 30
                ),

                mainStackView.trailingAnchor.constraint(
                    lessThanOrEqualTo: contentView.trailingAnchor,
                    constant: -30
                )
            ])
        }
    }
    
    private func makeCheckboxButton(
        action: Selector
    ) -> UIButton {

        let button = UIButton(type: .system)

        let config = UIImage.SymbolConfiguration(
            pointSize: 23,
            weight: .regular
        )

        button.setImage(
            UIImage(
                systemName: "square",
                withConfiguration: config
            ),
            for: .normal
        )

        button.tintColor = Palette.secondaryText

        button.addTarget(
            self,
            action: action,
            for: .touchUpInside
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(
                equalToConstant: 32
            )
        ])

        return button
    }

    private func makeLegalTextView(
        documentName: String,
        suffix: String,
        link: String
    ) -> UITextView {

        let textView = UITextView()

        let fullText =
            "\(documentName)\(suffix)"

        let attributed =
            NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: UIFont.systemFont(
                        ofSize: 14,
                        weight: .regular
                    ),
                    .foregroundColor:
                        Palette.text
                ]
            )

        let documentRange =
            (fullText as NSString)
                .range(of: documentName)

        if let url = URL(string: link) {

            attributed.addAttributes(
                [
                    .link: url,
                    .foregroundColor:
                        Palette.primaryPink,
                    .underlineStyle:
                        NSUnderlineStyle.single.rawValue
                ],
                range: documentRange
            )
        }

        textView.attributedText =
            attributed

        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false

        textView.backgroundColor = .clear

        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        textView.delegate = self

        textView.linkTextAttributes = [
            .foregroundColor:
                Palette.primaryPink,

            .underlineStyle:
                NSUnderlineStyle.single.rawValue
        ]

        textView.translatesAutoresizingMaskIntoConstraints = false

        return textView
    }

    private func makeConsentRow(
        checkbox: UIButton,
        textView: UITextView
    ) -> UIStackView {

        let stack = UIStackView(
            arrangedSubviews: [
                checkbox,
                textView
            ]
        )

        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 8

        return stack
    }


    private func configureInputs() {

        nameInputView.textField.textContentType = .name

        nameInputView.textField.autocapitalizationType =
            .words

        nameInputView.textField.returnKeyType = .next


        usernameInputView.textField.autocapitalizationType =
            .none

        usernameInputView.textField.autocorrectionType =
            .no

        usernameInputView.textField.spellCheckingType =
            .no

        usernameInputView.textField.returnKeyType = .next
        
        usernameInputView.textField.addTarget(
            self,
            action: #selector(usernameDidChange),
            for: .editingChanged
        )


        motivationInputView.textView.returnKeyType =
            .done
    }
    
    @objc
    private func usernameDidChange() {

        let current =
            usernameInputView.textField.text ?? ""

        let normalized =
            current
                .lowercased()
                .replacingOccurrences(
                    of: " ",
                    with: ""
                )

        if current != normalized {
            usernameInputView.textField.text =
                normalized
        }

        usernameInputView.setError(nil)
    }


    // MARK: - Actions
    
    @objc
    private func termsTapped() {
        hasAcceptedTerms.toggle()

        updateConsentButton(
            termsCheckboxButton,
            checked: hasAcceptedTerms
        )

        updateSaveButtonState()
    }

    @objc
    private func privacyTapped() {
        hasReadPrivacyPolicy.toggle()

        updateConsentButton(
            privacyCheckboxButton,
            checked: hasReadPrivacyPolicy
        )

        updateSaveButtonState()
    }

    @objc
    private func kvkkTapped() {
        hasReadKVKK.toggle()

        updateConsentButton(
            kvkkCheckboxButton,
            checked: hasReadKVKK
        )

        updateSaveButtonState()
    }
    
    private func updateConsentButton(
        _ button: UIButton,
        checked: Bool
    ) {

        let symbol =
            checked
            ? "checkmark.square.fill"
            : "square"

        let config = UIImage.SymbolConfiguration(
            pointSize: 23,
            weight: .regular
        )

        button.setImage(
            UIImage(
                systemName: symbol,
                withConfiguration: config
            ),
            for: .normal
        )

        button.tintColor =
            checked
            ? Palette.primaryPink
            : Palette.secondaryText
    }
    
    private var allConsentsCompleted: Bool {
        hasAcceptedTerms &&
        hasReadPrivacyPolicy &&
        hasReadKVKK
    }

    private func updateSaveButtonState() {

        saveButton.isEnabled =
            allConsentsCompleted

        saveButton.alpha =
            allConsentsCompleted
            ? 1.0
            : 0.45
    }

    @objc
    private func addPhotoButtonTapped() {

        present(
            imagePicker,
            animated: true
        )
    }
    
    @objc
    private func saveAndContinueButtonTapped() {
        
        view.endEditing(true)
        
        guard allConsentsCompleted else {
            
            showAlert(
                title: "Devam etmek için",
                message:
                    "Kullanım Koşulları, Gizlilik Politikası ve KVKK Aydınlatma Metni alanlarını tamamlamalısın."
            )
            
            return
        }
        
        let name =
        nameInputView.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        
        let username =
        normalizedUsername(
            usernameInputView.text
        )
        
        let motivation =
        motivationInputView.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        
        
        // MARK: - Name
        
        guard !name.isEmpty else {
            
            nameInputView.setError(
                "Lütfen ismini gir."
            )
            
            nameInputView.textField
                .becomeFirstResponder()
            
            return
        }
        
        nameInputView.setError(nil)
        
        
        // MARK: - Username format
        
        if let errorMessage =
            usernameValidationError(username) {
            
            usernameInputView.setError(
                errorMessage
            )
            
            usernameInputView.textField
                .becomeFirstResponder()
            
            return
        }
        
        usernameInputView.setError(nil)
        
        // MARK: - Username uniqueness
        
        let excludedUID =
        Auth.auth().currentUser?.uid
        ?? "__pending_email_registration__"
        
        guard ProfileStore.shared.isUsernameAvailable(
            username,
            excluding: excludedUID
        ) else {
            
            usernameInputView.setError(
                "Bu kullanıcı adı zaten kullanılıyor."
            )
            
            usernameInputView.textField
                .becomeFirstResponder()
            
            return
        }
        
        usernameInputView.setError(nil)
        
        let avatar =
        hasCustomAvatar
        ? avatarImageView.image
        : nil
        
        setSaving(true)
        
        // MARK: - Email Registration
        
        if let credentials =
            pendingEmailCredentials {
            
            createEmailAccountAndProfile(
                credentials: credentials,
                name: name,
                username: username,
                motivation: motivation,
                avatar: avatar
            )
            
            return
        }
        
        // MARK: - Google / Apple
        
        guard let uid =
                Auth.auth().currentUser?.uid
        else {
            
            setSaving(false)
            
            showAlert(
                title: "Oturum bulunamadı",
                message:
                    "Profil oluşturmak için tekrar giriş yapmalısın."
            )
            
            return
        }
        
        finishProfileCreation(
            uid: uid,
            name: name,
            username: username,
            motivation: motivation,
            avatar: avatar
        )
    }
    
    private func createEmailAccountAndProfile(
        credentials: PendingEmailCredentials,
        name: String,
        username: String,
        motivation: String,
        avatar: UIImage?
    ) {

        Auth.auth().createUser(
            withEmail: credentials.email,
            password: credentials.password
        ) { [weak self] result, error in

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }

                if let error = error {

                    self.setSaving(false)

                    let nsError = error as NSError

                    if nsError.code ==
                        AuthErrorCode.emailAlreadyInUse.rawValue {

                        self.showAlert(
                            title: "Bu e-posta zaten kayıtlı",
                            message:
                                "Bu e-posta adresiyle daha önce bir hesap oluşturulmuş. Giriş yapmayı deneyebilirsin."
                        )

                    } else {

                        self.showAlert(
                            title: "Hesap oluşturulamadı",
                            message:
                                "Bir sorun oluştu. Lütfen tekrar dene."
                        )
                    }

                    return
                }

                guard let uid =
                    result?.user.uid
                else {

                    self.setSaving(false)

                    self.showAlert(
                        title: "Hesap oluşturulamadı",
                        message:
                            "Kullanıcı bilgisi alınamadı. Lütfen tekrar dene."
                    )

                    return
                }

                self.finishProfileCreation(
                    uid: uid,
                    name: name,
                    username: username,
                    motivation: motivation,
                    avatar: avatar
                )
            }
        }
    }
    
    
    private func finishProfileCreation(
        uid: String,
        name: String,
        username: String,
        motivation: String,
        avatar: UIImage?
    ) {

        do {

            _ = try ProfileStore.shared.saveProfile(
                uid: uid,
                name: name,
                username: username,
                motivation: motivation,
                avatar: avatar
            )

        } catch {

            setSaving(false)

            showAlert(
                title: "Profil kaydedilemedi",
                message:
                    "Profil oluşturuldu ancak cihaz kaydı tamamlanamadı."
            )

            return
        }


        ProfileSyncService.shared
            .pushProfileToRemote(
                uid: uid,
                name: name,
                username: username,
                motivation: motivation,
                avatar: avatar
            ) { [weak self] error in

                DispatchQueue.main.async {

                    guard let self else {
                        return
                    }

                    if let error {
                        self.setSaving(false)

                        print(
                            "Remote push error:",
                            error
                        )

                        self.showAlert(
                            title:
                                "Senkronizasyon Hatası",
                            message:
                                "Profil oluşturuldu ancak bazı bilgiler buluta aktarılırken sorun oluştu."
                        )

                        return
                    }

                    GuidedOnboardingManager.shared.start(
                        for: uid
                    )

                    print(
                        "🧭 GUIDED: Profil oluşturuldu → onboarding başladı"
                    )

                    self.routeToMainApp()

                }
            }
    }


    private func setSaving(_ saving: Bool) {

        saveButton.isEnabled = !saving

        saveButton.configuration?
            .showsActivityIndicator = saving

        saveButton.configuration?.title =
            saving
                ? nil
                : saveButtonTitle
    }
    
    


    // MARK: - Validation

    private func normalizedUsername(
        _ username: String
    ) -> String {

        username
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }


    private func usernameValidationError(
        _ username: String
    ) -> String? {

        let username =
            normalizedUsername(username)


        // Boş olamaz
        if username.isEmpty {
            return "Bir kullanıcı adı seçmelisin."
        }


        // Minimum
        if username.count < 3 {
            return "Kullanıcı adı en az 3 karakter olmalı."
        }


        // Maximum
        if username.count > 20 {
            return "Kullanıcı adı en fazla 20 karakter olabilir."
        }


        // İlk karakter harf olmalı.
        // Sadece a-z, 0-9 ve _ kabul edilir.
        let regex =
            "^[a-z][a-z0-9_]{2,19}$"

        let predicate =
            NSPredicate(
                format: "SELF MATCHES %@",
                regex
            )


        if !predicate.evaluate(
            with: username
        ) {

            return "Kullanıcı adı bir harfle başlamalı; yalnızca harf, rakam ve _ kullanabilirsin."
        }


        // Son karakter _ olamaz
        if username.hasSuffix("_") {

            return "Kullanıcı adı _ ile bitemez."
        }


        // Çift underscore yok
        if username.contains("__") {

            return "Arka arkaya iki _ kullanamazsın."
        }


        // Lunora sistem isimleri
        let reservedUsernames: Set<String> = [
            "lunora",
            "admin",
            "administrator",
            "support",
            "help",
            "official",
            "system",
            "moderator",
            "staff"
        ]


        if reservedUsernames.contains(
            username
        ) {

            return "Bu kullanıcı adı kullanılamaz."
        }


        return nil
    }


    // MARK: - Routing

    private func routeToMainApp() {

        guard
            let scene = view.window?.windowScene,
            let sceneDelegate = scene.delegate as? SceneDelegate,
            let uid = Auth.auth().currentUser?.uid
        else {
            return
        }

        let firstExperienceCoordinator =
            FirstExperienceCoordinator(
                userID: uid
            )

        if firstExperienceCoordinator.shouldStartFirstExperience {

            let firstExperience =
                sceneDelegate.buildFirstExperience(
                    coordinator: firstExperienceCoordinator
                )

            sceneDelegate.setRoot(
                firstExperience,
                animated: true
            )

        } else {

            let tab =
                sceneDelegate.buildMainTabBar()

            sceneDelegate.setRoot(
                tab,
                animated: true
            )
        }
    }
    
    // MARK: - Legal Documents

    private func showLegalDocument(
        _ type: LegalDocumentType
    ) {

        let controller =
            LegalDocumentViewController(
                type: type
            )

        let navigationController =
            UINavigationController(
                rootViewController: controller
            )

        navigationController.modalPresentationStyle =
            .pageSheet

        if let sheet =
            navigationController
                .sheetPresentationController {

            sheet.detents = [
                .large()
            ]

            sheet.prefersGrabberVisible =
                true
        }

        present(
            navigationController,
            animated: true
        )
    }


    // MARK: - Alerts

    private func showAlert(
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


    // MARK: - Image Picker

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info:
            [UIImagePickerController.InfoKey: Any]
    ) {

        selectedImage =
            info[.originalImage] as? UIImage

        picker.dismiss(
            animated: true
        ) { [weak self] in

            guard
                let self,
                let selectedImage =
                    self.selectedImage
            else {
                return
            }

            let cropViewController =
                TOCropViewController(
                    croppingStyle: .circular,
                    image: selectedImage
                )

            cropViewController.delegate = self

            cropViewController.title =
                "Fotoğrafını ayarla"

            self.present(
                cropViewController,
                animated: true
            )
        }
    }


    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {

        picker.dismiss(
            animated: true
        )
    }


    // MARK: - Crop

    func cropViewController(
        _ cropViewController:
            TOCropViewController,
        didFinishCancelled cancelled: Bool
    ) {

        cropViewController.dismiss(
            animated: true
        )
    }


    func cropViewController(
        _ cropViewController:
            TOCropViewController,
        didCropToCircularImage image: UIImage,
        with cropRect: CGRect,
        angle: Int
    ) {

        avatarImageView.image = image

        hasCustomAvatar = true
        selectedImage = nil

        cropViewController.dismiss(
            animated: true
        )
    }


    // MARK: - Keyboard

    private func setupKeyboard() {

        NotificationCenter.default.addObserver(
            self,
            selector:
                #selector(keyboardWillChangeFrame),
            name:
                UIResponder
                    .keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector:
                #selector(keyboardWillHide),
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
            let frame =
                notification.userInfo?[
                    UIResponder
                        .keyboardFrameEndUserInfoKey
                ] as? CGRect
        else {
            return
        }

        let frameInView =
            view.convert(
                frame,
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
            .bottom = overlap
    }


    @objc
    private func keyboardWillHide() {

        scrollView.contentInset.bottom = 0

        scrollView
            .verticalScrollIndicatorInsets
            .bottom = 0
    }


    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension CreateProfileViewController:
    UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {

        switch URL.host {

        case "terms":
            showLegalDocument(
                .terms
            )

        case "privacy":
            showLegalDocument(
                .privacy
            )

        case "kvkk":
            showLegalDocument(
                .kvkk
            )

        default:
            break
        }

        return false
    }
}
