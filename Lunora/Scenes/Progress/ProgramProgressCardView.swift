//
//  ProgramProgressCardView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 10.04.2026.
//

import UIKit

struct ProgramProgressCardLegendItem {
    let color: UIColor
    let title: String
    let valueText: String
    let chartValue: CGFloat
}

struct ProgramProgressCardData {
    let currentDay: Int
    let totalDays: Int
    let progressPercent: Int
    let donutCenterPercent: Int
    let legendItems: [ProgramProgressCardLegendItem]
}

final class ProgramProgressCardView: UIView {

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
        label.text = "Program İlerlemen"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
        return label
    }()

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Gün 15 / 30"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 113/255, green: 122/255, blue: 138/255, alpha: 1)
        return label
    }()

    private let percentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "48%"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)
        label.textAlignment = .right
        return label
    }()
    
    private let donutChartView: SegmentedDonutChartView = {
        let view = SegmentedDonutChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        label.text = "Genel ilerleme"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
        return label
    }()

    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "48%"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor =  UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)
        label.textAlignment = .right
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 236/255, alpha: 1)
        view.layer.cornerRadius = 7
        view.clipsToBounds = true
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1)
        view.layer.cornerRadius = 7
        return view
    }()

    private var progressFillWidthConstraint: NSLayoutConstraint?
    private var currentProgressMultiplier: CGFloat = 0

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
        progressFillWidthConstraint?.constant = progressTrackView.bounds.width * currentProgressMultiplier
    }

    func configure(with data: ProgramProgressCardData) {
        dayLabel.text = "Gün \(data.currentDay) / \(data.totalDays)"
        percentLabel.text = "\(data.progressPercent)%"
        progressPercentLabel.text = "\(data.progressPercent)%"

        let progress = CGFloat(data.progressPercent) / 100.0

        updateProgressFill(multiplier: progress)

        let progressColor = UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1)
        let segments = [
            SegmentedDonutChartView.Segment(
                value: progress,
                color: progressColor
            )
        ]

        donutChartView.configure(
            segments: segments,
            totalText: "\(data.donutCenterPercent)%"
        )
    }
    
    private func updateProgressFill(multiplier: CGFloat) {
        currentProgressMultiplier = max(0, min(1, multiplier))
        progressFillWidthConstraint?.constant = progressTrackView.bounds.width * currentProgressMultiplier

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(dayLabel)
        containerView.addSubview(percentLabel)
        
        containerView.addSubview(donutChartView)

        containerView.addSubview(dividerView)
        containerView.addSubview(progressTitleLabel)
        containerView.addSubview(progressPercentLabel)
        containerView.addSubview(progressTrackView)
        
        containerView.addSubview(progressTitleLabel)
        containerView.addSubview(progressPercentLabel)
        containerView.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),

            dayLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),

            percentLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            donutChartView.topAnchor.constraint(
                equalTo: dayLabel.bottomAnchor,
                constant: 24
            ),

            donutChartView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor
            ),

            donutChartView.widthAnchor.constraint(
                equalToConstant: 140
            ),

            donutChartView.heightAnchor.constraint(
                equalToConstant: 140
            ),

            dividerView.topAnchor.constraint(
                equalTo: donutChartView.bottomAnchor,
                constant: 24
            ),

            dividerView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 24
            ),

            dividerView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -24
            ),

            dividerView.heightAnchor.constraint(
                equalToConstant: 1
            ),
            
            
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            dividerView.heightAnchor.constraint(equalToConstant: 1),

            progressTitleLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20),
            progressTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),

            progressPercentLabel.centerYAnchor.constraint(equalTo: progressTitleLabel.centerYAnchor),
            progressPercentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            progressTrackView.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 12),
            progressTrackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            progressTrackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            progressTrackView.heightAnchor.constraint(equalToConstant: 14),
            progressTrackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),

            progressFillView.topAnchor.constraint(equalTo: progressTrackView.topAnchor),
            progressFillView.leadingAnchor.constraint(equalTo: progressTrackView.leadingAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: progressTrackView.bottomAnchor),

//            heightAnchor.constraint(greaterThanOrEqualToConstant: 460)
        ])
        progressFillWidthConstraint = progressFillView.widthAnchor.constraint(equalToConstant: 0)
        progressFillWidthConstraint?.isActive = true
    }
    

}
    


