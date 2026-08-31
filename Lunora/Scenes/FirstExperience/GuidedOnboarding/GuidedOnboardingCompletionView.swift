//
//  GuidedOnboardingCompletionView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.08.2026.
//

import UIKit

final class GuidedOnboardingCompletionView: UIView {

    private var onFinish: (() -> Void)?

    // MARK: - UI

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 24
        view.layer.shadowOffset = CGSize(width: 0, height: 12)

        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "lunora_logo")
        )

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.text = "Artık Lunora senin ✨"

        label.font = .systemFont(
            ofSize: 27,
            weight: .bold
        )

        label.textColor = UIColor(
            red: 55 / 255,
            green: 38 / 255,
            blue: 55 / 255,
            alpha: 1
        )

        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()

        label.text =
        """
        Günün gökyüzünü keşfetmeyi, sana uygun programları bulmayı ve ilerlemeni takip etmeyi artık biliyorsun.

        Bundan sonrası senin yolculuğun. Kendine iyi gelecek küçük bir adımla başlayabilirsin. 🌷
        """

        label.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )

        label.textColor = UIColor(
            red: 105 / 255,
            green: 84 / 255,
            blue: 105 / 255,
            alpha: 1
        )

        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private lazy var finishButton: GradientPrimaryButton = {

        let button = GradientPrimaryButton(
            frame: .zero
        )

        button.setTitle(
            "Lunora'yı Keşfet",
            for: .normal
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(
            self,
            action: #selector(finishTapped),
            for: .touchUpInside
        )

        return button
    }()


    // MARK: - Init

    private override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }


    // MARK: - Setup

    private func setupUI() {

        backgroundColor = .clear

        addSubview(dimView)
        addSubview(cardView)

        cardView.addSubview(logoImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(bodyLabel)
        cardView.addSubview(finishButton)


        NSLayoutConstraint.activate([

            dimView.topAnchor.constraint(
                equalTo: topAnchor
            ),

            dimView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),

            dimView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),

            dimView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),


            // Card

            cardView.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),

            cardView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 28
            ),

            cardView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -28
            ),


            // Logo

            logoImageView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 28
            ),

            logoImageView.centerXAnchor.constraint(
                equalTo: cardView.centerXAnchor
            ),

            logoImageView.widthAnchor.constraint(
                equalToConstant: 80
            ),

            logoImageView.heightAnchor.constraint(
                equalToConstant: 80
            ),


            // Title

            titleLabel.topAnchor.constraint(
                equalTo: logoImageView.bottomAnchor,
                constant: 18
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 24
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -24
            ),


            // Body

            bodyLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 18
            ),

            bodyLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 24
            ),

            bodyLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -24
            ),


            // Button

            finishButton.topAnchor.constraint(
                equalTo: bodyLabel.bottomAnchor,
                constant: 26
            ),

            finishButton.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 24
            ),

            finishButton.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -24
            ),

            finishButton.heightAnchor.constraint(
                equalToConstant: 54
            ),

            finishButton.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -28
            )
        ])
    }


    // MARK: - Action

    @objc
    private func finishTapped() {

        UIView.animate(
            withDuration: 0.20,
            animations: {
                self.alpha = 0
                self.cardView.transform =
                    CGAffineTransform(
                        scaleX: 0.96,
                        y: 0.96
                    )
            },
            completion: { _ in

                self.removeFromSuperview()
                self.onFinish?()
            }
        )
    }


    // MARK: - Present

    @discardableResult
    static func present(
        over hostView: UIView,
        onFinish: @escaping () -> Void
    ) -> GuidedOnboardingCompletionView {

        let completionView =
            GuidedOnboardingCompletionView(
                frame: .zero
            )

        completionView.translatesAutoresizingMaskIntoConstraints = false
        completionView.onFinish = onFinish

        hostView.addSubview(
            completionView
        )

        NSLayoutConstraint.activate([

            completionView.topAnchor.constraint(
                equalTo: hostView.topAnchor
            ),

            completionView.leadingAnchor.constraint(
                equalTo: hostView.leadingAnchor
            ),

            completionView.trailingAnchor.constraint(
                equalTo: hostView.trailingAnchor
            ),

            completionView.bottomAnchor.constraint(
                equalTo: hostView.bottomAnchor
            )
        ])

        completionView.alpha = 0

        completionView.cardView.transform =
            CGAffineTransform(
                scaleX: 0.94,
                y: 0.94
            )

        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.4,
            options: [.curveEaseOut]
        ) {

            completionView.alpha = 1
            completionView.cardView.transform = .identity
        }

        return completionView
    }
}
