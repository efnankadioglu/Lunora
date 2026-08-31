//
//  BirthInformationViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 19.07.2026.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class BirthInformationViewController: UIViewController {

    // MARK: - Dependencies

    private let db = Firestore.firestore()
    private let repository = BirthInformationRepository.shared
    
    // MARK: - Output

    var onBirthInformationSaved: (() -> Void)?

    // MARK: - State

    private var birthDateISO: String?
    private var birthInformation = BirthInformation()

    private var selectedBirthDate: Date?
    private var selectedBirthTime: Date?
    private var selectedBirthPlace: BirthPlace?

    private var isLoading = false {
        didSet {
            updateLoadingState()
        }
    }

    // MARK: - Colors

    private enum Palette {

        static let background = UIColor(
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
            red: 126 / 255,
            green: 99 / 255,
            blue: 116 / 255,
            alpha: 1
        )
    }

    // MARK: - Main Views

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
        stack.spacing = 20
        return stack
    }()

    // MARK: - Header

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
        button.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        return button
    }()

    private let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Doğum Bilgileri"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = Palette.text
        label.textAlignment = .center
        return label
    }()

    // MARK: - Information Card

    private let informationCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 26
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Palette.primaryPink.withAlphaComponent(0.14)
        view.layer.cornerRadius = 27
        return view
    }()

    private let astrologyIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "sparkles")
        imageView.tintColor = Palette.primaryPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let informationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Kişisel astroloji bilgilerin"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = Palette.text
        label.numberOfLines = 0
        return label
    }()

    private let informationDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text =
            "Doğum tarihi, saati ve yeri; yakında kullanıma sunulacak kişiselleştirilmiş astroloji yorumlarının hazırlanmasında kullanılacaktır. Bu özellik şu anda aktif değildir."
        label.font = .systemFont(ofSize: 14)
        label.textColor = Palette.secondaryText
        label.numberOfLines = 0
        return label
    }()
    
    private let unknownTimeExplanationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = """
        Doğum saatin bilinmiyorsa yine kişisel yorum alabilirsin. \
        Ancak yükselen burç ve ev yerleşimlerine dayalı yorumlar kullanılamaz.
        """
        label.font = .systemFont(ofSize: 13)
        label.textColor = Palette.secondaryText
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Form Fields

    private lazy var birthDateInputView = BirthInfoInputView(
        title: "DOĞUM TARİHİ",
        placeholder: "GG.AA.YYYY",
        leadingIconName: "calendar",
        trailingIconName: "calendar"
    )

    private lazy var birthTimeInputView = BirthInfoInputView(
        title: "DOĞUM SAATİ",
        placeholder: "SS:DD",
        leadingIconName: "clock",
        trailingIconName: "clock"
    )

    private lazy var birthPlaceInputView = BirthInfoInputView(
        title: "DOĞUM YERİ",
        placeholder: "Şehir veya ülke ara",
        leadingIconName: "location",
        trailingIconName: "chevron.right"
    )

    private let unknownTimeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 19
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.borderPink.cgColor
        return view
    }()

    private let unknownTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Doğum saatimi bilmiyorum"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = Palette.text
        label.numberOfLines = 0
        return label
    }()

    private lazy var unknownTimeSwitch: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.onTintColor = Palette.primaryPink
        control.addTarget(
            self,
            action: #selector(unknownTimeSwitchChanged),
            for: .valueChanged
        )
        return control
    }()

    private lazy var formStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            birthDateInputView,
            birthTimeInputView,
            unknownTimeContainerView,
            unknownTimeExplanationLabel,
            birthPlaceInputView
        ])

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 20
        return stack
    }()

    // MARK: - Save Button

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Bilgileri Kaydet"
        configuration.baseBackgroundColor = Palette.primaryPink
        configuration.baseForegroundColor = .white
        configuration.background.cornerRadius = 18

        button.configuration = configuration
        button.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: - Privacy Label

    private let privacyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text =
            "Doğum bilgileriniz profilinizde herkese açık gösterilmez."
        label.font = .systemFont(ofSize: 13)
        label.textColor = Palette.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Loading

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = Palette.primaryPink
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Pickers

    private lazy var birthDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "tr_TR")
        picker.maximumDate = Date()

        picker.addTarget(
            self,
            action: #selector(birthDatePickerChanged),
            for: .valueChanged
        )

        return picker
    }()

    private lazy var birthTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "tr_TR")

        picker.addTarget(
            self,
            action: #selector(birthTimePickerChanged),
            for: .valueChanged
        )

        return picker
    }()

    // MARK: - Formatters

    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    private lazy var storageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private lazy var displayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        configureForm()
        loadBirthInformation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: animated
        )
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Palette.background

        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)

        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)

        headerView.addSubview(backButton)
        headerView.addSubview(pageTitleLabel)

        iconContainerView.addSubview(astrologyIconImageView)

        informationCardView.addSubview(iconContainerView)
        informationCardView.addSubview(informationTitleLabel)
        informationCardView.addSubview(informationDescriptionLabel)

        unknownTimeContainerView.addSubview(unknownTimeLabel)
        unknownTimeContainerView.addSubview(unknownTimeSwitch)

        mainStackView.addArrangedSubview(headerView)
        mainStackView.addArrangedSubview(informationCardView)
        mainStackView.addArrangedSubview(formStackView)
        mainStackView.addArrangedSubview(saveButton)
        mainStackView.addArrangedSubview(privacyLabel)
    }

    private func setupConstraints() {
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
            ),

            mainStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 22
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -30
            ),

            headerView.heightAnchor.constraint(equalToConstant: 58),

            backButton.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 4
            ),
            backButton.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor
            ),

            pageTitleLabel.centerXAnchor.constraint(
                equalTo: headerView.centerXAnchor
            ),
            pageTitleLabel.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor
            ),

            informationCardView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 132
            ),

            iconContainerView.leadingAnchor.constraint(
                equalTo: informationCardView.leadingAnchor,
                constant: 18
            ),
            iconContainerView.topAnchor.constraint(
                equalTo: informationCardView.topAnchor,
                constant: 22
            ),
            iconContainerView.widthAnchor.constraint(equalToConstant: 54),
            iconContainerView.heightAnchor.constraint(equalToConstant: 54),

            astrologyIconImageView.centerXAnchor.constraint(
                equalTo: iconContainerView.centerXAnchor
            ),
            astrologyIconImageView.centerYAnchor.constraint(
                equalTo: iconContainerView.centerYAnchor
            ),
            astrologyIconImageView.widthAnchor.constraint(
                equalToConstant: 25
            ),
            astrologyIconImageView.heightAnchor.constraint(
                equalToConstant: 25
            ),

            informationTitleLabel.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor,
                constant: 14
            ),
            informationTitleLabel.trailingAnchor.constraint(
                equalTo: informationCardView.trailingAnchor,
                constant: -18
            ),
            informationTitleLabel.topAnchor.constraint(
                equalTo: informationCardView.topAnchor,
                constant: 22
            ),

            informationDescriptionLabel.leadingAnchor.constraint(
                equalTo: informationTitleLabel.leadingAnchor
            ),
            informationDescriptionLabel.trailingAnchor.constraint(
                equalTo: informationTitleLabel.trailingAnchor
            ),
            informationDescriptionLabel.topAnchor.constraint(
                equalTo: informationTitleLabel.bottomAnchor,
                constant: 8
            ),
            informationDescriptionLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: informationCardView.bottomAnchor,
                constant: -20
            ),

            unknownTimeContainerView.heightAnchor.constraint(
                equalToConstant: 58
            ),

            unknownTimeLabel.leadingAnchor.constraint(
                equalTo: unknownTimeContainerView.leadingAnchor,
                constant: 18
            ),
            unknownTimeLabel.centerYAnchor.constraint(
                equalTo: unknownTimeContainerView.centerYAnchor
            ),

            unknownTimeSwitch.leadingAnchor.constraint(
                greaterThanOrEqualTo: unknownTimeLabel.trailingAnchor,
                constant: 12
            ),
            unknownTimeSwitch.trailingAnchor.constraint(
                equalTo: unknownTimeContainerView.trailingAnchor,
                constant: -16
            ),
            unknownTimeSwitch.centerYAnchor.constraint(
                equalTo: unknownTimeContainerView.centerYAnchor
            ),

            saveButton.heightAnchor.constraint(equalToConstant: 58),

            loadingIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            loadingIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    private func configureForm() {
        birthDateInputView.textField.inputView = birthDatePicker
        birthTimeInputView.textField.inputView = birthTimePicker

        birthDateInputView.textField.inputAccessoryView =
            makePickerToolbar(
                doneSelector: #selector(confirmBirthDateSelection)
            )

        birthTimeInputView.textField.inputAccessoryView =
            makePickerToolbar(
                doneSelector: #selector(confirmBirthTimeSelection)
            )

        birthDateInputView.textField.tintColor = .clear
        birthTimeInputView.textField.tintColor = .clear
        birthPlaceInputView.textField.tintColor = .clear

        // Doğum yeri kutusu yazı yazılan bir alan değil.
        // Kutunun tamamı dokunulabilir olsun.
        birthPlaceInputView.textField.isUserInteractionEnabled = false

        birthDateInputView.onTrailingButtonTapped = { [weak self] in
            self?.birthDateInputView.textField.becomeFirstResponder()
        }

        birthTimeInputView.onTrailingButtonTapped = { [weak self] in
            guard self?.unknownTimeSwitch.isOn == false else {
                return
            }

            self?.birthTimeInputView.textField.becomeFirstResponder()
        }

        birthPlaceInputView.onTrailingButtonTapped = { [weak self] in
            self?.openBirthPlaceSearch()
        }

        birthPlaceInputView.onContainerTapped = { [weak self] in
            self?.openBirthPlaceSearch()
        }
    }

    // MARK: - Loading Data

    private func loadBirthInformation() {
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(
                title: "Oturum bulunamadı",
                message: "Doğum bilgilerini görüntülemek için tekrar giriş yapmalısın."
            )
            return
        }

        isLoading = true

        let group = DispatchGroup()

        var loadedBirthDate: String?
        var loadedInformation: BirthInformation?
        var loadingError: Error?

        group.enter()

        db.collection("profiles")
            .document(uid)
            .getDocument { snapshot, error in

                if let error {
                    loadingError = error
                } else {
                    loadedBirthDate =
                        snapshot?.data()?["birthDate"] as? String
                }

                group.leave()
            }

        group.enter()

        repository.fetch(uid: uid) { result in
            switch result {
            case .success(let information):
                loadedInformation = information

            case .failure(let error):
                loadingError = error
            }

            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }

            self.isLoading = false

            if let loadingError {
                self.showAlert(
                    title: "Bilgiler yüklenemedi",
                    message: loadingError.localizedDescription
                )
                return
            }

            self.birthDateISO = loadedBirthDate
            self.birthInformation =
                loadedInformation ?? BirthInformation()

            self.populateForm()
        }
    }

    private func populateForm() {

        let resolvedBirthDateISO =
            birthInformation.birthDateISO
            ?? birthDateISO

        if let resolvedBirthDateISO,
           let date = storageDateFormatter.date(from: resolvedBirthDateISO) {

            birthDateISO = resolvedBirthDateISO
            selectedBirthDate = date
            birthDatePicker.date = date
            birthDateInputView.text =
                displayDateFormatter.string(from: date)
        } else {
            selectedBirthDate = nil
            birthDateInputView.text = ""
        }

        selectedBirthPlace = birthInformation.birthPlace

        if let birthPlace = birthInformation.birthPlace {
            birthPlaceInputView.text = birthPlace.displayName
        } else {
            birthPlaceInputView.text = ""
        }

        unknownTimeSwitch.isOn =
            birthInformation.isBirthTimeUnknown

        updateBirthTimeState()

        if birthInformation.isBirthTimeUnknown {
            selectedBirthTime = nil
            birthTimeInputView.text = ""
            return
        }

        guard let birthHour = birthInformation.birthHour,
              let birthMinute = birthInformation.birthMinute else {
            selectedBirthTime = nil
            birthTimeInputView.text = ""
            return
        }

        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = birthHour
        components.minute = birthMinute

        if let timeDate = components.date {
            selectedBirthTime = timeDate
            birthTimePicker.date = timeDate
            birthTimeInputView.text =
                displayTimeFormatter.string(from: timeDate)
        } else {
            selectedBirthTime = nil
            birthTimeInputView.text = ""
        }
    }

    // MARK: - Save

    @objc private func saveButtonTapped() {
        view.endEditing(true)

        birthDateInputView.setError(nil)
        birthTimeInputView.setError(nil)
        birthPlaceInputView.setError(nil)

        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(
                title: "Oturum bulunamadı",
                message: "Bilgilerini kaydetmek için tekrar giriş yapmalısın."
            )
            return
        }

        guard let selectedBirthDate else {
            birthDateInputView.setError("Doğum tarihini seçmelisin.")
            return
        }

        let birthDateISO =
            storageDateFormatter.string(from: selectedBirthDate)

        let birthTimeMinutes: Int?

        if unknownTimeSwitch.isOn {
            birthTimeMinutes = nil
        } else {
            guard let selectedBirthTime else {
                birthTimeInputView.setError(
                    "Doğum saatini seçmelisin."
                )
                return
            }

            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: selectedBirthTime
            )

            guard let hour = components.hour,
                  let minute = components.minute,
                  let minutes = BirthInformation.makeBirthTimeMinutes(
                    hour: hour,
                    minute: minute
                  ) else {

                birthTimeInputView.setError(
                    "Doğum saati geçerli değil."
                )
                return
            }

            birthTimeMinutes = minutes
        }

        guard let selectedBirthPlace else {
            birthPlaceInputView.setError(
                "Doğum yerini seçmelisin."
            )
            return
        }

        let information = BirthInformation(
            birthDateISO: birthDateISO,
            birthTimeMinutes: birthTimeMinutes,
            isBirthTimeUnknown: unknownTimeSwitch.isOn,
            birthPlace: selectedBirthPlace,
            schemaVersion: 2
        )

        guard information.hasValidBirthPlace else {
            birthPlaceInputView.setError(
                "Doğum yeri doğrulanamadı."
            )
            return
        }

        isLoading = true

        repository.save(
            information,
            uid: uid
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.isLoading = false

                switch result {
                case .failure(let error):
                    self.showAlert(
                        title: "Bilgiler kaydedilemedi",
                        message: error.localizedDescription
                    )

                case .success:
                    self.birthDateISO = birthDateISO
                    self.birthInformation = information

                    self.onBirthInformationSaved?()

                    self.navigationController?
                        .popViewController(animated: true)
                    
                }
            }
        }
    }

    // MARK: - Picker Actions

    @objc private func birthDatePickerChanged() {
        selectedBirthDate = birthDatePicker.date
        birthDateInputView.text =
            displayDateFormatter.string(from: birthDatePicker.date)
        birthDateInputView.setError(nil)
    }

    @objc private func birthTimePickerChanged() {
        selectedBirthTime = birthTimePicker.date
        birthTimeInputView.text =
            displayTimeFormatter.string(from: birthTimePicker.date)
        birthTimeInputView.setError(nil)
    }

    @objc private func confirmBirthDateSelection() {
        birthDatePickerChanged()
        birthDateInputView.textField.resignFirstResponder()
    }

    @objc private func confirmBirthTimeSelection() {
        birthTimePickerChanged()
        birthTimeInputView.textField.resignFirstResponder()
    }

    @objc private func cancelPickerSelection() {
        view.endEditing(true)
    }

    private func makePickerToolbar(
        doneSelector: Selector
    ) -> UIToolbar {
        let toolbar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.bounds.width,
                height: 44
            )
        )

        toolbar.sizeToFit()

        let cancel = UIBarButtonItem(
            title: "Vazgeç",
            style: .plain,
            target: self,
            action: #selector(cancelPickerSelection)
        )

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let done = UIBarButtonItem(
            title: "Bitti",
            style: .done,
            target: self,
            action: doneSelector
        )

        toolbar.items = [
            cancel,
            flexibleSpace,
            done
        ]

        return toolbar
    }

    // MARK: - Unknown Time

    @objc private func unknownTimeSwitchChanged() {
        if unknownTimeSwitch.isOn {
            selectedBirthTime = nil
            birthTimeInputView.text = ""
            birthTimeInputView.setError(nil)
        }

        updateBirthTimeState()
    }

    private func updateBirthTimeState() {
        let isUnknown = unknownTimeSwitch.isOn

        birthTimeInputView.isUserInteractionEnabled = !isUnknown
        birthTimeInputView.alpha = isUnknown ? 0.45 : 1

        unknownTimeExplanationLabel.isHidden = !isUnknown
    }

    // MARK: - Birth Place

    private func openBirthPlaceSearch() {
        view.endEditing(true)

        let viewController = BirthPlaceSearchViewController()

        viewController.onPlaceSelected = { [weak self] place in
            guard let self else { return }

            self.selectedBirthPlace = place
            self.birthPlaceInputView.text = place.displayName
            self.birthPlaceInputView.setError(nil)
        }

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    // MARK: - Navigation

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Loading State

    private func updateLoadingState() {
        scrollView.isUserInteractionEnabled = !isLoading
        saveButton.isEnabled = !isLoading
        saveButton.alpha = isLoading ? 0.55 : 1

        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    // MARK: - Alert

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

        present(alert, animated: true)
    }
}

