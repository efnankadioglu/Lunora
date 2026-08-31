////
////  ProgramCompletion.swift
////  Lunora
////
////  Created by Efnan Kadıoğlu on 24.04.2026.
////
//


import UIKit

final class ProgramCompletionViewController: UIViewController, UITextViewDelegate {

    // MARK: - Incoming Data

    var programTitle: String?
    var programImageName: String?
    var userId: String?
    var enrollmentId: String?

    private let enrollmentRepository = EnrollmentRepository()

    private let notePlaceholder = "Bu yolculukta neler hissettin?"

    // MARK: - State

    private var sparkleLayer: CAEmitterLayer?
    private var hasPlayedEntranceAnimation = false

    // MARK: - Background

    private let backgroundImageView = UIImageView()
    private let backgroundOverlayView = UIView()
    private let backgroundGradientLayer = CAGradientLayer()

    // MARK: - Scroll

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Header

    private let completionPill = UIView()
    private let completionPillLabel = UILabel()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Badge

    private let badgeStageView = UIView()
    private let glowView = UIView()
    private let haloView = UIView()
    private let imageView = UIImageView()

    private let badgeTitleLabel = UILabel()
    private let badgeSubtitleLabel = UILabel()

    // MARK: - Reflection

    private let noteCardView = UIView()
    private let noteTitleLabel = UILabel()
    private let textView = UITextView()

    // MARK: - Button

    private let startButton = GradientPrimaryButton(frame: .zero)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupKeyboardHandling()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasPlayedEntranceAnimation else { return }
        hasPlayedEntranceAnimation = true

        playEntranceAnimation()
        startAuraAnimation()
        startSparkles()

        let feedback = UINotificationFeedbackGenerator()
        feedback.prepare()
        feedback.notificationOccurred(.success)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundGradientLayer.frame = backgroundOverlayView.bounds

        sparkleLayer?.emitterPosition = CGPoint(
            x: badgeStageView.bounds.midX,
            y: badgeStageView.bounds.midY
        )

