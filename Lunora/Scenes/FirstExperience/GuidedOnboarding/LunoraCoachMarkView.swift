//
//  LunoraCoachMarkView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.08.2026.
//

import UIKit

final class LunoraCoachMarkView: UIView {

    enum Placement {
        case above
        case below
    }

    // MARK: - Layout Constants

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let safeVerticalMargin: CGFloat = 12
        static let targetSpacing: CGFloat = 16

        static let cardCornerRadius: CGFloat = 24
        static let spotlightCornerRadius: CGFloat = 32

        static let cardHorizontalPadding: CGFloat = 20
        static let cardTopPadding: CGFloat = 20
        static let cardBottomPadding: CGFloat = 14

        static let maxCardWidth: CGFloat = 520

        static let primaryButtonHeight: CGFloat = 50
        static let skipButtonHeight: CGFloat = 44
    }

    // MARK: - Properties

    private let targetRect: CGRect

    /// Bu artık zorunlu konum değil.
    /// Kullanıcının tercih ettiği ilk konum.
    private let preferredPlacement: Placement

    private var onPrimary: (() -> Void)?
    private var onSkip: (() -> Void)?

    private let dimmingLayer = CAShapeLayer()

    private var coachCardTopConstraint: NSLayoutConstraint?

    private var lastLayoutSize: CGSize = .zero

    // MARK: - Spotlight

    private let spotlightBorderView: UIView = {

        let view = UIView()

        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear

        view.layer.borderWidth = 2

        view.layer.borderColor =
            UIColor.white
                .withAlphaComponent(0.95)
                .cgColor

        return view
    }()

    // MARK: - Coach Card

    private let coachCard: UIView = {

        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor =
            UIColor.white.withAlphaComponent(0.97)

        view.layer.cornerRadius =
            Layout.cardCornerRadius

        view.layer.shadowColor =
            UIColor.black.cgColor

        view.layer.shadowOpacity = 0.12

        view.layer.shadowRadius = 18

        view.layer.shadowOffset =
            CGSize(
                width: 0,
                height: 8
            )

        return view
    }()

    // MARK: - Title

    private let titleLabel: UILabel = {

        let label = UILabel()

        label.font =
            .systemFont(
                ofSize: 20,
                weight: .bold
            )

        label.textColor =
            UIColor(
                red: 48 / 255,
                green: 36 / 255,
                blue: 52 / 255,
                alpha: 1
            )

        label.numberOfLines = 0

        label.setContentCompressionResistancePriority(
            .required,
            for: .vertical
        )

        return label
    }()

    // MARK: - Body

    private let bodyLabel: UILabel = {

        let label = UILabel()

        label.font =
            .systemFont(
                ofSize: 16,
                weight: .regular
            )

        label.textColor =
            UIColor(
                red: 95 / 255,
                green: 82 / 255,
                blue: 100 / 255,
                alpha: 1
            )

        label.numberOfLines = 0

        label.setContentCompressionResistancePriority(
            .required,
            for: .vertical
        )

        return label
    }()

    // MARK: - Primary Button

    private let primaryButton: GradientPrimaryButton = {

        let button = GradientPrimaryButton()

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Skip Button

    private let skipButton: UIButton = {

        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(
            "Şimdilik geç",
            for: .normal
        )

        button.setTitleColor(
            UIColor(
                red: 116 / 255,
                green: 98 / 255,
                blue: 121 / 255,
                alpha: 1
            ),
            for: .normal
        )

        button.titleLabel?.font =
            .systemFont(
                ofSize: 14,
                weight: .medium
            )

        return button
    }()

    // MARK: - Content Stack

    private lazy var textStack: UIStackView = {

        let stack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                bodyLabel,
                primaryButton,
                skipButton
            ]
        )

        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12

        return stack
    }()

    // MARK: - Init

    private init(
        targetRect: CGRect,
        placement: Placement,
        title: String,
        body: String,
        primaryTitle: String,
        onPrimary: (() -> Void)?,
        onSkip: (() -> Void)?
    ) {

        self.targetRect = targetRect

        self.preferredPlacement = placement

        self.onPrimary = onPrimary

        self.onSkip = onSkip

        super.init(frame: .zero)

        titleLabel.text = title

        bodyLabel.text = body

        primaryButton.setTitle(
            primaryTitle,
            for: .normal
        )

        setupView()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    // MARK: - Setup View

    private func setupView() {

        backgroundColor = .clear

        layer.insertSublayer(
            dimmingLayer,
            at: 0
        )

        addSubview(
            spotlightBorderView
        )

        addSubview(
            coachCard
        )

        coachCard.addSubview(
            textStack
        )
    }

    // MARK: - Setup Layout

    private func setupLayout() {

        let topConstraint =
            coachCard.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 0
            )

        topConstraint.priority =
            UILayoutPriority(999)

        coachCardTopConstraint =
            topConstraint

        NSLayoutConstraint.activate([

            topConstraint,

            coachCard.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),

            coachCard.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),

            coachCard.topAnchor.constraint(
                greaterThanOrEqualTo:
                    safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),

            coachCard.bottomAnchor.constraint(
                lessThanOrEqualTo:
                    safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),

            textStack.topAnchor.constraint(
                equalTo: coachCard.topAnchor,
                constant: 20
            ),

            textStack.leadingAnchor.constraint(
                equalTo: coachCard.leadingAnchor,
                constant: 20
            ),

            textStack.trailingAnchor.constraint(
                equalTo: coachCard.trailingAnchor,
                constant: -20
            ),

            textStack.bottomAnchor.constraint(
                equalTo: coachCard.bottomAnchor,
                constant: -14
            ),

            primaryButton.heightAnchor.constraint(
                equalToConstant: 50
            ),

            skipButton.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 44
            )
        ])
    }

    // MARK: - Actions Setup

    private func setupActions() {

        primaryButton.addTarget(
            self,
            action: #selector(primaryTapped),
            for: .touchUpInside
        )

        skipButton.addTarget(
            self,
            action: #selector(skipTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Layout

    override func layoutSubviews() {

        super.layoutSubviews()

        updateSpotlight()

        /*
         Bounds değiştiğinde yeniden hesaplıyoruz.
         Böylece farklı iPhone boyutlarında
         ve orientation değişikliklerinde
         konum yeniden belirlenir.
         */

        if lastLayoutSize != bounds.size {

            lastLayoutSize = bounds.size

            updateCoachCardPosition()
        } else {

            /*
             İlk Auto Layout turunda coachCard'ın
             yüksekliği henüz oluşmamış olabilir.

             Bu yüzden height geldikten sonra
             tekrar kontrol ediyoruz.
             */

            if coachCard.bounds.height > 0 {
                updateCoachCardPosition()
            }
        }
    }

    // MARK: - Spotlight

    private func updateSpotlight() {

        dimmingLayer.frame = bounds

        var spotlightRect =
            targetRect.insetBy(
                dx: -7,
                dy: -7
            )

        /*
         Target ekranın bir kısmının dışındaysa
         spotlight'ın saçma şekilde taşmasını
         engelliyoruz.
         */

        let visibleBounds =
            bounds.insetBy(
                dx: 1,
                dy: 1
            )

        let intersection =
            spotlightRect.intersection(
                visibleBounds
            )

        if !intersection.isNull,
           !intersection.isEmpty {

            spotlightRect = intersection
        }

        let path =
            UIBezierPath(
                rect: bounds
            )

        let holePath =
            UIBezierPath(
                roundedRect:
                    spotlightRect,
                cornerRadius:
                    Layout.spotlightCornerRadius
            )

        path.append(
            holePath
        )

        dimmingLayer.path =
            path.cgPath

        dimmingLayer.fillRule =
            .evenOdd

        dimmingLayer.fillColor =
            UIColor.black
                .withAlphaComponent(0.55)
                .cgColor

        spotlightBorderView.frame =
            spotlightRect

        spotlightBorderView.layer.cornerRadius =
            Layout.spotlightCornerRadius
    }

    // MARK: - Adaptive Coach Position

    private func updateCoachCardPosition() {

        guard bounds.height > 0 else {
            return
        }

        /*
         Kartın gerçek yüksekliğini Auto Layout
         belirledi. Biz sadece nereye koyacağımıza
         karar veriyoruz.
         */

        let cardHeight =
            coachCard.bounds.height

        guard cardHeight > 0 else {
            return
        }

        // Safe Area'nın üst sınırı.
        let safeTop =
            safeAreaInsets.top
            + Layout.safeVerticalMargin

        // Safe Area'nın alt sınırı.
        let safeBottom =
            bounds.height
            - safeAreaInsets.bottom
            - Layout.safeVerticalMargin

        /*
         Target ekran dışına kısmen taşmış
         olabilir.

         Konum hesabında sadece ekranda
         görünen kısmını kullanıyoruz.
         */

        let visibleTargetRect: CGRect

        let intersection =
            targetRect.intersection(
                bounds
            )

        if intersection.isNull ||
           intersection.isEmpty {

            visibleTargetRect =
                targetRect

        } else {

            visibleTargetRect =
                intersection
        }

        // Target'ın üstündeki kullanılabilir alan.
        let availableAbove =
            visibleTargetRect.minY
            - Layout.targetSpacing
            - safeTop

        // Target'ın altındaki kullanılabilir alan.
        let availableBelow =
            safeBottom
            - visibleTargetRect.maxY
            - Layout.targetSpacing

        let fitsAbove =
            availableAbove >= cardHeight

        let fitsBelow =
            availableBelow >= cardHeight

        let actualPlacement: Placement

        switch preferredPlacement {

        case .above:

            if fitsAbove {

                // İstenen yer müsait.
                actualPlacement = .above

            } else if fitsBelow {

                // Üstte yer yok.
                // Otomatik aşağı geç.
                actualPlacement = .below

            } else {

                /*
                 İki tarafta da tamamen sığmıyorsa
                 daha fazla boşluğu olan tarafı seç.
                 */
                actualPlacement =
                    availableAbove >= availableBelow
                    ? .above
                    : .below
            }

        case .below:

            if fitsBelow {

                actualPlacement = .below

            } else if fitsAbove {

                actualPlacement = .above

            } else {

                actualPlacement =
                    availableBelow >= availableAbove
                    ? .below
                    : .above
            }
        }

        let desiredY: CGFloat

        switch actualPlacement {

        case .above:

            desiredY =
                visibleTargetRect.minY
                - Layout.targetSpacing
                - cardHeight

        case .below:

            desiredY =
                visibleTargetRect.maxY
                + Layout.targetSpacing
        }

        /*
         EN ÖNEMLİ KISIM.

         Desired Y ne çıkarsa çıksın kartı
         safe area içerisinde tutuyoruz.
         */

        let maximumAllowedY =
            max(
                safeTop,
                safeBottom - cardHeight
            )

        let clampedY =
            min(
                max(
                    desiredY,
                    safeTop
                ),
                maximumAllowedY
            )

        guard
            abs(
                (coachCardTopConstraint?.constant ?? 0)
                - clampedY
            ) > 0.5
        else {
            return
        }

        coachCardTopConstraint?.constant =
            clampedY
    }

    // MARK: - Actions

    @objc
    private func primaryTapped() {

        /*
         Closure'ı dismiss'ten önce tutuyoruz.

         View superview'dan kalktıktan sonra da
         güvenli şekilde çalışır.
         */

        let action = onPrimary

        dismiss {
            action?()
        }
    }

    @objc
    private func skipTapped() {

        let action = onSkip

        dismiss {
            action?()
        }
    }

    // MARK: - Dismiss

    func dismiss(
        completion: (() -> Void)? = nil
    ) {

        /*
         Double tap vb. durumda
         butonun iki kez çalışmasını engelle.
         */

        isUserInteractionEnabled = false

        UIView.animate(
            withDuration: 0.20,
            animations: {
                self.alpha = 0
            },
            completion: { _ in

                self.removeFromSuperview()

                completion?()
            }
        )
    }

    // MARK: - Present
    
    @discardableResult
    static func present(
        over hostView: UIView,
        targetRect: CGRect,
        placement: Placement = .below,
        title: String,
        body: String,
        primaryTitle: String,
        onPrimary: (() -> Void)?,
        onSkip: (() -> Void)?
    ) -> LunoraCoachMarkView {

        hostView.layoutIfNeeded()

        let overlay = LunoraCoachMarkView(
            targetRect: targetRect,
            placement: placement,
            title: title,
            body: body,
            primaryTitle: primaryTitle,
            onPrimary: onPrimary,
            onSkip: onSkip
        )

        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.alpha = 0

        hostView.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: hostView.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: hostView.bottomAnchor)
        ])

        hostView.layoutIfNeeded()

        UIView.animate(withDuration: 0.22) {
            overlay.alpha = 1
        }

        return overlay
    }

    @discardableResult
    static func present(
        over hostView: UIView,
        targetView: UIView,
        placement: Placement = .below,
        title: String,
        body: String,
        primaryTitle: String,
        onPrimary: (() -> Void)?,
        onSkip: (() -> Void)?
    ) -> LunoraCoachMarkView {

        hostView.layoutIfNeeded()
        targetView.layoutIfNeeded()

        let targetRect = targetView.convert(
            targetView.bounds,
            to: hostView
        )

        return present(
            over: hostView,
            targetRect: targetRect,
            placement: placement,
            title: title,
            body: body,
            primaryTitle: primaryTitle,
            onPrimary: onPrimary,
            onSkip: onSkip
        )
    }
}