// MARK: - BirthInfoInputView

private final class BirthInfoInputView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(
            red: 188 / 255,
            green: 83 / 255,
            blue: 140 / 255,
            alpha: 1
        )
        return label
    }()

    private let inputContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 19
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(
            red: 247 / 255,
            green: 167 / 255,
            blue: 207 / 255,
            alpha: 1
        ).cgColor
        return view
    }()

    private let leadingIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(
            red: 232 / 255,
            green: 87 / 255,
            blue: 160 / 255,
            alpha: 1
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .systemFont(ofSize: 16)
        field.textColor = UIColor(
            red: 61 / 255,
            green: 37 / 255,
            blue: 51 / 255,
            alpha: 1
        )
        return field
    }()

    private lazy var trailingButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(
            red: 232 / 255,
            green: 87 / 255,
            blue: 160 / 255,
            alpha: 1
        )
        button.addTarget(
            self,
            action: #selector(trailingButtonTapped),
            for: .touchUpInside
        )
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    var onTrailingButtonTapped: (() -> Void)?
    var onContainerTapped: (() -> Void)?

    var text: String {
        get {
            textField.text ?? ""
        }

        set {
            textField.text = newValue
        }
    }

    init(
        title: String,
        placeholder: String,
        leadingIconName: String,
        trailingIconName: String?
    ) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        textField.placeholder = placeholder
        leadingIconImageView.image =
            UIImage(systemName: leadingIconName)

        if let trailingIconName {
            trailingButton.setImage(
                UIImage(systemName: trailingIconName),
                for: .normal
            )
            trailingButton.isHidden = false
        } else {
            trailingButton.isHidden = true
        }

        setupUI()
        setupConstraints()
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(inputContainerView)
        addSubview(errorLabel)

        inputContainerView.addSubview(leadingIconImageView)
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(trailingButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor
            ),

            inputContainerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            inputContainerView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            inputContainerView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            inputContainerView.heightAnchor.constraint(
                equalToConstant: 58
            ),

            leadingIconImageView.leadingAnchor.constraint(
                equalTo: inputContainerView.leadingAnchor,
                constant: 20
            ),
            leadingIconImageView.centerYAnchor.constraint(
                equalTo: inputContainerView.centerYAnchor
            ),
            leadingIconImageView.widthAnchor.constraint(
                equalToConstant: 20
            ),
            leadingIconImageView.heightAnchor.constraint(
                equalToConstant: 20
            ),

            trailingButton.trailingAnchor.constraint(
                equalTo: inputContainerView.trailingAnchor,
                constant: -14
            ),
            trailingButton.centerYAnchor.constraint(
                equalTo: inputContainerView.centerYAnchor
            ),
            trailingButton.widthAnchor.constraint(
                equalToConstant: 30
            ),
            trailingButton.heightAnchor.constraint(
                equalToConstant: 30
            ),

            textField.leadingAnchor.constraint(
                equalTo: leadingIconImageView.trailingAnchor,
                constant: 15
            ),
            textField.trailingAnchor.constraint(
                equalTo: trailingButton.leadingAnchor,
                constant: -8
            ),
            textField.topAnchor.constraint(
                equalTo: inputContainerView.topAnchor
            ),
            textField.bottomAnchor.constraint(
                equalTo: inputContainerView.bottomAnchor
            ),

            errorLabel.topAnchor.constraint(
                equalTo: inputContainerView.bottomAnchor,
                constant: 5
            ),
            errorLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 4
            ),
            errorLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            errorLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(containerTapped)
        )

        tapGesture.cancelsTouchesInView = false
        inputContainerView.isUserInteractionEnabled = true
        inputContainerView.addGestureRecognizer(tapGesture)
    }

    func setError(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil

        inputContainerView.layer.borderColor = (
            message == nil
                ? UIColor(
                    red: 247 / 255,
                    green: 167 / 255,
                    blue: 207 / 255,
                    alpha: 1
                )
                : UIColor.systemRed
        ).cgColor
    }

    @objc private func trailingButtonTapped() {
        onTrailingButtonTapped?()
    }

    @objc private func containerTapped() {
        onContainerTapped?()
    }
}
