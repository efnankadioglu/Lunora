//
//  ProgramBadgeCardView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 10.04.2026.
//

import UIKit

struct ProgramBadgeCardData {
    let badgeName: String
    let badgeDescription: String
    let badgeImageName: String
    let progressPercent: Int
    let unlockThreshold: Int
    let isUnlocked: Bool
}

final class ProgramBadgeCardView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 14
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Program Rozeti"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let badgeCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 234/255, green: 236/255, blue: 242/255, alpha: 1)
        view.layer.cornerRadius = 80
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }()

    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 68
        imageView.alpha = 0.45
        return imageView
    }()

    private let lockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "lock.fill")
        imageView.tintColor = UIColor(red: 151/255, green: 158/255, blue: 174/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let badgeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "✨ Aura Rozeti"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(red: 60/255, green: 64/255, blue: 72/255, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let badgeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Programı tamamlayarak bu rozeti kazanabilirsin"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(red: 150/255, green: 156/255, blue: 170/255, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 238/255, alpha: 1)
        return view
    }()

    private let progressTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rozete ulaşmak için"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(red: 95/255, green: 102/255, blue: 118/255, alpha: 1)
        return label
    }()

    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "%52 kaldı"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)
        label.textAlignment = .right
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 236/255, alpha: 1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1)
        view.layer.cornerRadius = 5
        return view
    }()

    private var progressFillWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if progressFillWidthConstraint == nil {
            progressFillWidthConstraint = progressFillView.widthAnchor.constraint(
                equalTo: progressTrackView.widthAnchor,
                multiplier: 0.48
            )
            progressFillWidthConstraint?.isActive = true
        }
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(badgeCircleView)
        badgeCircleView.addSubview(badgeImageView)
        badgeCircleView.addSubview(lockImageView)

        containerView.addSubview(badgeNameLabel)
        containerView.addSubview(badgeDescriptionLabel)
        containerView.addSubview(dividerView)
        containerView.addSubview(progressTitleLabel)
        containerView.addSubview(remainingLabel)
        containerView.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            badgeCircleView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            badgeCircleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            badgeCircleView.widthAnchor.constraint(equalToConstant: 160),
            badgeCircleView.heightAnchor.constraint(equalToConstant: 160),

            badgeImageView.centerXAnchor.constraint(equalTo: badgeCircleView.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: badgeCircleView.centerYAnchor),
            badgeImageView.widthAnchor.constraint(equalToConstant: 136),
            badgeImageView.heightAnchor.constraint(equalToConstant: 136),

            lockImageView.centerXAnchor.constraint(equalTo: badgeCircleView.centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: badgeCircleView.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 42),
            lockImageView.heightAnchor.constraint(equalToConstant: 42),

            badgeNameLabel.topAnchor.constraint(equalTo: badgeCircleView.bottomAnchor, constant: 20),
            badgeNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            badgeNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            badgeDescriptionLabel.topAnchor.constraint(equalTo: badgeNameLabel.bottomAnchor, constant: 10),
            badgeDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            badgeDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            dividerView.topAnchor.constraint(equalTo: badgeDescriptionLabel.bottomAnchor, constant: 20),
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            dividerView.heightAnchor.constraint(equalToConstant: 1),

            progressTitleLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 18),
            progressTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),

            remainingLabel.centerYAnchor.constraint(equalTo: progressTitleLabel.centerYAnchor),
            remainingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            progressTrackView.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 12),
            progressTrackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            progressTrackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            progressTrackView.heightAnchor.constraint(equalToConstant: 10),
            progressTrackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),

            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),

            heightAnchor.constraint(equalToConstant: 430)
        ])
    }

    func configure(with data: ProgramBadgeCardData) {
        badgeNameLabel.text = data.badgeName
        badgeImageView.image = UIImage(named: data.badgeImageName)

        let clampedProgress = max(0, min(100, data.progressPercent))
        let remainingPercent = max(0, 100 - clampedProgress)

        badgeDescriptionLabel.text = message(for: clampedProgress)

        remainingLabel.text = data.isUnlocked
            ? "Rozet açıldı"
            : "%\(remainingPercent) kaldı"

        progressTitleLabel.text = data.isUnlocked
            ? "Rozet durumu"
            : "Rozete ulaşmak için"

        badgeImageView.alpha = data.isUnlocked ? 1.0 : imageAlpha(for: clampedProgress)
        lockImageView.isHidden = data.isUnlocked

        updateProgressFill(multiplier: CGFloat(clampedProgress) / 100.0)
    }
    
    private func updateProgressFill(multiplier: CGFloat) {
        let clampedValue = max(0, min(1, multiplier))

        if let progressFillWidthConstraint = progressFillWidthConstraint {
            progressFillWidthConstraint.isActive = false
        }

        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(
            equalTo: progressTrackView.widthAnchor,
            multiplier: clampedValue
        )
        progressFillWidthConstraint?.isActive = true

        layoutIfNeeded()
    }
    
    // 🔥 Progress'e göre yazıyı belirler
    private func message(for percentage: Int) -> String {
        switch percentage {
        case 0...30:
            return "Yolculuk başladı… 🌱"
        case 31...70:
            return "Derinleşiyorsun… 🌊"
        case 71...99:
            return "İçindeki dönüşüm görünür hale geliyor… 🔮"
        case 100:
            return "Dönüşüm tamamlandı ✨"
        default:
            return "Yolculuk başladı… 🌱"
        }
    }
    
    
    // 🔥 Progress'e göre rozet görünürlüğünü belirler
    private func imageAlpha(for percentage: Int) -> CGFloat {
        switch percentage {
        case 0...30:
            return 0.18
        case 31...70:
            return 0.40
        case 71...99:
            return 0.72
        case 100:
            return 1.0
        default:
            return 0.18
        }
    }
    
    
}
