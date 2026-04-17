//
//  SegmentedDonutChartView.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 10.04.2026.
//

import UIKit

final class SegmentedDonutChartView: UIView {

    struct Segment {
        let value: CGFloat   // 0...1
        let color: UIColor
    }

    private let trackLayer = CAShapeLayer()
    private var segmentLayers: [CAShapeLayer] = []

    private let centerValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "48%"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let centerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "tamamlandı"
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(red: 113/255, green: 122/255, blue: 138/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private var segments: [Segment] = []
    private let lineWidth: CGFloat = 22
    private let segmentSpacing: CGFloat = 0.04

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
        drawChart()
    }

    func configure(segments: [Segment], totalText: String) {
        self.segments = segments
        centerValueLabel.text = totalText
        drawChart()
    }

    private func setupUI() {
        backgroundColor = .clear

        layer.addSublayer(trackLayer)
        addSubview(centerValueLabel)
        addSubview(centerSubtitleLabel)

        NSLayoutConstraint.activate([
            centerValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerValueLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6),

            centerSubtitleLabel.topAnchor.constraint(equalTo: centerValueLabel.bottomAnchor, constant: 2),
            centerSubtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func drawChart() {
        trackLayer.removeFromSuperlayer()
        segmentLayers.forEach { $0.removeFromSuperlayer() }
        segmentLayers.removeAll()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2

        guard radius > 0 else { return }

        let startAngle = -CGFloat.pi / 2
        let fullCircle = CGFloat.pi * 2

        let trackPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: fullCircle,
            clockwise: true
        )

        trackLayer.path = trackPath.cgPath
        trackLayer.strokeColor = UIColor(red: 231/255, green: 231/255, blue: 236/255, alpha: 1).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        var currentAngle = startAngle

        for segment in segments {
            let adjustedValue = max(0, min(segment.value, 1))
            let segmentAngle = fullCircle * adjustedValue

            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: currentAngle,
                endAngle: currentAngle + max(segmentAngle - segmentSpacing, 0),
                clockwise: true
            )

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = segment.color.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.lineCap = .round

            layer.addSublayer(shapeLayer)
            segmentLayers.append(shapeLayer)

            currentAngle += segmentAngle
        }
    }
} 

