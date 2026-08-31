//
//  EditProfileViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 13.07.2026.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - EditProfileViewController

final class EditProfileViewController: UIViewController {

    // MARK: Firebase paths and fields

    /// Existing Lunora profile path:
    /// profiles/{uid}
    private enum FirebasePath {
        static let profiles = "profiles"
        static let usernames = "usernames"
        static let profileImages = "profile_images"
    }

    private enum Field {
        static let uid = "uid"
        static let name = "name"
        static let username = "username"
        static let usernameLowercase = "usernameLowercase"
        static let birthDate = "birthDate"
        static let socialMediaURL = "socialMediaURL"
        static let motivation = "motivation"
        static let profileImageURL = "profileImageURL"
        static let updatedAt = "updatedAt"
    }

    // MARK: State

    private struct EditableProfile: Equatable {
        var name: String
        var username: String
        var birthDate: Date?
        var socialMediaURL: String
        var motivation: String
        var profileImageURL: String?

        static let empty = EditableProfile(
            name: "",
            username: "",
            birthDate: nil,
            socialMediaURL: "",
            motivation: "",
            profileImageURL: nil
        )
    }

    private enum ScreenState {
        case loading
        case content
        case saving
        case error
    }

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private var originalProfile: EditableProfile = .empty
    private var selectedProfileImage: UIImage?
    private var screenState: ScreenState = .loading

    private var hasUnsavedChanges: Bool {
        currentFormProfile != originalProfile || selectedProfileImage != nil
    }

    private var currentFormProfile: EditableProfile {
        EditableProfile(
            name: normalizedName(nameInputView.text),
            username: normalizedUsername(usernameInputView.text),
            birthDate: selectedBirthDate,
            socialMediaURL: normalizedSocialURL(socialInputView.text),
            motivation: motivationInputView.text.trimmingCharacters(in: .whitespacesAndNewlines),
            profileImageURL: originalProfile.profileImageURL
        )
    }

    private var selectedBirthDate: Date?

    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    /// Birth date is a date-only value, so it is saved as yyyy-MM-dd.
    /// This avoids a birthday shifting by one day because of time-zone conversion.
    private lazy var storageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: Palette

    private enum Palette {
        static let pageBackground = UIColor(
            red: 255 / 255,
            green: 243 / 255,
            blue: 248 / 255,
            alpha: 1
        )

        static let primaryPink = UIColor(
            red: 232 / 255,
            green: 87 / 255,
            blue: 160 / 255,
            alpha: 1
        )

        static let bannerPink = UIColor(
            red: 241 / 255,
            green: 105 / 255,
            blue: 181 / 255,
            alpha: 1
        )

        static let borderPink = UIColor(
            red: 247 / 255,
            green: 167 / 255,
            blue: 207 / 255,
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
            red: 204 / 255,
            green: 116 / 255,
            blue: 164 / 255,
            alpha: 1
        )
    }

