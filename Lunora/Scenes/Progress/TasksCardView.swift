//
//  TasksCardView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 9.04.2026.
//

import UIKit

final class TasksCardView: UIView {

    var onToggleTaskCompletion: ((String) -> Void)?
    var onToggleTaskExpansion: ((String) -> Void)?

    private var tasks: [DailyTask] = []
    private var statesByTaskId: [String: DailyTaskUIState] = [:]

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

    private let headerStack = UIStackView()
    private let titleLabel = UILabel()

    private let progressBadgeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 252/255, green: 242/255, blue: 249/255, alpha: 1)
        view.layer.cornerRadius = 16
        return view
    }()

    private let progressIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.systemPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let progressLabel = UILabel()
    private let tasksStackView = UIStackView()
    private let progressTitleLabel = UILabel()
    private let progressPercentLabel = UILabel()
    private let progressTrackView = UIView()
    private let progressFillView = UIView()

    private var progressFillWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(tasks: [DailyTask], states: [DailyTaskUIState]) {
        self.tasks = tasks
        self.statesByTaskId = Dictionary(uniqueKeysWithValues: states.map { ($0.taskId, $0) })
        render()
    }

    func update(states: [DailyTaskUIState]) {
        self.statesByTaskId = Dictionary(uniqueKeysWithValues: states.map { ($0.taskId, $0) })
        render()
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(containerView)

        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .equalSpacing

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Bugünün Görevleri"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)

        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = .systemFont(ofSize: 15, weight: .bold)
        progressLabel.textColor = UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)

        tasksStackView.translatesAutoresizingMaskIntoConstraints = false
        tasksStackView.axis = .vertical
        tasksStackView.spacing = 12
        tasksStackView.alignment = .fill
        tasksStackView.distribution = .fill
        tasksStackView.setContentHuggingPriority(.required, for: .vertical)
        tasksStackView.setContentCompressionResistancePriority(.required, for: .vertical)

        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressTitleLabel.text = "Günlük ilerleme"
        progressTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        progressTitleLabel.textColor = UIColor.systemGray

        progressPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        progressPercentLabel.font = .systemFont(ofSize: 15, weight: .bold)
        progressPercentLabel.textColor = UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)

        progressTrackView.translatesAutoresizingMaskIntoConstraints = false
        progressTrackView.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 236/255, alpha: 1)
        progressTrackView.layer.cornerRadius = 6
        progressTrackView.clipsToBounds = true

        progressFillView.translatesAutoresizingMaskIntoConstraints = false
        progressFillView.backgroundColor = UIColor(red: 247/255, green: 158/255, blue: 205/255, alpha: 1)
        progressFillView.layer.cornerRadius = 6

        containerView.addSubview(headerStack)
        containerView.addSubview(tasksStackView)
        containerView.addSubview(progressTitleLabel)
        containerView.addSubview(progressPercentLabel)
        containerView.addSubview(progressTrackView)

        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(progressBadgeView)

        progressBadgeView.addSubview(progressIconView)
        progressBadgeView.addSubview(progressLabel)

        progressTrackView.addSubview(progressFillView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            progressIconView.leadingAnchor.constraint(equalTo: progressBadgeView.leadingAnchor, constant: 10),
            progressIconView.centerYAnchor.constraint(equalTo: progressBadgeView.centerYAnchor),
            progressIconView.widthAnchor.constraint(equalToConstant: 14),
            progressIconView.heightAnchor.constraint(equalToConstant: 14),

            progressLabel.leadingAnchor.constraint(equalTo: progressIconView.trailingAnchor, constant: 6),
            progressLabel.trailingAnchor.constraint(equalTo: progressBadgeView.trailingAnchor, constant: -10),
            progressLabel.topAnchor.constraint(equalTo: progressBadgeView.topAnchor, constant: 8),
            progressLabel.bottomAnchor.constraint(equalTo: progressBadgeView.bottomAnchor, constant: -8),

            tasksStackView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 18),
            tasksStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tasksStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            progressTitleLabel.topAnchor.constraint(equalTo: tasksStackView.bottomAnchor, constant: 20),
            progressTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            progressPercentLabel.centerYAnchor.constraint(equalTo: progressTitleLabel.centerYAnchor),
            progressPercentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            progressTrackView.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 10),
            progressTrackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            progressTrackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            progressTrackView.heightAnchor.constraint(equalToConstant: 12),
            progressTrackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),

            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor)
        ])

        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidthConstraint?.isActive = true
    }

    private func render() {
        tasksStackView.arrangedSubviews.forEach {
            tasksStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let completedCount = tasks.filter { statesByTaskId[$0.id]?.isCompleted == true }.count
        let totalCount = tasks.count
        let progress = totalCount > 0 ? CGFloat(completedCount) / CGFloat(totalCount) : 0

        progressLabel.text = "\(completedCount)/\(totalCount)"
        progressPercentLabel.text = "\(Int(progress * 100))%"

        for task in tasks {
            guard let state = statesByTaskId[task.id] else { continue }

            let taskView = TaskAccordionView()
            taskView.translatesAutoresizingMaskIntoConstraints = false
            taskView.setContentHuggingPriority(.required, for: .vertical)
            taskView.setContentCompressionResistancePriority(.required, for: .vertical)
            taskView.configure(task: task, uiState: state)

            taskView.onToggleComplete = { [weak self] in
                self?.onToggleTaskCompletion?(task.id)
            }

            taskView.onToggleExpand = { [weak self] in
                self?.onToggleTaskExpansion?(task.id)
            }

            tasksStackView.addArrangedSubview(taskView)
        }

        layoutIfNeeded()
        progressFillWidthConstraint?.isActive = false
        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(
            equalTo: progressTrackView.widthAnchor,
            multiplier: progress
        )
        progressFillWidthConstraint?.isActive = true

        invalidateIntrinsicContentSize()
        containerView.invalidateIntrinsicContentSize()
        tasksStackView.invalidateIntrinsicContentSize()
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()

        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
}
