//
//  LegalDocumentViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 30.08.2026.
//

import UIKit

final class LegalDocumentViewController:
    UIViewController {

    // MARK: - Data

    private let documentType: LegalDocumentType

    // MARK: - UI

    private let textView: UITextView = {
        let textView = UITextView()

        textView.isEditable = false
        textView.isSelectable = true

        textView.backgroundColor = .clear

        textView.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        textView.textColor = UIColor(
            red: 61 / 255,
            green: 37 / 255,
            blue: 51 / 255,
            alpha: 1
        )

        textView.textContainerInset =
            UIEdgeInsets(
                top: 24,
                left: 20,
                bottom: 40,
                right: 20
            )

        textView.translatesAutoresizingMaskIntoConstraints =
            false

        return textView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator =
            UIActivityIndicatorView(
                style: .medium
            )

        indicator.hidesWhenStopped = true

        indicator.translatesAutoresizingMaskIntoConstraints =
            false

        return indicator
    }()

    // MARK: - Init

    init(
        type: LegalDocumentType
    ) {

        self.documentType = type

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadDocument()
    }

    // MARK: - Setup

    private func setupUI() {

        view.backgroundColor = UIColor(
            red: 1,
            green: 0.95,
            blue: 0.97,
            alpha: 1
        )

        title = documentType.defaultTitle

        navigationController?
            .navigationBar
            .tintColor = UIColor(
                red: 232 / 255,
                green: 87 / 255,
                blue: 160 / 255,
                alpha: 1
            )

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: "Kapat",
                style: .done,
                target: self,
                action: #selector(closeTapped)
            )

        view.addSubview(textView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([

            textView.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor
            ),

            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            textView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            activityIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    // MARK: - Firebase

    private func loadDocument() {

        activityIndicator.startAnimating()

        LegalDocumentService.shared.fetch(
            documentType
        ) { [weak self] result in

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }

                self.activityIndicator.stopAnimating()

                switch result {

                case .success(let document):

                    self.title =
                        document.title

                    self.textView.text =
                        document.content

                case .failure(let error):

                    self.textView.text =
                        """
                        Belge şu anda yüklenemedi.

                        İnternet bağlantını kontrol edip tekrar deneyebilirsin.

                        \(error.localizedDescription)
                        """
                }
            }
        }
    }

    // MARK: - Actions

    @objc
    private func closeTapped() {

        dismiss(
            animated: true
        )
    }
}
