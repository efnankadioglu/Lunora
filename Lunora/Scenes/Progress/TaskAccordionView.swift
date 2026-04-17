//
//  TaskAccordionView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.04.2026.
//

import UIKit

final class TaskAccordionView: UIView {

    var onToggleExpand: (() -> Void)?
    var onToggleComplete: (() -> Void)?

    private var task: DailyTask?
    private var uiState: DailyTaskUIState?

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private let headerView = UIView()
    private let detailsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 254/255, alpha: 1)
        view.isHidden = true
        return view
    }()

    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.backgroundColor = .clear
        return button
    }()

    private let checkmarkLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "✓"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
        label.numberOfLines = 0
        return label
    }()

    private let shortDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(red: 113/255, green: 122/255, blue: 138/255, alpha: 1)
        label.numberOfLines = 0
        return label
    }()

    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = UIColor.systemGray3
        return button
    }()

    private let detailsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

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

    func configure(task: DailyTask, uiState: DailyTaskUIState) {
        self.task = task
        self.uiState = uiState

        titleLabel.text = task.title
        shortDescriptionLabel.text = task.shortDescription

        reloadDetails(items: task.details)
        updateCompletionUI(isCompleted: uiState.isCompleted)
        updateExpandedUI(isExpanded: uiState.isExpanded, animated: false)
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(cardView)
        cardView.addSubview(mainStackView)

        mainStackView.addArrangedSubview(headerView)
        mainStackView.addArrangedSubview(detailsContainerView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(shortDescriptionLabel)

        headerView.addSubview(completeButton)
        completeButton.addSubview(checkmarkLabel)
        headerView.addSubview(textStackView)
        headerView.addSubview(chevronButton)

        detailsContainerView.addSubview(detailsStackView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            mainStackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            completeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 18),
            completeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 36),
            completeButton.heightAnchor.constraint(equalToConstant: 36),

            checkmarkLabel.centerXAnchor.constraint(equalTo: completeButton.centerXAnchor),
            checkmarkLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),

            chevronButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -18),
            chevronButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            chevronButton.widthAnchor.constraint(equalToConstant: 26),
            chevronButton.heightAnchor.constraint(equalToConstant: 26),

            textStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 18),
            textStackView.leadingAnchor.constraint(equalTo: completeButton.trailingAnchor, constant: 14),
            textStackView.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor, constant: -12),
            textStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),

            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 92),

            detailsStackView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 18),
            detailsStackView.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 20),
            detailsStackView.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -20),
            detailsStackView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -18)
        ])

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func setupActions() {
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
        chevronButton.addTarget(self, action: #selector(didTapChevron), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapChevron))
        headerView.addGestureRecognizer(tap)
    }

    private func reloadDetails(items: [String]) {
        detailsStackView.arrangedSubviews.forEach {
            detailsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for item in items {
            let row = makeDetailRow(text: item)
            detailsStackView.addArrangedSubview(row)
        }
    }
    
    private func makeDetailRow(text: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let bulletLabel = UILabel()
        bulletLabel.translatesAutoresizingMaskIntoConstraints = false
        bulletLabel.text = "✓"
        bulletLabel.font = .systemFont(ofSize: 16, weight: .bold)
        bulletLabel.textColor = UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1)

        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 15, weight: .medium)
        textLabel.textColor = UIColor(red: 55/255, green: 65/255, blue: 81/255, alpha: 1) // gri
        textLabel.numberOfLines = 0

        row.addSubview(bulletLabel)
        row.addSubview(textLabel)

        NSLayoutConstraint.activate([
            bulletLabel.topAnchor.constraint(equalTo: row.topAnchor),
            bulletLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            bulletLabel.widthAnchor.constraint(equalToConstant: 18),

            textLabel.topAnchor.constraint(equalTo: row.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: bulletLabel.trailingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }

    private func updateCompletionUI(isCompleted: Bool) {
        if isCompleted {
            completeButton.layer.borderColor = UIColor.clear.cgColor
            completeButton.backgroundColor = UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1)
            checkmarkLabel.isHidden = false

            if let title = task?.title {
                titleLabel.attributedText = NSAttributedString(
                    string: title,
                    attributes: [
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                        .foregroundColor: UIColor.systemGray
                    ]
                )
            }
            shortDescriptionLabel.textColor = UIColor.systemGray3
        } else {
            completeButton.layer.borderColor = UIColor.systemGray4.cgColor
            completeButton.backgroundColor = .clear
            checkmarkLabel.isHidden = true

            titleLabel.attributedText = nil
            titleLabel.text = task?.title
            titleLabel.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
            shortDescriptionLabel.textColor = UIColor(red: 113/255, green: 122/255, blue: 138/255, alpha: 1)
        }
    }

    private func updateExpandedUI(isExpanded: Bool, animated: Bool) {
        detailsContainerView.isHidden = !isExpanded

        let animations = {
            self.chevronButton.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: animations)
        } else {
            animations()
        }
    }

    @objc private func didTapComplete() {
        onToggleComplete?()
    }

    @objc private func didTapChevron() {
        onToggleExpand?()
    }
}