    // MARK: Main layout

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .interactive
        view.alwaysBounceVertical = true
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 20
        return stack
    }()

    // MARK: Header

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Geri"
        configuration.image = UIImage(systemName: "chevron.left")
        configuration.imagePadding = 5
        configuration.contentInsets = .zero
        configuration.baseForegroundColor = Palette.titlePink
        button.configuration = configuration

        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()

    private let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Profili Düzenle"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = Palette.text
        label.textAlignment = .center
        return label
    }()

    // MARK: Profile card

    private let profileCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.clipsToBounds = true
        return view
    }()

    private let bannerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Palette.bannerPink
        return view
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .systemGray4
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.layer.cornerRadius = 43
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor

        return imageView
    }()

    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.backgroundColor = Palette.primaryPink
        button.tintColor = .white

        let image = UIImage(
            systemName: "camera.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 9,
                weight: .semibold
            )
        )

        button.setImage(image, for: .normal)

        button.layer.cornerRadius = 13
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true

        button.addTarget(
            self,
            action: #selector(cameraButtonTapped),
            for: .touchUpInside
        )

        return button
    }()
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = Palette.text
        label.numberOfLines = 1
        return label
    }()

    private let profileUsernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = Palette.titlePink
        label.numberOfLines = 1
        return label
    }()

    private lazy var identityStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            profileNameLabel,
            profileUsernameLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 3
        return stack
    }()

    // MARK: Form

    private lazy var nameInputView = ProfileInputView(
        title: "İSİM SOYİSİM",
        placeholder: "İsim soyisim",
        leadingIconName: "person",
        trailingIconName: nil
    )

    private lazy var usernameInputView = ProfileInputView(
        title: "KULLANICI ADI",
        placeholder: "kullanici.adi",
        leadingIconName: "at",
        trailingIconName: "checkmark"
    )

    private lazy var birthDateInputView = ProfileInputView(
        title: "DOĞUM TARİHİ",
        placeholder: "GG.AA.YYYY",
        leadingIconName: "calendar",
        trailingIconName: "calendar"
    )
    
    private lazy var birthInformationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .zero
        button.configuration = configuration

        button.backgroundColor = .white
        button.layer.cornerRadius = 19
        button.layer.borderWidth = 1
        button.layer.borderColor = Palette.borderPink.cgColor

        button.isUserInteractionEnabled = true
        button.contentHorizontalAlignment = .fill

        button.addTarget(
            self,
            action: #selector(birthInformationButtonTapped),
            for: .touchUpInside
        )

        return button
    }()
    
    private let birthInformationIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "sparkles")
        imageView.tintColor = Palette.primaryPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let birthInformationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Doğum saati ve doğum yeri"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Palette.text
        label.numberOfLines = 1
        return label
    }()

    private let birthInformationSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Kişisel astroloji yorumları için tamamla"
        label.font = .systemFont(ofSize: 13)
        label.textColor = Palette.secondaryText
        label.numberOfLines = 1
        return label
    }()

    private let birthInformationChevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = Palette.primaryPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var birthInformationTextStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            birthInformationTitleLabel,
            birthInformationSubtitleLabel
        ])

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()

    private lazy var birthInformationSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ASTROLOJİK DOĞUM BİLGİLERİ"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = Palette.titlePink

        view.addSubview(titleLabel)
        view.addSubview(birthInformationButton)

        birthInformationButton.addSubview(birthInformationIconView)
        birthInformationButton.addSubview(birthInformationTextStackView)
        birthInformationButton.addSubview(birthInformationChevronView)
        
        birthInformationIconView.isUserInteractionEnabled = false
        birthInformationTextStackView.isUserInteractionEnabled = false
        birthInformationChevronView.isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor
            ),

            birthInformationButton.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            birthInformationButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            birthInformationButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            birthInformationButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            birthInformationButton.heightAnchor.constraint(
                equalToConstant: 70
            ),

            birthInformationIconView.leadingAnchor.constraint(
                equalTo: birthInformationButton.leadingAnchor,
                constant: 20
            ),
            birthInformationIconView.centerYAnchor.constraint(
                equalTo: birthInformationButton.centerYAnchor
            ),
            birthInformationIconView.widthAnchor.constraint(
                equalToConstant: 22
            ),
            birthInformationIconView.heightAnchor.constraint(
                equalToConstant: 22
            ),

            birthInformationTextStackView.leadingAnchor.constraint(
                equalTo: birthInformationIconView.trailingAnchor,
                constant: 15
            ),
            birthInformationTextStackView.centerYAnchor.constraint(
                equalTo: birthInformationButton.centerYAnchor
            ),

            birthInformationChevronView.leadingAnchor.constraint(
                greaterThanOrEqualTo: birthInformationTextStackView.trailingAnchor,
                constant: 12
            ),
            birthInformationChevronView.trailingAnchor.constraint(
                equalTo: birthInformationButton.trailingAnchor,
                constant: -18
            ),
            birthInformationChevronView.centerYAnchor.constraint(
                equalTo: birthInformationButton.centerYAnchor
            ),
            birthInformationChevronView.widthAnchor.constraint(
                equalToConstant: 18
            ),
            birthInformationChevronView.heightAnchor.constraint(
                equalToConstant: 18
            )
        ])

        return view
    }()

    private lazy var socialInputView = ProfileInputView(
        title: "SOSYAL MEDYA LİNKİ",
        placeholder: "instagram.com/kullaniciadi",
        leadingIconName: "link",
        trailingIconName: nil
    )

    private lazy var motivationInputView = ProfileTextAreaView(
        title: "MOTİVASYON SÖZÜ",
        placeholder: "Sana ilham veren kısa bir söz yaz."
    )

    private lazy var formStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameInputView,
            usernameInputView,
            birthInformationSectionView,
            socialInputView,
            motivationInputView
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 20
        return stack
    }()

    // MARK: Actions

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Vazgeç"
        configuration.image = UIImage(systemName: "xmark")
        configuration.imagePadding = 8
        configuration.baseForegroundColor = Palette.titlePink

        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 14,
            bottom: 0,
            trailing: 14
        )

        button.configuration = configuration
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping

        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = Palette.borderPink.cgColor

        button.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )

        return button
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Kaydet"
        configuration.baseBackgroundColor = Palette.primaryPink
        configuration.baseForegroundColor = .white
        configuration.background.cornerRadius = 18
        button.configuration = configuration

        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 14
        return stack
    }()

    private let visibilityInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bu bilgiler profilini kişiselleştirmek için kullanılır. Topluluk özellikleri eklendiğinde hangi bilgilerin görünür olacağını sen seçebilirsin."
        label.font = .systemFont(ofSize: 14)
        label.textColor = Palette.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: Loading

    private let loadingOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        view.layer.cornerRadius = 28
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = Palette.primaryPink
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Profil bilgilerin yükleniyor…"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Palette.titlePink
        return label
    }()

    private lazy var loadingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [loadingIndicator, loadingLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()

    // MARK: Date picker

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        picker.locale = Locale(identifier: "tr_TR")
        picker.maximumDate = Date()

        var components = DateComponents()
        components.year = -120

        picker.minimumDate = Calendar.current.date(
            byAdding: components,
            to: Date()
        )

        picker.addTarget(
            self,
            action: #selector(datePickerChanged),
            for: .valueChanged
        )

        return picker
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureFormBehavior()
        registerForKeyboardNotifications()
        loadProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: UI setup

    private func setupUI() {
        view.backgroundColor = Palette.pageBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)

        headerView.addSubview(backButton)
        headerView.addSubview(pageTitleLabel)

        profileCardView.addSubview(bannerView)
        profileCardView.addSubview(profileImageView)
        profileCardView.addSubview(cameraButton)
        profileCardView.addSubview(identityStackView)
        profileCardView.addSubview(formStackView)
        profileCardView.addSubview(buttonsStackView)
        profileCardView.addSubview(loadingOverlayView)

        loadingOverlayView.addSubview(loadingStackView)

        mainStackView.addArrangedSubview(headerView)
        mainStackView.addArrangedSubview(profileCardView)
        mainStackView.addArrangedSubview(visibilityInfoLabel)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

            headerView.heightAnchor.constraint(equalToConstant: 58),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 4),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            pageTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            pageTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            pageTitleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: backButton.trailingAnchor,
                constant: 12
            ),

            bannerView.topAnchor.constraint(equalTo: profileCardView.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 100),

