//
//  ProfileFormComponents.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 17.08.2026.
//

//
//  ProfileFormComponents.swift
//  Lunora
//

import UIKit


// MARK: - ProfileInputView

final class ProfileInputView: UIView {

    // MARK: - Title

    private let titleLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 15,
            weight: .semibold
        )

        label.textColor = UIColor(
            red: 188 / 255,
            green: 83 / 255,
            blue: 140 / 255,
            alpha: 1
        )

        return label
    }()


    // MARK: - Input Container

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


    // MARK: - Leading Icon

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


    // MARK: - TextField

    let textField: UITextField = {

        let field = UITextField()

        field.translatesAutoresizingMaskIntoConstraints = false

        field.font = .systemFont(
            ofSize: 16
        )

        field.textColor = UIColor(
            red: 61 / 255,
            green: 37 / 255,
            blue: 51 / 255,
            alpha: 1
        )

        field.clearButtonMode = .whileEditing

        return field
    }()


    // MARK: - Trailing Button

    private lazy var trailingButton: UIButton = {

        let button = UIButton(
            type: .system
        )

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


    // MARK: - Error

    private let errorLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 12
        )

        label.textColor = .systemRed

        label.numberOfLines = 0

        label.isHidden = true

        return label
    }()


    // MARK: - Public Properties

    var onTrailingButtonTapped: (() -> Void)?


    var text: String {

        get {
            textField.text ?? ""
        }

        set {
            textField.text = newValue
        }
    }


    // MARK: - Init

    init(
        title: String,
        placeholder: String,
        leadingIconName: String,
        trailingIconName: String?
    ) {

        super.init(
            frame: .zero
        )

        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title

        textField.placeholder = placeholder

        leadingIconImageView.image = UIImage(
            systemName: leadingIconName
        )


        if let trailingIconName {

            trailingButton.setImage(
                UIImage(
                    systemName: trailingIconName
                ),
                for: .normal
            )

            trailingButton.isHidden = false

        } else {

            trailingButton.isHidden = true
        }


        setupUI()

        setupConstraints()
    }


    required init?(
        coder: NSCoder
    ) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }


    // MARK: - UI

    private func setupUI() {

        addSubview(
            titleLabel
        )

        addSubview(
            inputContainerView
        )

        addSubview(
            errorLabel
        )


        inputContainerView.addSubview(
            leadingIconImageView
        )

        inputContainerView.addSubview(
            textField
        )

        inputContainerView.addSubview(
            trailingButton
        )
    }


    // MARK: - Constraints

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // Title

            titleLabel.topAnchor.constraint(
                equalTo: topAnchor
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),

            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor
            ),


            // Input Container

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


            // Leading Icon

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


            // Trailing Button

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


            // TextField

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


            // Error

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


    // MARK: - Error State

    func setError(
        _ message: String?
    ) {

        errorLabel.text = message

        errorLabel.isHidden =
            message == nil


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


    // MARK: - Trailing Icon

    func setTrailingIconVisible(
        _ isVisible: Bool
    ) {

        trailingButton.isHidden =
            !isVisible
    }


    @objc
    private func trailingButtonTapped() {

        onTrailingButtonTapped?()
    }
}


// MARK: - ProfileTextAreaView

final class ProfileTextAreaView: UIView {

    // MARK: - Title

