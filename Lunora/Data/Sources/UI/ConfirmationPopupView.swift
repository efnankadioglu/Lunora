//
//  ConfirmationPopupView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 11.04.2026.
//

import UIKit

final class ConfirmationPopupView: UIView {

    // MARK: - Public Properties (DIŞARIDAN SET EDİLECEK)
    
    var titleText: String = ""
    var messageText: String = ""
    var cancelTitle: String = ""
    var confirmTitle: String = ""

    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - UI
    
    private let dimView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 250/255, green: 244/255, blue: 248/255, alpha: 1)
        view.layer.cornerRadius = 28
        return view
    }()

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = GradientPrimaryButton(type: .system)

    // MARK: - INIT
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }

    // MARK: - CONFIGURE
    
    func applyContent() {
        titleLabel.text = titleText
        messageLabel.text = messageText
        cancelButton.setTitle(cancelTitle, for: .normal)
        confirmButton.setTitle(confirmTitle, for: .normal)
    }

    // MARK: - PRESENT
    
    func present(in parentView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false

        parentView.addSubview(self)

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: parentView.topAnchor),
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])

        applyContent()

        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)

        UIView.animate(withDuration: 0.22) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }

    private func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.20, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }

    // MARK: - UI SETUP
    
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(dimView)
        addSubview(containerView)

        [titleLabel, messageLabel, cancelButton, confirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }

        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .darkGray

        cancelButton.layer.cornerRadius = 22
        cancelButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
        cancelButton.setTitleColor(.black, for: .normal)

        confirmButton.layer.cornerRadius = 22
        confirmButton.backgroundColor = UIColor.appAccentPink
        confirmButton.setTitleColor(.white, for: .normal)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            cancelButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),

            confirmButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            confirmButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 12),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            confirmButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 52),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    @objc private func cancelTapped() {
        dismiss { [weak self] in
            self?.onCancel?()
        }
    }

    @objc private func confirmTapped() {
        dismiss { [weak self] in
            self?.onConfirm?()
        }
    }
}
