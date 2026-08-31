//
//  InternetRequiredAlert.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 18.08.2026.
//

import UIKit

enum InternetRequiredAlert {

    static func show(on viewController: UIViewController) {
        let popup = InternetRequiredPopupViewController()

        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve

        viewController.present(popup, animated: true)
    }
}


// MARK: - Popup

private final class InternetRequiredPopupViewController: UIViewController {

    // MARK: UI

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "İnternet Bağlantısı Gerekiyor"
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.textColor = UIColor(
            red: 48/255,
            green: 39/255,
            blue: 52/255,
            alpha: 1
        )
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Bu işlemi gerçekleştirmek için internete bağlan."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(
            red: 108/255,
            green: 91/255,
            blue: 112/255,
            alpha: 1
        )
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let okButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton(frame: .zero)
        button.setTitle("Tamam", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        setupActions()
    }


    // MARK: Setup

    private func setupView() {
        view.backgroundColor = .clear

        view.addSubview(dimView)
        view.addSubview(cardView)

        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(okButton)
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // Dim background
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Card
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            cardView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 24
            ),
            cardView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -24
            ),
            cardView.widthAnchor.constraint(equalToConstant: 330),

            // Title
            titleLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 24
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 20
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -20
            ),

            // Message
            messageLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 10
            ),
            messageLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 20
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -20
            ),

            // Button
            okButton.topAnchor.constraint(
                equalTo: messageLabel.bottomAnchor,
                constant: 20
            ),
            okButton.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 20
            ),
            okButton.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -20
            ),
            okButton.heightAnchor.constraint(equalToConstant: 48),
            okButton.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -20
            )
        ])
    }

    private func setupActions() {
        okButton.addTarget(
            self,
            action: #selector(okButtonTapped),
            for: .touchUpInside
        )
    }


    // MARK: Actions

    @objc private func okButtonTapped() {
        dismiss(animated: true)
    }
}