        sparkleLayer?.emitterSize = CGSize(
            width: badgeStageView.bounds.width * 0.72,
            height: badgeStageView.bounds.height * 0.72
        )
    }

    // MARK: - Setup

    private func setupUI() {

        view.backgroundColor = UIColor(
            red: 253 / 255,
            green: 238 / 255,
            blue: 247 / 255,
            alpha: 1
        )

        setupBackground()
        setupScrollView()
        setupHeader()
        setupBadge()
        setupNoteCard()
        setupButton()
    }

    // MARK: - Background

    private func setupBackground() {

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "welcome_background_phone")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        view.addSubview(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        backgroundOverlayView.translatesAutoresizingMaskIntoConstraints = false
        backgroundOverlayView.backgroundColor = .clear
        view.addSubview(backgroundOverlayView)

        NSLayoutConstraint.activate([
            backgroundOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        backgroundGradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.08).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor(
                red: 255 / 255,
                green: 235 / 255,
                blue: 247 / 255,
                alpha: 0.42
            ).cgColor
        ]

        backgroundGradientLayer.locations = [0, 0.52, 1]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        backgroundOverlayView.layer.addSublayer(backgroundGradientLayer)
    }

    // MARK: - Scroll

    private func setupScrollView() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false

        // Sayfa gerektiğinde mutlaka scroll edebilsin.
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true

        // Klavye açıkken aşağı sürüklenirse kapanabilsin.
        scrollView.keyboardDismissMode = .interactive

        // Alt kısımda buton için biraz ekstra hareket alanı.
        scrollView.contentInset.bottom = 24
        scrollView.verticalScrollIndicatorInsets.bottom = 24

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),

            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),

            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),

            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),

            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            )
        ])
    }

    // MARK: - Header

    private func setupHeader() {

        completionPill.translatesAutoresizingMaskIntoConstraints = false
        completionPill.backgroundColor = UIColor.white.withAlphaComponent(0.52)
        completionPill.layer.cornerRadius = 15
        completionPill.layer.borderWidth = 1
        completionPill.layer.borderColor =
            UIColor.white.withAlphaComponent(0.72).cgColor

        contentView.addSubview(completionPill)

        completionPillLabel.translatesAutoresizingMaskIntoConstraints = false
        completionPillLabel.text = "PROGRAM TAMAMLANDI"
        completionPillLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        completionPillLabel.textColor = UIColor(
            red: 112 / 255,
            green: 68 / 255,
            blue: 99 / 255,
            alpha: 1
        )

        completionPillLabel.textAlignment = .center
        completionPillLabel.letterSpacing = 1.1

        completionPill.addSubview(completionPillLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Yeni bir rozet kazandın ✨"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = UIColor(
            red: 67 / 255,
            green: 43 / 255,
            blue: 61 / 255,
            alpha: 1
        )

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text =
            "Tamamladığın bu yolculuk artık koleksiyonunda."

        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor(
            red: 91 / 255,
            green: 70 / 255,
            blue: 86 / 255,
            alpha: 0.82
        )

        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([

            completionPill.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 62
            ),

            completionPill.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),

            completionPill.heightAnchor.constraint(
                equalToConstant: 30
            ),

            completionPillLabel.leadingAnchor.constraint(
                equalTo: completionPill.leadingAnchor,
                constant: 14
            ),

            completionPillLabel.trailingAnchor.constraint(
                equalTo: completionPill.trailingAnchor,
                constant: -14
            ),

            completionPillLabel.centerYAnchor.constraint(
                equalTo: completionPill.centerYAnchor
            ),

            titleLabel.topAnchor.constraint(
                equalTo: completionPill.bottomAnchor,
                constant: 18
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 28
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -28
            ),

            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 10
            ),

            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 38
            ),

            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -38
            )
        ])
    }

    // MARK: - Badge

    private func setupBadge() {

        badgeStageView.translatesAutoresizingMaskIntoConstraints = false
        badgeStageView.backgroundColor = .clear
        contentView.addSubview(badgeStageView)

        glowView.translatesAutoresizingMaskIntoConstraints = false
        glowView.backgroundColor = UIColor.white.withAlphaComponent(0.30)

        glowView.layer.cornerRadius = 108

        glowView.layer.shadowColor =
            UIColor.white.cgColor

        glowView.layer.shadowOpacity = 0.75
        glowView.layer.shadowRadius = 34
        glowView.layer.shadowOffset = .zero

        badgeStageView.addSubview(glowView)

        haloView.translatesAutoresizingMaskIntoConstraints = false
        haloView.backgroundColor =
            UIColor.white.withAlphaComponent(0.24)

        haloView.layer.cornerRadius = 96
        haloView.layer.borderWidth = 1

        haloView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.65).cgColor

        badgeStageView.addSubview(haloView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.layer.cornerRadius = 82
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.95).cgColor

        imageView.layer.shadowColor =
            UIColor(
                red: 112 / 255,
                green: 63 / 255,
                blue: 96 / 255,
                alpha: 1
            ).cgColor

        imageView.layer.shadowOpacity = 0.22
        imageView.layer.shadowRadius = 18
        imageView.layer.shadowOffset = CGSize(width: 0, height: 10)

        if let name = programImageName,
           let image = UIImage(named: name) {

            imageView.image = image

        } else {

            imageView.image = UIImage(systemName: "sparkles")
            imageView.tintColor = UIColor(
                red: 204 / 255,
                green: 113 / 255,
                blue: 165 / 255,
                alpha: 1
            )

            imageView.contentMode = .center
            imageView.backgroundColor =
                UIColor.white.withAlphaComponent(0.7)
        }

        badgeStageView.addSubview(imageView)

        badgeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeTitleLabel.text = programTitle ?? "Lunora Rozeti"
        badgeTitleLabel.font = .systemFont(ofSize: 21, weight: .semibold)

        badgeTitleLabel.textColor = UIColor(
            red: 67 / 255,
            green: 43 / 255,
            blue: 61 / 255,
            alpha: 1
        )

        badgeTitleLabel.textAlignment = .center
        badgeTitleLabel.numberOfLines = 2

        contentView.addSubview(badgeTitleLabel)

        badgeSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeSubtitleLabel.text = "Rozetin koleksiyonuna eklendi."

        badgeSubtitleLabel.font =
            .systemFont(ofSize: 13, weight: .medium)

        badgeSubtitleLabel.textColor = UIColor(
            red: 112 / 255,
            green: 76 / 255,
            blue: 102 / 255,
            alpha: 0.75
        )

        badgeSubtitleLabel.textAlignment = .center

        contentView.addSubview(badgeSubtitleLabel)

        NSLayoutConstraint.activate([

            badgeStageView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: 18
            ),

            badgeStageView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),

            badgeStageView.widthAnchor.constraint(
                equalToConstant: 240
            ),

            badgeStageView.heightAnchor.constraint(
                equalToConstant: 240
            ),

            glowView.centerXAnchor.constraint(
                equalTo: badgeStageView.centerXAnchor
            ),

            glowView.centerYAnchor.constraint(
                equalTo: badgeStageView.centerYAnchor
            ),

            glowView.widthAnchor.constraint(
                equalToConstant: 216
            ),

            glowView.heightAnchor.constraint(
                equalToConstant: 216
            ),

            haloView.centerXAnchor.constraint(
                equalTo: badgeStageView.centerXAnchor
            ),

            haloView.centerYAnchor.constraint(
                equalTo: badgeStageView.centerYAnchor
            ),

            haloView.widthAnchor.constraint(
                equalToConstant: 192
            ),

            haloView.heightAnchor.constraint(
                equalToConstant: 192
            ),

            imageView.centerXAnchor.constraint(
                equalTo: badgeStageView.centerXAnchor
            ),

            imageView.centerYAnchor.constraint(
                equalTo: badgeStageView.centerYAnchor
            ),

            imageView.widthAnchor.constraint(
                equalToConstant: 164
            ),

            imageView.heightAnchor.constraint(
                equalToConstant: 164
            ),

            badgeTitleLabel.topAnchor.constraint(
                equalTo: badgeStageView.bottomAnchor,
                constant: -2
            ),

            badgeTitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 30
            ),

            badgeTitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -30
            ),

            badgeSubtitleLabel.topAnchor.constraint(
                equalTo: badgeTitleLabel.bottomAnchor,
                constant: 6
            ),

            badgeSubtitleLabel.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            )
        ])
    }

    // MARK: - Note

    private func setupNoteCard() {

        noteCardView.translatesAutoresizingMaskIntoConstraints = false

        noteCardView.backgroundColor =
            UIColor.white.withAlphaComponent(0.55)

        noteCardView.layer.cornerRadius = 24
        noteCardView.layer.cornerCurve = .continuous

        noteCardView.layer.borderWidth = 1
        noteCardView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.75).cgColor

        noteCardView.layer.shadowColor =
            UIColor.black.cgColor

        noteCardView.layer.shadowOpacity = 0.05
        noteCardView.layer.shadowRadius = 18
        noteCardView.layer.shadowOffset =
            CGSize(width: 0, height: 8)

        contentView.addSubview(noteCardView)

        noteTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTitleLabel.text = "Bu yolculuktan sende ne kaldı?"

        noteTitleLabel.font =
            .systemFont(ofSize: 15, weight: .semibold)

        noteTitleLabel.textColor = UIColor(
            red: 73 / 255,
            green: 49 / 255,
            blue: 67 / 255,
            alpha: 1
        )

        noteCardView.addSubview(noteTitleLabel)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear

        textView.text = notePlaceholder
        textView.textColor = UIColor(
            red: 117 / 255,
            green: 97 / 255,
            blue: 112 / 255,
            alpha: 0.68
        )

        textView.font =
            .systemFont(ofSize: 14.5, weight: .regular)

        textView.delegate = self

        textView.isEditable = true
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true

        // İçeride ikinci bir scroll oluşmasın.
        // Sayfayı ana scrollView hareket ettirsin.
        textView.isScrollEnabled = false

        textView.keyboardDismissMode = .interactive

        textView.textContainerInset =
            UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 8,
                right: 0
            )

        noteCardView.addSubview(textView)

        NSLayoutConstraint.activate([

            noteCardView.topAnchor.constraint(
                equalTo: badgeSubtitleLabel.bottomAnchor,
                constant: 26
            ),

            noteCardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 22
            ),

            noteCardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -22
            ),

            noteTitleLabel.topAnchor.constraint(
                equalTo: noteCardView.topAnchor,
                constant: 18
            ),

            noteTitleLabel.leadingAnchor.constraint(
                equalTo: noteCardView.leadingAnchor,
                constant: 18
            ),

            noteTitleLabel.trailingAnchor.constraint(
                equalTo: noteCardView.trailingAnchor,
                constant: -18
            ),

            textView.topAnchor.constraint(
                equalTo: noteTitleLabel.bottomAnchor,
                constant: 4
            ),

            textView.leadingAnchor.constraint(
                equalTo: noteCardView.leadingAnchor,
                constant: 18
            ),

            textView.trailingAnchor.constraint(
                equalTo: noteCardView.trailingAnchor,
                constant: -18
            ),

            textView.heightAnchor.constraint(
                equalToConstant: 92
            ),

            textView.bottomAnchor.constraint(
                equalTo: noteCardView.bottomAnchor,
                constant: -12
            )
        ])
        let noteTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapNoteCard)
        )

        noteTapGesture.cancelsTouchesInView = false

        noteCardView.addGestureRecognizer(noteTapGesture)
    }

    // MARK: - Button

    private func setupButton() {

        startButton.translatesAutoresizingMaskIntoConstraints = false

        startButton.setTitle(
            "Yeni Yolculuğa Başla  →",
            for: .normal
        )

        startButton.addTarget(
            self,
            action: #selector(didTapStartNewProgram),
            for: .touchUpInside
        )

        contentView.addSubview(startButton)

        NSLayoutConstraint.activate([

            startButton.topAnchor.constraint(
                equalTo: noteCardView.bottomAnchor,
                constant: 18
            ),

            startButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 22
            ),

            startButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -22
            ),

            startButton.heightAnchor.constraint(
                equalToConstant: 56
            ),

            startButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -36
            )
        ])
    }

    // MARK: - Entrance Animation

    private func playEntranceAnimation() {

        completionPill.alpha = 0
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        badgeStageView.alpha = 0
        badgeTitleLabel.alpha = 0
        badgeSubtitleLabel.alpha = 0
        noteCardView.alpha = 0
        startButton.alpha = 0

        titleLabel.transform =
            CGAffineTransform(translationX: 0, y: 12)

        subtitleLabel.transform =
            CGAffineTransform(translationX: 0, y: 12)

        badgeStageView.transform =
            CGAffineTransform(scaleX: 0.56, y: 0.56)

        noteCardView.transform =
            CGAffineTransform(translationX: 0, y: 18)

        startButton.transform =
            CGAffineTransform(translationX: 0, y: 18)

        UIView.animate(
            withDuration: 0.45,
            delay: 0.05,
            options: [.curveEaseOut]
        ) {
            self.completionPill.alpha = 1
        }

        UIView.animate(
            withDuration: 0.55,
            delay: 0.13,
            options: [.curveEaseOut]
        ) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity

            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }

        UIView.animate(
            withDuration: 0.9,
            delay: 0.25,
            usingSpringWithDamping: 0.60,
            initialSpringVelocity: 0.65,
            options: [.curveEaseOut]
        ) {
            self.badgeStageView.alpha = 1
            self.badgeStageView.transform = .identity
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0.62,
            options: [.curveEaseOut]
        ) {
            self.badgeTitleLabel.alpha = 1
            self.badgeSubtitleLabel.alpha = 1
        }

        UIView.animate(
            withDuration: 0.55,
            delay: 0.75,
            options: [.curveEaseOut]
        ) {
            self.noteCardView.alpha = 1
            self.noteCardView.transform = .identity
        }

        UIView.animate(
            withDuration: 0.55,
            delay: 0.88,
            options: [.curveEaseOut]
        ) {
            self.startButton.alpha = 1
            self.startButton.transform = .identity
        }
    }

    // MARK: - Aura

    private func startAuraAnimation() {

        glowView.alpha = 0.48
        haloView.alpha = 0.65

        UIView.animate(
            withDuration: 2.1,
            delay: 0,
            options: [
                .autoreverse,
                .repeat,
                .allowUserInteraction,
                .curveEaseInOut
            ]
        ) {
            self.glowView.transform =
                CGAffineTransform(scaleX: 1.10, y: 1.10)

            self.glowView.alpha = 0.82

            self.haloView.transform =
                CGAffineTransform(scaleX: 1.045, y: 1.045)
        }
    }

    // MARK: - Sparkles

    private func startSparkles() {

        sparkleLayer?.removeFromSuperlayer()

        let emitter = CAEmitterLayer()

        emitter.emitterShape = .circle
        emitter.emitterMode = .outline

        emitter.emitterPosition = CGPoint(
            x: badgeStageView.bounds.midX,
            y: badgeStageView.bounds.midY
        )

        emitter.emitterSize = CGSize(
            width: 180,
            height: 180
        )

        let colors: [UIColor] = [
            .white,
            UIColor(
                red: 255 / 255,
                green: 212 / 255,
                blue: 236 / 255,
                alpha: 1
            ),
            UIColor(
                red: 255 / 255,
                green: 235 / 255,
                blue: 183 / 255,
                alpha: 1
            )
        ]

        emitter.emitterCells = colors.map { color in

            let cell = CAEmitterCell()

            cell.birthRate = 2.6
            cell.lifetime = 2.6
            cell.lifetimeRange = 0.6

            cell.velocity = 18
            cell.velocityRange = 10

            cell.emissionRange = .pi * 2

            cell.scale = 0.34
            cell.scaleRange = 0.16

            cell.alphaSpeed = -0.35

            cell.contents =
                makeSparkleImage(color: color).cgImage

            return cell
        }

        badgeStageView.layer.insertSublayer(
            emitter,
            above: glowView.layer
        )

        sparkleLayer = emitter
    }

    private func makeSparkleImage(color: UIColor) -> UIImage {

        let size = CGSize(width: 12, height: 12)

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in

            let center = CGPoint(
                x: size.width / 2,
                y: size.height / 2
            )

            let path = UIBezierPath()

            path.move(
                to: CGPoint(
                    x: center.x,
                    y: 0
                )
            )

            path.addLine(
                to: CGPoint(
                    x: center.x + 1.5,
                    y: center.y - 1.5
                )
            )

            path.addLine(
                to: CGPoint(
                    x: size.width,
                    y: center.y
                )
            )

            path.addLine(
                to: CGPoint(
                    x: center.x + 1.5,
                    y: center.y + 1.5
                )
            )

            path.addLine(
                to: CGPoint(
                    x: center.x,
                    y: size.height
                )
            )

            path.addLine(
                to: CGPoint(
                    x: center.x - 1.5,
                    y: center.y + 1.5
                )
            )

            path.addLine(
                to: CGPoint(
                    x: 0,
                    y: center.y
                )
            )

            path.addLine(
                to: CGPoint(
                    x: center.x - 1.5,
                    y: center.y - 1.5
                )
            )

            path.close()

            color.setFill()
            path.fill()
        }
    }

    // MARK: - Completion

    @objc private func didTapStartNewProgram() {

        guard let userId = userId,
              let enrollmentId = enrollmentId else {

            print("🔴 completion: userId veya enrollmentId yok")
            return
        }

        let rawNote =
            textView.text
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        let note =
            rawNote == notePlaceholder
            ? ""
            : rawNote

        // MARK: OFFLINE

        if !NetworkMonitor.shared.isConnected {

            print("🟡 Completion ekranı offline kapatılıyor")

            enrollmentRepository.completeJourney(
                userId: userId,
                enrollmentId: enrollmentId,
                note: note
            ) { result in

                switch result {

                case .success:
                    print(
                        "✅ Offline completeJourney daha sonra Firebase'e sync edildi"
                    )

                case .failure(let error):
                    print(
                        "🔴 Offline completeJourney sync hatası:",
                        error.localizedDescription
                    )
                }
            }

            finishCompletionAndGoToProgramList()
            return
        }

        // MARK: ONLINE

        enrollmentRepository.completeJourney(
            userId: userId,
            enrollmentId: enrollmentId,
            note: note
        ) { [weak self] result in

            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {

                case .success:
                    self.finishCompletionAndGoToProgramList()

                case .failure(let error):
                    print(
                        "🔴 Program completion hata:",
                        error.localizedDescription
                    )
                }
            }
        }
    }

    // MARK: - Finish

    private func finishCompletionAndGoToProgramList() {

        ProgressCacheManager.shared.clear()

        NotificationCenter.default.post(
            name: .activeEnrollmentDidChange,
            object: nil
        )

        dismiss(animated: true) {

            let tabBarController =
                UIApplication.shared.connectedScenes
                    .compactMap {
                        $0 as? UIWindowScene
                    }
                    .flatMap {
                        $0.windows
                    }
                    .first {
                        $0.isKeyWindow
                    }?
                    .rootViewController
                    as? UITabBarController

            guard let tabBarController else {

                print(
                    "🔴 Program List için UITabBarController bulunamadı"
                )

                return
            }

            tabBarController.selectedIndex = 0

            print(
                "✅ Program List ekranına dönüldü"
            )
        }
    }

    // MARK: - Keyboard

    private func setupKeyboardHandling() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func didTapNoteCard() {

        textView.becomeFirstResponder()
    }

    @objc private func keyboardWillChangeFrame(
        _ notification: Notification
    ) {

        guard
            let userInfo = notification.userInfo,
            let keyboardFrameValue =
                userInfo[
                    UIResponder.keyboardFrameEndUserInfoKey
                ] as? NSValue
        else {
            return
        }

        let keyboardFrame = view.convert(
            keyboardFrameValue.cgRectValue,
            from: nil
        )

        let keyboardOverlap = max(
            0,
            view.bounds.maxY - keyboardFrame.minY
        )

        let duration =
            userInfo[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? Double ?? 0.25

        let curveRawValue =
            userInfo[
                UIResponder.keyboardAnimationCurveUserInfoKey
            ] as? UInt ?? 7

        let animationOptions =
            UIView.AnimationOptions(
                rawValue: curveRawValue << 16
            )

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: animationOptions
        ) {

            // Klavye kadar aşağıdan boşluk aç.
            self.scrollView.contentInset.bottom =
                keyboardOverlap + 24

            self.scrollView
                .verticalScrollIndicatorInsets
                .bottom = keyboardOverlap + 24

            self.view.layoutIfNeeded()
        }

        // Klavye yerleşince not alanını görünür konuma getir.
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.05
        ) {

            self.scrollNoteAreaAboveKeyboard()
        }
    }

    @objc private func keyboardWillHide(
        _ notification: Notification
    ) {

        let duration =
            notification.userInfo?[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? Double ?? 0.25

        UIView.animate(
            withDuration: duration
        ) {

            // Normal ekran için bıraktığımız küçük alt boşluk.
            self.scrollView.contentInset.bottom = 24

            self.scrollView
                .verticalScrollIndicatorInsets
                .bottom = 24

            self.view.layoutIfNeeded()
        }
    }

    private func scrollNoteAreaAboveKeyboard() {

        let noteRect = noteCardView.convert(
            noteCardView.bounds,
            to: scrollView
        )

        // Kartın üstünde de biraz nefes alanı bırakalım.
        let targetRect = noteRect.insetBy(
            dx: 0,
            dy: -24
        )

        scrollView.scrollRectToVisible(
            targetRect,
            animated: true
        )
    }

    // MARK: - UITextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.text == notePlaceholder {

            textView.text = ""

            textView.textColor = UIColor(
                red: 67 / 255,
                green: 48 / 255,
                blue: 62 / 255,
                alpha: 1
            )
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if textView.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty {

            textView.text = notePlaceholder

            textView.textColor = UIColor(
                red: 117 / 255,
                green: 97 / 255,
                blue: 112 / 255,
                alpha: 0.68
            )
        }
    }
}

// MARK: - UILabel Letter Spacing

private extension UILabel {

    var letterSpacing: CGFloat {

        get { 0 }

        set {

            guard let text = text else { return }

            let attributedString = NSMutableAttributedString(
                string: text
            )

            attributedString.addAttribute(
                .kern,
                value: newValue,
                range: NSRange(
                    location: 0,
                    length: attributedString.length
                )
            )

            attributedText = attributedString
        }
    }
}