//            profileImageView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 27),
//            profileImageView.centerYAnchor.constraint(equalTo: bannerView.bottomAnchor),
//            profileImageView.widthAnchor.constraint(equalToConstant: 92),
//            profileImageView.heightAnchor.constraint(equalToConstant: 92),
            
            profileImageView.leadingAnchor.constraint(
                equalTo: profileCardView.leadingAnchor,
                constant: 24
            ),
            profileImageView.centerYAnchor.constraint(
                equalTo: bannerView.bottomAnchor
            ),
            profileImageView.widthAnchor.constraint(equalToConstant: 86),
            profileImageView.heightAnchor.constraint(equalToConstant: 86),
            
            

            cameraButton.centerXAnchor.constraint(
                equalTo: profileImageView.trailingAnchor,
                constant: -8
            ),
            cameraButton.centerYAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: -8
            ),
            cameraButton.widthAnchor.constraint(equalToConstant: 24),
            cameraButton.heightAnchor.constraint(equalToConstant: 24),
            

            identityStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            identityStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: profileCardView.trailingAnchor,
                constant: -24
            ),
            identityStackView.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 8),

            formStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 28),
            formStackView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 28),
            formStackView.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -28),

            buttonsStackView.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: 26),
            buttonsStackView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 28),
            buttonsStackView.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -28),
            buttonsStackView.bottomAnchor.constraint(equalTo: profileCardView.bottomAnchor, constant: -28),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 58),

