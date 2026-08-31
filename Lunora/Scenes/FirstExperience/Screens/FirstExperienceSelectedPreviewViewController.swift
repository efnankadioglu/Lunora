//
//  FirstExperienceSelectedPreviewViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.08.2026.
//

import UIKit

final class FirstExperienceSelectedPreviewViewController: UIViewController {

    // MARK: - Properties

    private let coordinator: FirstExperienceCoordinator
    
    private let need: FirstExperienceNeed
    private let viewModel: FirstExperiencePreviewViewModel

    var onBack: (() -> Void)?
    var onContinue: (() -> Void)?

    // MARK: - UI

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "welcome_background_phone")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)

        let config = UIImage.SymbolConfiguration(
            pointSize: 18,
            weight: .semibold
        )

        button.setImage(
            UIImage(
                systemName: "chevron.left",
                withConfiguration: config
            ),
            for: .normal
        )

        button.tintColor = UIColor(
            red: 55/255,
            green: 40/255,
            blue: 60/255,
            alpha: 1
        )

        button.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        button.layer.cornerRadius = 20

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let stepBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stepLabel: UILabel = {
        let label = UILabel()
        label.text = "2 / 3"
        label.font = .systemFont(
            ofSize: 13,
            weight: .semibold
        )
        label.textColor = UIColor(
            red: 83/255,
            green: 67/255,
            blue: 92/255,
            alpha: 1
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let eyebrowLabel: UILabel = {
        let label = UILabel()
        label.text = "SENİN İÇİN BURADAN BAŞLAYALIM"
        label.font = .systemFont(
            ofSize: 12,
            weight: .bold
        )
        label.textColor = UIColor(
            red: 235/255,
            green: 70/255,
            blue: 151/255,
            alpha: 1
        )
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 31,
            weight: .bold
        )
        label.textColor = UIColor(
            red: 44/255,
            green: 31/255,
            blue: 49/255,
            alpha: 1
        )
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )
        label.textColor = UIColor(
            red: 101/255,
            green: 84/255,
            blue: 109/255,
            alpha: 1
        )
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let previewCard: UIView = {
        let view = UIView()

        view.backgroundColor = UIColor.white.withAlphaComponent(0.86)
        view.layer.cornerRadius = 28

        view.layer.borderWidth = 1
        view.layer.borderColor =
            UIColor.white.withAlphaComponent(0.85).cgColor

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 14
        view.layer.shadowOffset = CGSize(
            width: 0,
            height: 6
        )

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let previewStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let previewIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(
            red: 242/255,
            green: 92/255,
            blue: 184/255,
            alpha: 1
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let previewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 22,
            weight: .bold
        )
        label.textColor = UIColor(
            red: 45/255,
            green: 36/255,
            blue: 48/255,
            alpha: 1
        )
        label.numberOfLines = 0
        return label
    }()

    private let previewBodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 16,
            weight: .regular
        )
        label.textColor = UIColor(
            red: 95/255,
            green: 82/255,
            blue: 100/255,
            alpha: 1
        )
        label.numberOfLines = 0
        return label
    }()

    private let continueButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton()

        button.setTitle(
            "Devam edelim",
            for: .normal
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Init

    init(
        coordinator: FirstExperienceCoordinator,
        need: FirstExperienceNeed
    ) {

        self.coordinator = coordinator
        self.need = need
        self.viewModel = FirstExperiencePreviewViewModel(
            need: need
        )

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupLayout()
        configureForSelectedNeed()
        bindViewModel()
        loadPreviewData()

        backButton.addTarget(
            self,
            action: #selector(backTapped),
            for: .touchUpInside
        )

        continueButton.addTarget(
            self,
            action: #selector(continueTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Setup

    private func setupView() {

        view.backgroundColor = .black

        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(scrollView)
        view.addSubview(continueButton)

        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        contentView.addSubview(stepBadgeView)
        stepBadgeView.addSubview(stepLabel)

        contentView.addSubview(eyebrowLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        contentView.addSubview(previewCard)
        previewCard.addSubview(previewStack)

        previewStack.addArrangedSubview(
            previewIconView
        )

        previewStack.addArrangedSubview(
            previewTitleLabel
        )

        previewStack.addArrangedSubview(
            previewBodyLabel
        )
    }

    private func setupLayout() {

        NSLayoutConstraint.activate([

            // Background

            backgroundImageView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            backgroundImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            backgroundImageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            backgroundImageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            overlayView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            overlayView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            overlayView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            overlayView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            // Bottom CTA

            continueButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            continueButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),
            continueButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            continueButton.heightAnchor.constraint(
                equalToConstant: 62
            ),

            // Scroll

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
                equalTo: continueButton.topAnchor,
                constant: -18
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

            // Header top row

            backButton.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 18
            ),
            backButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),
            backButton.widthAnchor.constraint(
                equalToConstant: 40
            ),
            backButton.heightAnchor.constraint(
                equalToConstant: 40
            ),

            stepBadgeView.centerYAnchor.constraint(
                equalTo: backButton.centerYAnchor
            ),
            stepBadgeView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),

            stepLabel.topAnchor.constraint(
                equalTo: stepBadgeView.topAnchor,
                constant: 8
            ),
            stepLabel.leadingAnchor.constraint(
                equalTo: stepBadgeView.leadingAnchor,
                constant: 12
            ),
            stepLabel.trailingAnchor.constraint(
                equalTo: stepBadgeView.trailingAnchor,
                constant: -12
            ),
            stepLabel.bottomAnchor.constraint(
                equalTo: stepBadgeView.bottomAnchor,
                constant: -8
            ),

            // Text

            eyebrowLabel.topAnchor.constraint(
                equalTo: backButton.bottomAnchor,
                constant: 28
            ),
            eyebrowLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),
            eyebrowLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),

            titleLabel.topAnchor.constraint(
                equalTo: eyebrowLabel.bottomAnchor,
                constant: 10
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: eyebrowLabel.leadingAnchor
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: eyebrowLabel.trailingAnchor
            ),

            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 12
            ),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),

            // Preview card

            previewCard.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: 28
            ),
            previewCard.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),
            previewCard.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),
            previewCard.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -24
            ),

            previewStack.topAnchor.constraint(
                equalTo: previewCard.topAnchor,
                constant: 22
            ),
            previewStack.leadingAnchor.constraint(
                equalTo: previewCard.leadingAnchor,
                constant: 22
            ),
            previewStack.trailingAnchor.constraint(
                equalTo: previewCard.trailingAnchor,
                constant: -22
            ),
            previewStack.bottomAnchor.constraint(
                equalTo: previewCard.bottomAnchor,
                constant: -24
            ),

            previewIconView.heightAnchor.constraint(
                equalToConstant: 42
            )
        ])
    }

    // MARK: - Selection

    private func configureForSelectedNeed() {
        
        print(
            "🌸 PREVIEW SECTION:",
            need.rawValue,
            need.previewSection
        )

        switch need.previewSection {

        case .actions:

            titleLabel.text =
                "Bugün kendin için yapabileceğin bir şey var."

            subtitleLabel.text =
                "Lunora günün gökyüzünü yalnızca yorumlamakla kalmaz; onu küçük ve uygulanabilir önerilere dönüştürür."

            previewIconView.image =
                UIImage(systemName: "sparkles")

            previewTitleLabel.text =
                "Bugün Bunları Yapabilirsin"

            previewBodyLabel.text =
                "Birazdan burada bugünün gerçek önerilerinden birini göstereceğiz."

        case .energy:

            titleLabel.text =
                "Bugünün havasını biraz daha yakından görelim."

            subtitleLabel.text =
                "Günün astrolojik temasını, günlük hayatında neye dikkat edebileceğini anlatan kısa bir rehbere dönüştürüyoruz."

            previewIconView.image =
                UIImage(systemName: "moon.stars.fill")

            previewTitleLabel.text =
                "Bugünün Enerjisi"

            previewBodyLabel.text =
                "Birazdan burada bugünün gerçek enerji yorumunu göstereceğiz."

        case .programs:

            titleLabel.text =
                "Değişim tek bir güne sığmak zorunda değil."

            subtitleLabel.text =
                "Lunora programları, bir konuyu gün gün ilerleyen küçük adımlarla çalışmana yardımcı olur."

            previewIconView.image =
                UIImage(systemName: "leaf.fill")

            previewTitleLabel.text =
                "Programlar"

            previewBodyLabel.text =
                "Birazdan burada başlayabileceğin gerçek bir Lunora programını göstereceğiz."

        case .relationships:

            titleLabel.text =
                "Bugün ilişkilerinde neye bakabileceğini görelim."

            subtitleLabel.text =
                "Günün temasını ilişkilerde alan, iletişim ve ihtiyaçlar açısından daha somut hale getiriyoruz."

            previewIconView.image =
                UIImage(systemName: "heart.fill")

            previewTitleLabel.text =
                "İlişkilerde Bugün"

            previewBodyLabel.text =
                "Birazdan burada bugünün gerçek ilişki yorumunu göstereceğiz."

        case .beauty:

            titleLabel.text =
                "Bakım için bugünün ritmine bakalım."

            subtitleLabel.text =
                "Bazı günlerde bakım başlıklarını da gökyüzünün genel temasına göre öne çıkarıyoruz."

            previewIconView.image =
                UIImage(systemName: "wand.and.stars")

            previewTitleLabel.text =
                "Güzellik & Bakım"

            previewBodyLabel.text =
                "Birazdan burada bugünün gerçek bakım önerilerini göstereceğiz."
        }
    }
    
    // MARK: - ViewModel

    private func bindViewModel() {

        viewModel.onStateChange = { [weak self] state in

            guard let self else {
                return
            }

            self.render(state)
        }
    }

    private func loadPreviewData() {

        Task { [weak self] in

            guard let self else {
                return
            }

            await self.viewModel.load()
        }
    }

    private func render(
        _ state: FirstExperiencePreviewViewModel.State
    ) {

        switch state {

        case .idle:
            break

        case .loading:

            continueButton.isEnabled = false
            continueButton.alpha = 0.55

            previewBodyLabel.text =
                "Bugünün içeriği hazırlanıyor..."

        case .loaded(let content):
            continueButton.isEnabled = true
            continueButton.alpha = 1.0

            previewTitleLabel.text = content.title

            if need.previewSection == .relationships {
                previewBodyLabel.attributedText =
                    makeRelationshipAttributedText(content.body)
            } else {
                previewBodyLabel.attributedText = nil
                previewBodyLabel.text = content.body
            }

        case .unavailable:

            continueButton.isEnabled = false
            continueButton.alpha = 0.55

            previewTitleLabel.text =
                "Bugünün içeriğine ulaşamadık"

            previewBodyLabel.text =
                "Bağlantını kontrol edip biraz sonra tekrar deneyebilirsin."
        }
    }
    
    private func makeRelationshipAttributedText(
        _ text: String
    ) -> NSAttributedString {

        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(
                    ofSize: 16,
                    weight: .regular
                ),
                .foregroundColor:
                    UIColor(
                        red: 95/255,
                        green: 82/255,
                        blue: 100/255,
                        alpha: 1
                    )
            ]
        )

        let headings = [
            "Bugün iyi gelebilir",
            "Bugün Dikkat"
        ]

        for heading in headings {

            let range =
                (text as NSString).range(
                    of: heading
                )

            guard range.location != NSNotFound else {
                continue
            }

            attributed.addAttributes(
                [
                    .font: UIFont.systemFont(
                        ofSize: 16,
                        weight: .bold
                    ),
                    .foregroundColor:
                        UIColor(
                            red: 167/255,
                            green: 67/255,
                            blue: 123/255,
                            alpha: 1
                        )
                ],
                range: range
            )
        }

        return attributed
    }
    
    private func showUnavailableContent() {

        previewTitleLabel.text =
            "Bugünün içeriğine ulaşamadık"

        previewBodyLabel.text =
            "Bu içerik şu anda hazır değil."
    }

    // MARK: - Actions

    @objc
    private func backTapped() {

        coordinator.moveBack()
        onBack?()
    }

    @objc
    private func continueTapped() {

        coordinator.moveToSecondPillar()
        onContinue?()
    }
}
