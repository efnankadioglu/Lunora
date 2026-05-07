//
//  CompletedProgramTableViewCell.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.04.2026.
//
import UIKit

final class CompletedProgramTableViewCell: UITableViewCell {

    static let identifier = "CompletedProgramTableViewCell" // EKLEDİM

    private let cardView = UIView()
    private let badgeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    private let noteTitleLabel = UILabel()
    private let noteLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI() // EKLEDİM
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI() // EKLEDİM
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)

        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.contentMode = .scaleAspectFill
        badgeImageView.clipsToBounds = true
        badgeImageView.layer.cornerRadius = 28
        badgeImageView.backgroundColor = UIColor(red: 250/255, green: 244/255, blue: 248/255, alpha: 1)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
        titleLabel.numberOfLines = 2

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = UIColor(red: 113/255, green: 122/255, blue: 138/255, alpha: 1)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        durationLabel.textColor = UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)

        noteTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTitleLabel.text = "Kendine yazdığın not"
        noteTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        noteTitleLabel.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)

        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.font = .systemFont(ofSize: 14, weight: .regular)
        noteLabel.textColor = UIColor(red: 90/255, green: 98/255, blue: 112/255, alpha: 1)
        noteLabel.numberOfLines = 0

        contentView.addSubview(cardView)
        cardView.addSubview(badgeImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(durationLabel)
        cardView.addSubview(noteTitleLabel)
        cardView.addSubview(noteLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            badgeImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            badgeImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            badgeImageView.widthAnchor.constraint(equalToConstant: 56),
            badgeImageView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: badgeImageView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            durationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            noteTitleLabel.topAnchor.constraint(equalTo: badgeImageView.bottomAnchor, constant: 16),
            noteTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            noteTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            noteLabel.topAnchor.constraint(equalTo: noteTitleLabel.bottomAnchor, constant: 6),
            noteLabel.leadingAnchor.constraint(equalTo: noteTitleLabel.leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: noteTitleLabel.trailingAnchor),
            noteLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])
    }

    func configure(with item: CompletedProgramDisplayItem) { // EKLEDİM
        titleLabel.text = item.programName
        dateLabel.text = "Tamamlandı: \(item.completedDateText)"
        durationLabel.text = item.durationText
        badgeImageView.image = UIImage(named: item.imageName)

        let note = item.completionNote?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let note, !note.isEmpty {
            noteTitleLabel.isHidden = false
            noteLabel.isHidden = false
            noteLabel.text = note
        } else {
            noteTitleLabel.isHidden = true
            noteLabel.isHidden = true
            noteLabel.text = nil
        }
    }
}