//            cancelButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor, multiplier: 0.34),
            
            cancelButton.widthAnchor.constraint(equalToConstant: 118),

            loadingOverlayView.topAnchor.constraint(equalTo: profileCardView.topAnchor),
            loadingOverlayView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor),
            loadingOverlayView.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor),
            loadingOverlayView.bottomAnchor.constraint(equalTo: profileCardView.bottomAnchor),

            loadingStackView.centerXAnchor.constraint(equalTo: loadingOverlayView.centerXAnchor),
            loadingStackView.centerYAnchor.constraint(equalTo: loadingOverlayView.centerYAnchor)
        ])
    }

    private func configureFormBehavior() {
        nameInputView.textField.textContentType = .name
        nameInputView.textField.autocapitalizationType = .words
        nameInputView.textField.returnKeyType = .next

        usernameInputView.textField.autocapitalizationType = .none
        usernameInputView.textField.autocorrectionType = .no
        usernameInputView.textField.spellCheckingType = .no
        usernameInputView.textField.returnKeyType = .next

        socialInputView.textField.keyboardType = .URL
        socialInputView.textField.autocapitalizationType = .none
        socialInputView.textField.autocorrectionType = .no
        socialInputView.textField.textContentType = .URL
        socialInputView.textField.returnKeyType = .next

        motivationInputView.textView.returnKeyType = .done

        nameInputView.textField.delegate = self
        usernameInputView.textField.delegate = self
        socialInputView.textField.delegate = self
        motivationInputView.textView.delegate = self

        [
            nameInputView.textField,
            usernameInputView.textField,
            socialInputView.textField
        ].forEach {
            $0.addTarget(self, action: #selector(formValueChanged), for: .editingChanged)
        }

        usernameInputView.setTrailingIconVisible(false)
        setScreenState(.loading)
    }

    // MARK: Load profile

    private func loadProfile() {
        guard let user = Auth.auth().currentUser else {
            showAuthenticationError()
            return
        }

        setScreenState(.loading)

        db.collection(FirebasePath.profiles)
            .document(user.uid)
            .getDocument { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    self.setScreenState(.error)
                    self.showLoadError(error)
                    return
                }

                let data = snapshot?.data() ?? [:]
                let profile = self.makeProfile(from: data, authUser: user)

                self.originalProfile = profile
                self.populateForm(with: profile)
                self.setScreenState(.content)
            }
    }

    private func makeProfile(
        from data: [String: Any],
        authUser: User
    ) -> EditableProfile {
        let name = data[Field.name] as? String
            ?? authUser.displayName
            ?? ""

        let username = data[Field.username] as? String ?? ""
        let socialMediaURL = data[Field.socialMediaURL] as? String ?? ""
        let motivation = data[Field.motivation] as? String ?? ""
        let profileImageURL = data[Field.profileImageURL] as? String

        return EditableProfile(
            name: name,
            username: username,
            birthDate: parseBirthDate(data[Field.birthDate]),
            socialMediaURL: socialMediaURL,
            motivation: motivation,
            profileImageURL: profileImageURL
        )
    }

    /// Reads the new yyyy-MM-dd format and also supports a legacy Firestore Timestamp.
    private func parseBirthDate(_ value: Any?) -> Date? {
        if let stringValue = value as? String {
            return storageDateFormatter.date(from: stringValue)
        }

        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        if let date = value as? Date {
            return date
        }

        return nil
    }

    private func populateForm(with profile: EditableProfile) {
        nameInputView.text = profile.name
        usernameInputView.text = profile.username
        socialInputView.text = profile.socialMediaURL
        motivationInputView.text = profile.motivation

        selectedBirthDate = profile.birthDate

        profileNameLabel.text = profile.name
        profileUsernameLabel.text = profile.username.isEmpty ? "" : "@\(profile.username)"

        if let birthDate = profile.birthDate {
            datePicker.date = birthDate
        }

        if let urlString = profile.profileImageURL,
           let url = URL(string: urlString) {
            loadProfileImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }

        selectedProfileImage = nil
        updateSaveButtonState()
    }

    // MARK: Save profile

    @objc private func saveButtonTapped() {
        view.endEditing(true)

        guard screenState == .content else { return }
        guard let user = Auth.auth().currentUser else {
            showAuthenticationError()
            return
        }

        let profile = currentFormProfile

        guard validate(profile) else { return }

        setScreenState(.saving)

        uploadSelectedImageIfNeeded(uid: user.uid) { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                self.setScreenState(.content)
                self.showAlert(
                    title: "Fotoğraf yüklenemedi",
                    message: error.localizedDescription
                )

            case .success(let uploadedURL):
                var profileToSave = profile
                if let uploadedURL {
                    profileToSave.profileImageURL = uploadedURL
                }

                self.saveProfileAtomically(
                    profileToSave,
                    user: user
                )
            }
        }
    }

    private func saveProfileAtomically(
        _ profile: EditableProfile,
        user: User
    ) {
        let uid = user.uid
        let newUsername = normalizedUsername(profile.username)
        let oldUsername = normalizedUsername(originalProfile.username)

        let profileReference = db
            .collection(FirebasePath.profiles)
            .document(uid)

        let newUsernameReference = db
            .collection(FirebasePath.usernames)
            .document(newUsername)

        let oldUsernameReference: DocumentReference? = oldUsername.isEmpty
            ? nil
            : db.collection(FirebasePath.usernames).document(oldUsername)

        db.runTransaction({ transaction, errorPointer -> Any? in
            do {
                let newUsernameSnapshot = try transaction.getDocument(newUsernameReference)

                var oldUsernameIsOwnedByCurrentUser = false

                if oldUsername != newUsername,
                   let oldUsernameReference {
                    let oldUsernameSnapshot = try transaction.getDocument(oldUsernameReference)
                    oldUsernameIsOwnedByCurrentUser =
                        oldUsernameSnapshot.data()?[Field.uid] as? String == uid
                }

                if newUsernameSnapshot.exists {
                    let ownerUID = newUsernameSnapshot.data()?[Field.uid] as? String

                    if ownerUID != uid {
                        errorPointer?.pointee = NSError(
                            domain: "Lunora.EditProfile",
                            code: 409,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    "Bu kullanıcı adı başka bir hesap tarafından kullanılıyor."
                            ]
                        )
                        return nil
                    }
                }

                transaction.setData(
                    [
                        Field.uid: uid,
                        Field.updatedAt: FieldValue.serverTimestamp()
                    ],
                    forDocument: newUsernameReference,
                    merge: true
                )

                if oldUsername != newUsername,
                   let oldUsernameReference,
                   oldUsernameIsOwnedByCurrentUser {
                    transaction.deleteDocument(oldUsernameReference)
                }

                var profileData: [String: Any] = [
                    Field.uid: uid,
                    Field.name: profile.name,
                    Field.username: profile.username,
                    Field.usernameLowercase: newUsername,
                    Field.birthDate: self.storageDateFormatter.string(
                        from: profile.birthDate ?? Date()
                    ),
                    Field.motivation: profile.motivation,
                    Field.updatedAt: FieldValue.serverTimestamp()
                ]

                if profile.socialMediaURL.isEmpty {
                    profileData[Field.socialMediaURL] = FieldValue.delete()
                } else {
                    profileData[Field.socialMediaURL] = profile.socialMediaURL
                }

                if let profileImageURL = profile.profileImageURL {
                    profileData[Field.profileImageURL] = profileImageURL
                }

                transaction.setData(
                    profileData,
                    forDocument: profileReference,
                    merge: true
                )

                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }) { [weak self] _, error in
            guard let self else { return }

            if let error {
                self.setScreenState(.content)
                self.showAlert(
                    title: "Profil kaydedilemedi",
                    message: error.localizedDescription
                )
                return
            }

            self.updateAuthProfile(
                user: user,
                name: profile.name,
                photoURLString: profile.profileImageURL
            ) { [weak self] authError in
                guard let self else { return }

                if let authError {
                    // Firestore is the source of truth. Auth synchronization can
                    // be retried later without discarding the saved profile.
                    print("Auth profile synchronization warning: \(authError.localizedDescription)")
                }

                self.originalProfile = profile
                self.selectedProfileImage = nil
                self.populateForm(with: profile)
                self.setScreenState(.content)

                NotificationCenter.default.post(
                    name: .lunoraProfileDidUpdate,
                    object: nil,
                    userInfo: ["uid": user.uid]
                )

                self.navigateBackToProfile()
            }
        }
    }

    private func updateAuthProfile(
        user: User,
        name: String,
        photoURLString: String?,
        completion: @escaping (Error?) -> Void
    ) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name

        if let photoURLString {
            changeRequest.photoURL = URL(string: photoURLString)
        }

        changeRequest.commitChanges(completion: completion)
    }

    // MARK: Photo upload

    private func uploadSelectedImageIfNeeded(
        uid: String,
        completion: @escaping (Result<String?, Error>) -> Void
    ) {
        guard let image = selectedProfileImage else {
            completion(.success(nil))
            return
        }

        let resizedImage = image.resizedForProfile(maxDimension: 1200)

        guard let imageData = resizedImage.jpegData(compressionQuality: 0.82) else {
            completion(.failure(NSError(
                domain: "Lunora.EditProfile",
                code: 422,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Seçilen fotoğraf işlenemedi."
                ]
            )))
            return
        }

        let reference = storage.reference()
            .child(FirebasePath.profileImages)
            .child("\(uid).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["ownerUID": uid]

        reference.putData(imageData, metadata: metadata) { _, error in
            if let error {
                completion(.failure(error))
                return
            }

            reference.downloadURL { url, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let url else {
                    completion(.failure(NSError(
                        domain: "Lunora.EditProfile",
                        code: 500,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Fotoğraf bağlantısı oluşturulamadı."
                        ]
                    )))
                    return
                }

                completion(.success(url.absoluteString))
            }
        }
    }

    private func loadProfileImage(from url: URL) {
        let representedURL = url.absoluteString

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                guard self.originalProfile.profileImageURL == representedURL else {
                    return
                }

                self.profileImageView.image = image
            }
        }.resume()
    }

    // MARK: Validation and normalization

    private func validate(_ profile: EditableProfile) -> Bool {
        nameInputView.setError(nil)
        usernameInputView.setError(nil)
//        birthDateInputView.setError(nil)
        socialInputView.setError(nil)
        motivationInputView.setError(nil)

        if profile.name.count < 2 {
            nameInputView.setError("İsim soyisim en az 2 karakter olmalı.")
            scrollToView(nameInputView)
            return false
        }

        if profile.name.count > 50 {
            nameInputView.setError("İsim soyisim 50 karakterden uzun olamaz.")
            scrollToView(nameInputView)
            return false
        }

        if !isValidUsername(profile.username) {
            usernameInputView.setError(
                "Kullanıcı adı 3–20 karakter olmalı; yalnızca küçük harf, sayı, nokta veya alt çizgi içermeli."
            )
            scrollToView(usernameInputView)
            return false
        }

        if !profile.socialMediaURL.isEmpty,
           URL(string: profile.socialMediaURL)?.scheme == nil {
            socialInputView.setError("Geçerli bir sosyal medya bağlantısı yaz.")
            scrollToView(socialInputView)
            return false
        }

        if profile.motivation.count > 160 {
            motivationInputView.setError("Motivasyon sözü en fazla 160 karakter olabilir.")
            scrollToView(motivationInputView)
            return false
        }

        return true
    }

    private func normalizedName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(
                of: #"\s+"#,
                with: " ",
                options: .regularExpression
            )
    }

    private func normalizedUsername(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(with: Locale(identifier: "en_US_POSIX"))
    }

    private func normalizedSocialURL(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        if trimmed.lowercased().hasPrefix("http://")
            || trimmed.lowercased().hasPrefix("https://") {
            return trimmed
        }

        return "https://\(trimmed)"
    }

    private func isValidUsername(_ username: String) -> Bool {
        let pattern = #"^[a-z0-9._]{3,20}$"#
        return username.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: Screen state

    private func setScreenState(_ state: ScreenState) {
        screenState = state

        let isLoading = state == .loading
        let isSaving = state == .saving
        let isInteractive = state == .content

        loadingOverlayView.isHidden = !isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()

        formStackView.isUserInteractionEnabled = isInteractive
        cameraButton.isEnabled = isInteractive
        cancelButton.isEnabled = !isSaving
        backButton.isEnabled = !isSaving

        saveButton.configuration?.showsActivityIndicator = isSaving
        saveButton.configuration?.title = isSaving ? nil : "Kaydet"

        updateSaveButtonState()
    }

    private func updateSaveButtonState() {
        let shouldEnable = screenState == .content && hasUnsavedChanges
        saveButton.isEnabled = shouldEnable
        saveButton.alpha = shouldEnable ? 1 : 0.48

        usernameInputView.setTrailingIconVisible(
            !usernameInputView.text.isEmpty
            && isValidUsername(normalizedUsername(usernameInputView.text))
        )
    }

    // MARK: Date actions

    @objc private func datePickerChanged() {
        selectedBirthDate = datePicker.date
        updateSaveButtonState()
    }


    // MARK: Photo picker

    @objc private func cameraButtonTapped() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: Navigation actions
    
    @objc private func birthInformationButtonTapped() {
        view.endEditing(true)

        let viewController = BirthInformationViewController()

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    @objc private func backButtonTapped() {
        attemptToClose()
    }

    @objc private func cancelButtonTapped() {
        attemptToClose()
    }
    
    private func navigateBackToProfile() {
        guard let navigationController else {
            return
        }

        navigationController.popToRootViewController(animated: true)
    }

    private func attemptToClose() {
        guard hasUnsavedChanges else {
            navigationController?.popViewController(animated: true)
            return
        }

        let alert = UIAlertController(
            title: "Değişiklikler kaydedilmedi",
            message: "Bu sayfadan çıkarsan yaptığın değişiklikler silinecek.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Düzenlemeye Devam Et",
            style: .cancel
        ))

        alert.addAction(UIAlertAction(
            title: "Değişiklikleri Sil",
            style: .destructive,
            handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    @objc private func formValueChanged() {
        nameInputView.setError(nil)
        usernameInputView.setError(nil)
        socialInputView.setError(nil)

        profileNameLabel.text = normalizedName(nameInputView.text)

        let username = normalizedUsername(usernameInputView.text)
        profileUsernameLabel.text = username.isEmpty ? "" : "@\(username)"

        updateSaveButtonState()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: Keyboard

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? CGRect else {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY)

        scrollView.contentInset.bottom = overlap + 16
        scrollView.verticalScrollIndicatorInsets.bottom = overlap
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    private func scrollToView(_ targetView: UIView) {
        let rect = targetView.convert(targetView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(
            rect.insetBy(dx: 0, dy: -20),
            animated: true
        )
    }

    // MARK: Errors and feedback

    private func showAuthenticationError() {
        setScreenState(.error)
        showAlert(
            title: "Oturum bulunamadı",
            message: "Profilini düzenlemek için tekrar giriş yapmalısın."
        )
    }

    private func showLoadError(_ error: Error) {
        let alert = UIAlertController(
            title: "Profil yüklenemedi",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Tekrar Dene",
            style: .default,
            handler: { [weak self] _ in
                self?.loadProfile()
            }
        ))

        alert.addAction(UIAlertAction(
            title: "Geri Dön",
            style: .cancel,
            handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        ))

        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    private func showToast(_ message: String) {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = Palette.text.withAlphaComponent(0.92)
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        label.alpha = 0

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -18
            ),
            label.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 24
            ),
            label.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -24
            )
        ])

        UIView.animate(withDuration: 0.2, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(
                withDuration: 0.25,
                delay: 1.6,
                options: [.curveEaseInOut],
                animations: {
                    label.alpha = 0
                },
                completion: { _ in
                    label.removeFromSuperview()
                }
            )
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameInputView.textField:
            usernameInputView.textField.becomeFirstResponder()

        case socialInputView.textField:
            motivationInputView.textView.becomeFirstResponder()

        default:
            textField.resignFirstResponder()
        }

        return true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        guard textField === usernameInputView.textField else {
            return true
        }

        let currentText = textField.text ?? ""
        guard let swiftRange = Range(range, in: currentText) else {
            return false
        }

        let candidate = currentText.replacingCharacters(
            in: swiftRange,
            with: string
        )

        if candidate.count > 20 {
            return false
        }

        if candidate.isEmpty {
            return true
        }

        return candidate.range(
            of: #"^[A-Za-z0-9._]+$"#,
            options: .regularExpression
        ) != nil
    }
}

