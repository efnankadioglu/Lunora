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

    private let legendStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
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
    
//    func configure(with data: ProgramProgressCardData) {
//        dayLabel.text = "Gün \(data.currentDay) / \(data.totalDays)"
//        percentLabel.text = "\(data.progressPercent)%"
//        progressPercentLabel.text = "\(data.progressPercent)%"
//
//        updateProgressFill(multiplier: CGFloat(data.progressPercent) / 100.0)
//
//        // Legend yenile
//        legendStackView.arrangedSubviews.forEach {
//            legendStackView.removeArrangedSubview($0)
//            $0.removeFromSuperview()
//        }
//
//        data.legendItems.forEach { item in
//            legendStackView.addArrangedSubview(
//                makeLegendRow(color: item.color, title: item.title, value: item.valueText)
//            )
//        }
//
//        let segments = data.legendItems
//            .filter { $0.chartValue > 0 }
//            .map {
//                SegmentedDonutChartView.Segment(
//                    value: $0.chartValue,
//                    color: $0.color
//                )
//            }
//
//        donutChartView.configure(
//            segments: segments,
//            totalText: "\(data.donutCenterPercent)%"
//        )
//    }
    
    
    func configure(with data: ProgramProgressCardData) {
        dayLabel.text = "Gün \(data.currentDay) / \(data.totalDays)"
        percentLabel.text = "\(data.progressPercent)%"
        progressPercentLabel.text = "\(data.progressPercent)%"

        updateProgressFill(multiplier: CGFloat(data.progressPercent) / 100.0)

        legendStackView.arrangedSubviews.forEach {
            legendStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        data.legendItems.forEach { item in
            legendStackView.addArrangedSubview(
                makeLegendRow(color: item.color, title: item.title, value: item.valueText)
            )
        }

        let adjustedLegendItems = adjustedLegendItemsForChart(
            data.legendItems,
            currentDay: data.currentDay
        )

        let segments = adjustedLegendItems.map {
            SegmentedDonutChartView.Segment(
                value: $0.chartValue,
                color: $0.color
            )
        }

        donutChartView.configure(
            segments: segments,
            totalText: "\(data.donutCenterPercent)%"
        )
    }
    
    private func adjustedLegendItemsForChart(
        _ items: [ProgramProgressCardLegendItem],
        currentDay: Int
    ) -> [ProgramProgressCardLegendItem] {
        let visibleItems = items.filter { $0.chartValue > 0 }

        guard !visibleItems.isEmpty else {
            return []
        }

        let minimumVisibleValue = minimumVisibleChartValue(for: currentDay)

        var adjustedItems = items
        var totalAdjustedValue: CGFloat = 0

        for index in adjustedItems.indices {
            let originalValue = adjustedItems[index].chartValue

            if originalValue > 0, originalValue < minimumVisibleValue {
                adjustedItems[index] = ProgramProgressCardLegendItem(
                    color: adjustedItems[index].color,
                    title: adjustedItems[index].title,
                    valueText: adjustedItems[index].valueText,
                    chartValue: minimumVisibleValue
                )
            }

            totalAdjustedValue += adjustedItems[index].chartValue
        }

        if totalAdjustedValue > 1 {
            let scale = 1 / totalAdjustedValue

            adjustedItems = adjustedItems.map { item in
                ProgramProgressCardLegendItem(
                    color: item.color,
                    title: item.title,
                    valueText: item.valueText,
                    chartValue: item.chartValue * scale
                )
            }
        }

        return adjustedItems.filter { $0.chartValue > 0 }
    }

    private func minimumVisibleChartValue(for currentDay: Int) -> CGFloat {
        switch currentDay {
        case 1...4:
            return 0.015
        case 5...8:
            return 0.012
        case 9...14:
            return 0.010
        default:
            return 0.008
        }
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

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(dayLabel)
        containerView.addSubview(percentLabel)
        
        containerView.addSubview(donutChartView)

        containerView.addSubview(legendStackView)
        containerView.addSubview(dividerView)
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
            
            donutChartView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 24),
            donutChartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            donutChartView.widthAnchor.constraint(equalToConstant: 140),
            donutChartView.heightAnchor.constraint(equalToConstant: 140),

            legendStackView.centerYAnchor.constraint(equalTo: donutChartView.centerYAnchor),
            legendStackView.leadingAnchor.constraint(equalTo: donutChartView.trailingAnchor, constant: 24),

            legendStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            dividerView.topAnchor.constraint(equalTo: donutChartView.bottomAnchor, constant: 24),
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

            heightAnchor.constraint(equalToConstant: 400)
        ])
    }

    private func makeLegendRow(color: UIColor, title: String, value: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = color
        dotView.layer.cornerRadius = 7

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 55/255, green: 65/255, blue: 81/255, alpha: 1)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
        valueLabel.textAlignment = .right
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        row.addSubview(dotView)
        row.addSubview(titleLabel)
        row.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dotView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 14),
            dotView.heightAnchor.constraint(equalToConstant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10),
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            

            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])

        return row
    }
    

}
    


