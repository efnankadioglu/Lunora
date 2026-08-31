//
//  ProgramTableViewCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 9.12.2025.
//

import UIKit

final class ProgramTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ProgramTableViewCell"

    var onTapStartButton: (() -> Void)?

    // MARK: - Card

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = UIColor.white.withAlphaComponent(0.58)
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
        view.layer.masksToBounds = true

        return view
    }()

    // MARK: - Image

    private let programImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear

        // Görsel alanımız constraint'te 56x56 olduğu için
        // radius = 28 kesin daire oluşturur.
        imageView.layer.cornerRadius = 28
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true

        return imageView
    }()

    // MARK: - Labels

    private let programNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let baseFont = UIFont.systemFont(
            ofSize: 22,
            weight: .semibold
        )

        label.font = UIFontMetrics(
            forTextStyle: .title2
        ).scaledFont(for: baseFont)

        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.label.withAlphaComponent(0.96)

        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail

        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let baseFont = UIFont.systemFont(
            ofSize: 16,
            weight: .regular
        )

        label.font = UIFontMetrics(
            forTextStyle: .body
        ).scaledFont(for: baseFont)

        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.label.withAlphaComponent(0.65)

        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail

        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    // MARK: - Level Badge

    private lazy var levelButton: UIButton = {
        let button = makePinkBadgeButton()
        button.isUserInteractionEnabled = false

        return button
    }()

    // MARK: - Duration Badge

    private lazy var durationButton: UIButton = {
        let button = makePinkBadgeButton()
        button.isUserInteractionEnabled = false

        return button
    }()

    // MARK: - Start Button

    private lazy var startButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Başlat", for: .normal)

        // GradientPrimaryButton içinde 20 tanımlı.
        // Hücre tasarımına uyması için burada küçültüyoruz.
        button.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )

        button.addTarget(
            self,
            action: #selector(didTapStartButton),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: - Stack Views

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12

        return stackView
    }()

    private let footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12

        return stackView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 9

        return stackView
    }()

    private let headerSpacerView = UIView()
    private let footerSpacerView = UIView()

    // MARK: - Init

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        setupUI()
        setupHierarchy()
        setupConstraints()

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (cell: ProgramTableViewCell, _) in
            cell.updateResponsiveLayout()
        }
    }

    required init?(coder: NSCoder) {
        fatalError(
            "ProgramTableViewCell storyboard/XIB ile oluşturulmamalıdır."
        )
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        programImageView.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        levelButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        durationButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        startButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )

        durationButton.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        startButton.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        updateResponsiveLayout()
    }

    private func setupHierarchy() {
        contentView.addSubview(cardView)
        cardView.addSubview(contentStackView)

        headerStackView.addArrangedSubview(programImageView)
        headerStackView.addArrangedSubview(headerSpacerView)
        headerStackView.addArrangedSubview(levelButton)

        footerStackView.addArrangedSubview(durationButton)
        footerStackView.addArrangedSubview(footerSpacerView)
        footerStackView.addArrangedSubview(startButton)

        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(programNameLabel)
        contentStackView.addArrangedSubview(summaryLabel)
        contentStackView.addArrangedSubview(footerStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // Kart, table view genişliğini kullanır.
            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),

            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),

            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            cardView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -4
            ),

            // Kart iç boşlukları
            contentStackView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 12
            ),

            contentStackView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 18
            ),

            contentStackView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -18
            ),

            contentStackView.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -12
            ),

            // Program görseli
            programImageView.widthAnchor.constraint(
                equalToConstant: 56
            ),

            programImageView.heightAnchor.constraint(
                equalTo: programImageView.widthAnchor
            ),

            // Zorluk rozeti
            levelButton.heightAnchor.constraint(
                equalToConstant: 38
            ),

            levelButton.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 156
            ),

            // Süre rozeti
            durationButton.heightAnchor.constraint(
                equalToConstant: 36
            ),

            durationButton.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 98
            ),

            // Başlat butonu
            startButton.heightAnchor.constraint(
                equalToConstant: 44
            ),

            startButton.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 136
            )
        ])
    }

    // MARK: - Configure
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        print(
//            "🔵 CELL LAYOUT:",
//            programNameLabel.text ?? "nil",
//            "| frame:",
//            programImageView.frame,
//            "| bounds:",
//            programImageView.bounds,
//            "| radius:",
//            programImageView.layer.cornerRadius,
//            "| masks:",
//            programImageView.layer.masksToBounds
//        )
    }

    func configure(with program: Program) {

        programNameLabel.text = program.name
        summaryLabel.text = program.oneSentenceSummary

        programImageView.image =
            UIImage(named: program.imageName)
            ?? UIImage(named: "program_placeholder")

        if let recommendedStartText = makeRecommendedStartText(for: program) {
            levelButton.setTitle(
                "Önerilen · \(recommendedStartText)",
                for: .normal
            )
        } else {
            levelButton.setTitle(
                "Zorluk \(program.difficultyLevel)/\(program.difficultyScale)",
                for: .normal
            )
        }

        durationButton.setTitle(
            program.durationText,
            for: .normal
        )

        setNeedsLayout()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()

            self.setNeedsLayout()
            self.layoutIfNeeded()

            self.programImageView.layer.cornerRadius =
                self.programImageView.bounds.width / 2

            self.programImageView.layer.masksToBounds = true
        }
    }

    func applyStartButtonState(isActiveProgram: Bool) {
        if isActiveProgram {
            startButton.setTitle("Aktif", for: .normal)
            startButton.alpha = 0.75
        } else {
            startButton.setTitle("Başlat", for: .normal)
            startButton.alpha = 1
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        programImageView.image = nil
        programNameLabel.text = nil
        summaryLabel.text = nil

        levelButton.setTitle(nil, for: .normal)
        durationButton.setTitle(nil, for: .normal)

        startButton.setTitle("Başlat", for: .normal)
        startButton.alpha = 1

        onTapStartButton = nil
    }

    // MARK: - Layout


    private func updateResponsiveLayout() {
        let usesAccessibilitySize =
            traitCollection.preferredContentSizeCategory
                .isAccessibilityCategory

        if usesAccessibilitySize {
            footerStackView.axis = .vertical
            footerStackView.alignment = .fill
            footerSpacerView.isHidden = true
        } else {
            footerStackView.axis = .horizontal
            footerStackView.alignment = .center
            footerSpacerView.isHidden = false
        }
    }

    // MARK: - Badge Helper
    
    private func makeRecommendedStartText(
        for program: Program
    ) -> String? {

        guard
            let dateString =
                program.astroProfile?
                    .availability?
                    .recommendedStartDate
        else {
            return nil
        }

        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(
            identifier: "Europe/Istanbul"
        )
        inputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "tr_TR")
        outputFormatter.timeZone = TimeZone(
            identifier: "Europe/Istanbul"
        )
        outputFormatter.dateFormat = "d MMMM"

        return outputFormatter.string(from: date)
    }

    private func makePinkBadgeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.filled()

        configuration.baseForegroundColor = .white

        configuration.baseBackgroundColor = UIColor(
            red: 250 / 255,
            green: 169 / 255,
            blue: 216 / 255,
            alpha: 1
        )

        configuration.cornerStyle = .capsule

        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 7,
            leading: 16,
            bottom: 7,
            trailing: 16
        )

        button.configuration = configuration

        button.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )

        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8

        return button
    }
    // MARK: - Action

    @objc
    private func didTapStartButton() {
        onTapStartButton?()
    }
}