// MARK: - UITextViewDelegate

extension EditProfileViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        motivationInputView.updatePlaceholderVisibility()
        motivationInputView.setError(nil)

        if textView.text.count > 160 {
            textView.text = String(textView.text.prefix(160))
        }

        updateSaveButtonState()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error {
                DispatchQueue.main.async {
                    self?.showAlert(
                        title: "Fotoğraf seçilemedi",
                        message: error.localizedDescription
                    )
                }
                return
            }

            guard let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                self?.selectedProfileImage = image
                self?.profileImageView.image = image
                self?.updateSaveButtonState()
            }
        }
    }
}

// MARK: - ProfileInputView

//private final class ProfileInputView: UIView {
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 15, weight: .semibold)
//        label.textColor = UIColor(
//            red: 188 / 255,
//            green: 83 / 255,
//            blue: 140 / 255,
//            alpha: 1
//        )
//        return label
//    }()
//
//    private let inputContainerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 19
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor(
//            red: 247 / 255,
//            green: 167 / 255,
//            blue: 207 / 255,
//            alpha: 1
//        ).cgColor
//        return view
//    }()
//
//    private let leadingIconImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.tintColor = UIColor(
//            red: 232 / 255,
//            green: 87 / 255,
//            blue: 160 / 255,
//            alpha: 1
//        )
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//
//    let textField: UITextField = {
//        let field = UITextField()
//        field.translatesAutoresizingMaskIntoConstraints = false
//        field.font = .systemFont(ofSize: 16)
//        field.textColor = UIColor(
//            red: 61 / 255,
//            green: 37 / 255,
//            blue: 51 / 255,
//            alpha: 1
//        )
//        field.clearButtonMode = .whileEditing
//        return field
//    }()
//
//    private lazy var trailingButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.tintColor = UIColor(
//            red: 232 / 255,
//            green: 87 / 255,
//            blue: 160 / 255,
//            alpha: 1
//        )
//        button.addTarget(self, action: #selector(trailingButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    private let errorLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 12)
//        label.textColor = .systemRed
//        label.numberOfLines = 0
//        label.isHidden = true
//        return label
//    }()
//
//    var onTrailingButtonTapped: (() -> Void)?
//
//    var text: String {
//        get { textField.text ?? "" }
//        set { textField.text = newValue }
//    }
//
//    init(
//        title: String,
//        placeholder: String,
//        leadingIconName: String,
//        trailingIconName: String?
//    ) {
//        super.init(frame: .zero)
//        translatesAutoresizingMaskIntoConstraints = false
//
//        titleLabel.text = title
//        textField.placeholder = placeholder
//        leadingIconImageView.image = UIImage(systemName: leadingIconName)
//
//        if let trailingIconName {
//            trailingButton.setImage(
//                UIImage(systemName: trailingIconName),
//                for: .normal
//            )
//            trailingButton.isHidden = false
//        } else {
//            trailingButton.isHidden = true
//        }
//
//        setupUI()
//        setupConstraints()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupUI() {
//        addSubview(titleLabel)
//        addSubview(inputContainerView)
//        addSubview(errorLabel)
//
//        inputContainerView.addSubview(leadingIconImageView)
//        inputContainerView.addSubview(textField)
//        inputContainerView.addSubview(trailingButton)
//    }
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
//
//            inputContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//            inputContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            inputContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            inputContainerView.heightAnchor.constraint(equalToConstant: 58),
//
//            leadingIconImageView.leadingAnchor.constraint(
//                equalTo: inputContainerView.leadingAnchor,
//                constant: 20
//            ),
//            leadingIconImageView.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
//            leadingIconImageView.widthAnchor.constraint(equalToConstant: 20),
//            leadingIconImageView.heightAnchor.constraint(equalToConstant: 20),
//
//            trailingButton.trailingAnchor.constraint(
//                equalTo: inputContainerView.trailingAnchor,
//                constant: -14
//            ),
//            trailingButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
//            trailingButton.widthAnchor.constraint(equalToConstant: 30),
//            trailingButton.heightAnchor.constraint(equalToConstant: 30),
//
//            textField.leadingAnchor.constraint(
//                equalTo: leadingIconImageView.trailingAnchor,
//                constant: 15
//            ),
//            textField.trailingAnchor.constraint(
//                equalTo: trailingButton.leadingAnchor,
//                constant: -8
//            ),
//            textField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
//            textField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor),
//
//            errorLabel.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 5),
//            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
//            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//
//    func setError(_ message: String?) {
//        errorLabel.text = message
//        errorLabel.isHidden = message == nil
//        inputContainerView.layer.borderColor = (
//            message == nil
//                ? UIColor(
//                    red: 247 / 255,
//                    green: 167 / 255,
//                    blue: 207 / 255,
//                    alpha: 1
//                )
//                : UIColor.systemRed
//        ).cgColor
//    }
//
//    func setTrailingIconVisible(_ isVisible: Bool) {
//        trailingButton.isHidden = !isVisible
//    }
//
//    @objc private func trailingButtonTapped() {
//        onTrailingButtonTapped?()
//    }
//}

// MARK: - ProfileTextAreaView

//private final class ProfileTextAreaView: UIView {
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 15, weight: .semibold)
//        label.textColor = UIColor(
//            red: 188 / 255,
//            green: 83 / 255,
//            blue: 140 / 255,
//            alpha: 1
//        )
//        return label
//    }()
//
//    private let textContainerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 19
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor(
//            red: 247 / 255,
//            green: 167 / 255,
//            blue: 207 / 255,
//            alpha: 1
//        ).cgColor
//        return view
//    }()
//
//    private let quoteImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(systemName: "quote.opening")
//        imageView.tintColor = UIColor(
//            red: 232 / 255,
//            green: 87 / 255,
//            blue: 160 / 255,
//            alpha: 1
//        )
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//
//    let textView: UITextView = {
//        let view = UITextView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.font = .systemFont(ofSize: 16)
//        view.textColor = UIColor(
//            red: 61 / 255,
//            green: 37 / 255,
//            blue: 51 / 255,
//            alpha: 1
//        )
//        view.backgroundColor = .clear
//        view.isScrollEnabled = false
//        view.textContainerInset = .zero
//        view.textContainer.lineFragmentPadding = 0
//        return view
//    }()
//
//    private let placeholderLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .placeholderText
//        label.numberOfLines = 0
//        return label
//    }()
//
//    private let errorLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 12)
//        label.textColor = .systemRed
//        label.numberOfLines = 0
//        label.isHidden = true
//        return label
//    }()
//
//    var text: String {
//        get { textView.text ?? "" }
//        set {
//            textView.text = newValue
//            updatePlaceholderVisibility()
//        }
//    }
//
//    init(title: String, placeholder: String) {
//        super.init(frame: .zero)
//        translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.text = title
//        placeholderLabel.text = placeholder
//        setupUI()
//        setupConstraints()
//        updatePlaceholderVisibility()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupUI() {
//        addSubview(titleLabel)
//        addSubview(textContainerView)
//        addSubview(errorLabel)
//
//        textContainerView.addSubview(quoteImageView)
//        textContainerView.addSubview(textView)
//        textContainerView.addSubview(placeholderLabel)
//    }
//
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//
//            textContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//            textContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            textContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            textContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 116),
//
//            quoteImageView.leadingAnchor.constraint(
//                equalTo: textContainerView.leadingAnchor,
//                constant: 20
//            ),
//            quoteImageView.topAnchor.constraint(
//                equalTo: textContainerView.topAnchor,
//                constant: 44
//            ),
//            quoteImageView.widthAnchor.constraint(equalToConstant: 20),
//            quoteImageView.heightAnchor.constraint(equalToConstant: 20),
//
//            textView.leadingAnchor.constraint(
//                equalTo: quoteImageView.trailingAnchor,
//                constant: 15
//            ),
//            textView.trailingAnchor.constraint(
//                equalTo: textContainerView.trailingAnchor,
//                constant: -18
//            ),
//            textView.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 20),
//            textView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -20),
//
//            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
//            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
//            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
//
//            errorLabel.topAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: 5),
//            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
//            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//
//    func updatePlaceholderVisibility() {
//        placeholderLabel.isHidden = !text.isEmpty
//    }
//
//    func setError(_ message: String?) {
//        errorLabel.text = message
//        errorLabel.isHidden = message == nil
//        textContainerView.layer.borderColor = (
//            message == nil
//                ? UIColor(
//                    red: 247 / 255,
//                    green: 167 / 255,
//                    blue: 207 / 255,
//                    alpha: 1
//                )
//                : UIColor.systemRed
//        ).cgColor
//    }
//}

// MARK: - Supporting types

private final class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(
        top: 10,
        left: 16,
        bottom: 10,
        right: 16
    )

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}

private extension UIImage {
    func resizedForProfile(maxDimension: CGFloat) -> UIImage {
        let largestDimension = max(size.width, size.height)

        guard largestDimension > maxDimension else {
            return self
        }

        let scale = maxDimension / largestDimension
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension Notification.Name {
    static let lunoraProfileDidUpdate = Notification.Name(
        "lunoraProfileDidUpdate"
    )
}
