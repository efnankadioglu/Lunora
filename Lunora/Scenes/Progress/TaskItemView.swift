//
//  TaskItemView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 9.04.2026.
//

import UIKit

final class TaskItemView: UIView {

    private let titleLabel = UILabel()
    private let descLabel = UILabel()

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.97, alpha: 1)
        v.layer.cornerRadius = 16
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(descLabel)

        container.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        descLabel.font = UIFont.systemFont(ofSize: 14)
        descLabel.textColor = .gray
        descLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }

    func configure(task: DailyTask) {
        titleLabel.text = task.title
        descLabel.text = task.shortDescription
    }
}