    private let titleLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 15,
            weight: .semibold
        )

        label.textColor = UIColor(
            red: 188 / 255,
            green: 83 / 255,
            blue: 140 / 255,
            alpha: 1
        )

        return label
    }()


    // MARK: - Text Container

    private let textContainerView: UIView = {

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


    // MARK: - Quote Icon

    private let quoteImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.image = UIImage(
            systemName: "quote.opening"
        )

        imageView.tintColor = UIColor(
            red: 232 / 255,
            green: 87 / 255,
            blue: 160 / 255,
            alpha: 1
        )

        imageView.contentMode = .scaleAspectFit

        return imageView
    }()


    // MARK: - TextView

    let textView: UITextView = {

        let view = UITextView()

        view.translatesAutoresizingMaskIntoConstraints = false

        view.font = .systemFont(
            ofSize: 16
        )

        view.textColor = UIColor(
            red: 61 / 255,
            green: 37 / 255,
            blue: 51 / 255,
            alpha: 1
        )

        view.backgroundColor = .clear

        view.isScrollEnabled = false

        view.textContainerInset = .zero

        view.textContainer.lineFragmentPadding = 0

        return view
    }()


    // MARK: - Placeholder

    private let placeholderLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 16
        )

        label.textColor = .placeholderText

        label.numberOfLines = 0

        return label
    }()


    // MARK: - Error

    private let errorLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 12
        )

        label.textColor = .systemRed

        label.numberOfLines = 0

        label.isHidden = true

        return label
    }()


    // MARK: - Text

    var text: String {

        get {
            textView.text ?? ""
        }

        set {

            textView.text = newValue

            updatePlaceholderVisibility()
        }
    }


    // MARK: - Init

    init(
        title: String,
        placeholder: String
    ) {

        super.init(
            frame: .zero
        )

        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title

        placeholderLabel.text = placeholder

        setupUI()

        setupConstraints()

        setupTextObservation()

        updatePlaceholderVisibility()
    }


    required init?(
        coder: NSCoder
    ) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }


    deinit {

        NotificationCenter.default.removeObserver(
            self
        )
    }


    // MARK: - UI

    private func setupUI() {

        addSubview(
            titleLabel
        )

        addSubview(
            textContainerView
        )

        addSubview(
            errorLabel
        )


        textContainerView.addSubview(
            quoteImageView
        )

        textContainerView.addSubview(
            textView
        )

        textContainerView.addSubview(
            placeholderLabel
        )
    }


    // MARK: - Constraints

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // Title

            titleLabel.topAnchor.constraint(
                equalTo: topAnchor
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),

            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor
            ),


            // Text Container

            textContainerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),

            textContainerView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),

            textContainerView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),

            textContainerView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 116
            ),


            // Quote

            quoteImageView.leadingAnchor.constraint(
                equalTo: textContainerView.leadingAnchor,
                constant: 20
            ),

            quoteImageView.topAnchor.constraint(
                equalTo: textContainerView.topAnchor,
                constant: 44
            ),

            quoteImageView.widthAnchor.constraint(
                equalToConstant: 20
            ),

            quoteImageView.heightAnchor.constraint(
                equalToConstant: 20
            ),


            // TextView

            textView.leadingAnchor.constraint(
                equalTo: quoteImageView.trailingAnchor,
                constant: 15
            ),

            textView.trailingAnchor.constraint(
                equalTo: textContainerView.trailingAnchor,
                constant: -18
            ),

            textView.topAnchor.constraint(
                equalTo: textContainerView.topAnchor,
                constant: 20
            ),

            textView.bottomAnchor.constraint(
                equalTo: textContainerView.bottomAnchor,
                constant: -20
            ),


            // Placeholder

            placeholderLabel.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor
            ),

            placeholderLabel.trailingAnchor.constraint(
                equalTo: textView.trailingAnchor
            ),

            placeholderLabel.topAnchor.constraint(
                equalTo: textView.topAnchor
            ),


            // Error

            errorLabel.topAnchor.constraint(
                equalTo: textContainerView.bottomAnchor,
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


    // MARK: - Text Observation

    private func setupTextObservation() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChange),
            name: UITextView.textDidChangeNotification,
            object: textView
        )
    }


    @objc
    private func textViewDidChange() {

        updatePlaceholderVisibility()
    }


    // MARK: - Placeholder

    func updatePlaceholderVisibility() {

        placeholderLabel.isHidden =
            !text.isEmpty
    }


    // MARK: - Error

    func setError(
        _ message: String?
    ) {

        errorLabel.text =
            message

        errorLabel.isHidden =
            message == nil


        textContainerView.layer.borderColor = (

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
}
