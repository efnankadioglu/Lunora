//
//  AstroEventInfoViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.07.2026.
//

import UIKit

final class AstroEventInfoViewController: UIViewController {

    // MARK: - Properties

    private let eventTitle: String
    private let eventMessage: String
    private let eventColor: UIColor
    private let eventSymbol: String

    // MARK: - UI

    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 18

        return stack
    }()

    private let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        return stack
    }()

    private let symbolView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.layer.cornerRadius = 24
        view.clipsToBounds = true

        return view
    }()

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.textAlignment = .center

        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label

        label.numberOfLines = 0

        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(ofSize: 17, weight: .regular)

        label.textColor = UIColor.label.withAlphaComponent(0.72)

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        return label
    }()

    private lazy var closeButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Anladım ✨", for: .normal)

        button.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )

        button.addTarget(
            self,
            action: #selector(didTapClose),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: - Init

    init(
        title: String,
        message: String,
        color: UIColor,
        symbol: String
    ) {
        self.eventTitle = title
        self.eventMessage = message
        self.eventColor = color
        self.eventSymbol = symbol

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError(
            "AstroEventInfoViewController storyboard ile oluşturulmamalıdır."
        )
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupHierarchy()
        setupConstraints()
        configureContent()
        configureSheet()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
    }

    private func setupHierarchy() {
        view.addSubview(containerStackView)

        symbolView.addSubview(symbolLabel)

        headerStackView.addArrangedSubview(symbolView)
        headerStackView.addArrangedSubview(titleLabel)

        containerStackView.addArrangedSubview(headerStackView)
        containerStackView.addArrangedSubview(messageLabel)
        containerStackView.addArrangedSubview(closeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            containerStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 28
            ),

            containerStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),

            containerStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            containerStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),

            symbolView.widthAnchor.constraint(
                equalToConstant: 48
            ),

            symbolView.heightAnchor.constraint(
                equalToConstant: 48
            ),

            symbolLabel.centerXAnchor.constraint(
                equalTo: symbolView.centerXAnchor
            ),

            symbolLabel.centerYAnchor.constraint(
                equalTo: symbolView.centerYAnchor
            ),

            closeButton.heightAnchor.constraint(
                equalToConstant: 50
            )
        ])
    }

    private func configureContent() {
        titleLabel.text = eventTitle
        messageLabel.text = eventMessage
        symbolLabel.text = eventSymbol

        symbolView.backgroundColor =
            eventColor.withAlphaComponent(0.20)

        symbolLabel.textColor = eventColor
    }

    // MARK: - Sheet

    private func configureSheet() {
        guard let sheet = sheetPresentationController else {
            return
        }

        sheet.detents = [
            .medium(),
            .large()
        ]

        sheet.selectedDetentIdentifier = .medium

        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 28

        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }

    // MARK: - Action

    @objc
    private func didTapClose() {
        dismiss(animated: true)
    }
}
