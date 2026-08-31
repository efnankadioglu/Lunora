//
//  NotificationsViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.08.2026.
//

import UIKit
import UserNotifications

final class NotificationsViewController: UIViewController {

    // MARK: - Properties

    private var notifications: [NotificationInboxItem] = []

    private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Colors

    private let backgroundColor = UIColor(
        red: 1.0,
        green: 0.94,
        blue: 0.97,
        alpha: 1
    )

    private let primaryTextColor = UIColor(
        red: 0.16,
        green: 0.16,
        blue: 0.20,
        alpha: 1
    )

    // MARK: - Header

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bildirimler"
        label.font = .systemFont(
            ofSize: 30,
            weight: .bold
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Permission Card

    private let permissionCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let permissionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 14,
            weight: .medium
        )
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let permissionButton: UIButton = {
        let button = UIButton(type: .system)

        button.titleLabel?.font = .systemFont(
            ofSize: 14,
            weight: .semibold
        )

        button.setTitleColor(
            .systemPink,
            for: .normal
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var permissionCardHeightConstraint =
        permissionCard.heightAnchor.constraint(
            equalToConstant: 0
        )

    // MARK: - Table

    private let tableView: UITableView = {

        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.rowHeight =
            UITableView.automaticDimension

        tableView.estimatedRowHeight = 100

        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    // MARK: - Empty State

    private let emptyStateContainer = UIView()

    private let iconContainerView: UIView = {

        let view = UIView()

        view.backgroundColor =
            UIColor.systemPink.withAlphaComponent(0.10)

        view.layer.cornerRadius = 42

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let bellImageView: UIImageView = {

        let imageView = UIImageView(
            image: UIImage(
                systemName: "bell.fill"
            )
        )

        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let stateTitleLabel: UILabel = {

        let label = UILabel()

        label.text = "Henüz bildirimin yok"

        label.font = .systemFont(
            ofSize: 22,
            weight: .bold
        )

        label.textAlignment = .center
        label.numberOfLines = 0

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let descriptionLabel: UILabel = {

        let label = UILabel()

        label.text =
            "Yeni bildirimlerin geldiğinde burada görünecek. ✨"

        label.font = .systemFont(
            ofSize: 16,
            weight: .regular
        )

        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        setupUI()
        setupTableView()

        observeNotifications()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {

        super.viewWillAppear(animated)

        checkNotificationState()
    }

    deinit {
        NotificationInboxService.shared.stopListening()
    }

    // MARK: - Setup

    private func setupUI() {

        view.backgroundColor = backgroundColor

        titleLabel.textColor = primaryTextColor

        view.addSubview(titleLabel)
        view.addSubview(permissionCard)
        view.addSubview(tableView)

        permissionCard.addSubview(permissionLabel)
        permissionCard.addSubview(permissionButton)

        permissionButton.addTarget(
            self,
            action: #selector(permissionButtonTapped),
            for: .touchUpInside
        )

        permissionCard.isHidden = true

        permissionCardHeightConstraint.isActive = true

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),

            permissionCard.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 18
            ),

            permissionCard.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            permissionCard.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            permissionLabel.leadingAnchor.constraint(
                equalTo: permissionCard.leadingAnchor,
                constant: 16
            ),

            permissionLabel.centerYAnchor.constraint(
                equalTo: permissionCard.centerYAnchor
            ),

            permissionButton.trailingAnchor.constraint(
                equalTo: permissionCard.trailingAnchor,
                constant: -16
            ),

            permissionButton.centerYAnchor.constraint(
                equalTo: permissionCard.centerYAnchor
            ),

            permissionButton.leadingAnchor.constraint(
                greaterThanOrEqualTo: permissionLabel.trailingAnchor,
                constant: 12
            ),

            tableView.topAnchor.constraint(
                equalTo: permissionCard.bottomAnchor,
                constant: 12
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])

        setupEmptyState()
    }

    private func setupEmptyState() {

        emptyStateContainer.addSubview(iconContainerView)

        iconContainerView.addSubview(bellImageView)

        emptyStateContainer.addSubview(stateTitleLabel)
        emptyStateContainer.addSubview(descriptionLabel)

        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false

        tableView.addSubview(emptyStateContainer)

        NSLayoutConstraint.activate([

            emptyStateContainer.centerXAnchor.constraint(
                equalTo: tableView.centerXAnchor
            ),

            emptyStateContainer.centerYAnchor.constraint(
                equalTo: tableView.centerYAnchor,
                constant: -50
            ),

            emptyStateContainer.leadingAnchor.constraint(
                greaterThanOrEqualTo: tableView.leadingAnchor,
                constant: 30
            ),

            emptyStateContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: tableView.trailingAnchor,
                constant: -30
            ),

            iconContainerView.topAnchor.constraint(
                equalTo: emptyStateContainer.topAnchor
            ),

            iconContainerView.centerXAnchor.constraint(
                equalTo: emptyStateContainer.centerXAnchor
            ),

            iconContainerView.widthAnchor.constraint(
                equalToConstant: 84
            ),

            iconContainerView.heightAnchor.constraint(
                equalToConstant: 84
            ),

            bellImageView.centerXAnchor.constraint(
                equalTo: iconContainerView.centerXAnchor
            ),

            bellImageView.centerYAnchor.constraint(
                equalTo: iconContainerView.centerYAnchor
            ),

            bellImageView.widthAnchor.constraint(
                equalToConstant: 34
            ),

            bellImageView.heightAnchor.constraint(
                equalToConstant: 34
            ),

            stateTitleLabel.topAnchor.constraint(
                equalTo: iconContainerView.bottomAnchor,
                constant: 24
            ),

            stateTitleLabel.leadingAnchor.constraint(
                equalTo: emptyStateContainer.leadingAnchor
            ),

            stateTitleLabel.trailingAnchor.constraint(
                equalTo: emptyStateContainer.trailingAnchor
            ),

            descriptionLabel.topAnchor.constraint(
                equalTo: stateTitleLabel.bottomAnchor,
                constant: 12
            ),

            descriptionLabel.leadingAnchor.constraint(
                equalTo: emptyStateContainer.leadingAnchor
            ),

            descriptionLabel.trailingAnchor.constraint(
                equalTo: emptyStateContainer.trailingAnchor
            ),

            descriptionLabel.bottomAnchor.constraint(
                equalTo: emptyStateContainer.bottomAnchor
            )
        ])
    }

    private func setupTableView() {

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            NotificationInboxCell.self,
            forCellReuseIdentifier: NotificationInboxCell.reuseIdentifier
        )
    }

    // MARK: - Notifications

    private func observeNotifications() {

        NotificationInboxService.shared
            .observeNotifications { [weak self] result in

                DispatchQueue.main.async {

                    guard let self else {
                        return
                    }

                    switch result {

                    case .success(let notifications):

                        self.notifications = notifications

                        self.tableView.reloadData()

                        self.updateEmptyState()

                    case .failure(let error):

                        print(
                            "❌ Notification inbox fetch failed: \(error.localizedDescription)"
                        )
                    }
                }
            }
    }

    private func updateEmptyState() {

        emptyStateContainer.isHidden =
            !notifications.isEmpty
    }

    // MARK: - Notification State

    private func checkNotificationState() {

        UNUserNotificationCenter.current()
            .getNotificationSettings { [weak self] settings in

                DispatchQueue.main.async {

                    guard let self else {
                        return
                    }

                    self.authorizationStatus =
                        settings.authorizationStatus

                    self.updatePermissionCard()
                }
            }
    }

    private func updatePermissionCard() {

        switch authorizationStatus {

        case .denied:

            showPermissionCard(
                text:
                    "iPhone bildirim iznin kapalı. Yeni Lunora bildirimlerini alabilmek için izin vermen gerekiyor.",
                buttonTitle: "Ayarları Aç"
            )

        case .notDetermined:

            showPermissionCard(
                text:
                    "Program ve gökyüzü bildirimlerini kaçırmamak için bildirimlere izin verebilirsin.",
                buttonTitle: "Bildirimleri Aç"
            )

        case .authorized,
             .provisional,
             .ephemeral:

            if areAllLunoraNotificationsDisabled() {

                showPermissionCard(
                    text:
                        "Lunora bildirim tercihlerin kapalı. İstediğin bildirim türlerini yeniden açabilirsin.",
                    buttonTitle: "Tercihleri Düzenle"
                )

            } else {

                hidePermissionCard()
            }

        @unknown default:

            hidePermissionCard()
        }
    }

    private func areAllLunoraNotificationsDisabled() -> Bool {

        let preferences =
            NotificationPreferences.shared

        if !preferences.areNotificationsEnabled {
            return true
        }

        let program =
            preferences.isEnabled(.program)

        let astrology =
            preferences.isEnabled(.astrology)

        let beauty =
            preferences.isEnabled(.beauty)

        return !program &&
            !astrology &&
            !beauty
    }

    private func showPermissionCard(
        text: String,
        buttonTitle: String
    ) {

        permissionLabel.text = text

        permissionButton.setTitle(
            buttonTitle,
            for: .normal
        )

        permissionCard.isHidden = false

        permissionCardHeightConstraint.constant = 96
    }

    private func hidePermissionCard() {

        permissionCard.isHidden = true

        permissionCardHeightConstraint.constant = 0
    }

    // MARK: - Actions

    @objc
    private func permissionButtonTapped() {

        switch authorizationStatus {

        case .notDetermined:

            NotificationManager.shared
                .requestNotificationPermission { [weak self] granted in

                    guard let self else {
                        return
                    }

                    if granted {

                        NotificationPreferences.shared
                            .setNotificationsEnabled(true)

                        NotificationPreferencesSyncService.shared
                            .syncCurrentPreferences()
                    }

                    self.checkNotificationState()
                }

        case .denied:

            NotificationManager.shared
                .openSystemNotificationSettings()

        case .authorized,
             .provisional,
             .ephemeral:

            let controller =
                NotificationSettingsViewController()

            navigationController?
                .pushViewController(
                    controller,
                    animated: true
                )

        @unknown default:
            break
        }
    }
}

// MARK: - UITableViewDataSource

extension NotificationsViewController:
    UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        notifications.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationInboxCell.reuseIdentifier,
            for: indexPath
        ) as? NotificationInboxCell else {

            return UITableViewCell()
        }

        cell.configure(
            with: notifications[indexPath.row]
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationsViewController:
    UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        let notification =
            notifications[indexPath.row]

        if !notification.isRead {

            NotificationInboxService.shared
                .markAsRead(
                    notificationId: notification.id
                )
        }

        // Bir sonraki aşamada:
        // notification.route değerine göre
        // doğru Lunora ekranına yönlendireceğiz.
    }
}

// MARK: - Cell

private final class NotificationInboxCell:
    UITableViewCell {

    static let reuseIdentifier =
        "NotificationInboxCell"

    private let cardView = UIView()

    private let unreadDot = UIView()

    private let titleLabel = UILabel()

    private let bodyLabel = UILabel()

    private let dateLabel = UILabel()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {

        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    private func setup() {

        backgroundColor = .clear

        selectionStyle = .none

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18

        unreadDot.backgroundColor = .systemPink
        unreadDot.layer.cornerRadius = 4

        titleLabel.font = .systemFont(
            ofSize: 16,
            weight: .semibold
        )

        titleLabel.numberOfLines = 0

        bodyLabel.font = .systemFont(
            ofSize: 14,
            weight: .regular
        )

        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        dateLabel.font = .systemFont(
            ofSize: 12,
            weight: .regular
        )

        dateLabel.textColor = .tertiaryLabel

        [
            cardView,
            unreadDot,
            titleLabel,
            bodyLabel,
            dateLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(cardView)

        cardView.addSubview(unreadDot)
        cardView.addSubview(titleLabel)
        cardView.addSubview(bodyLabel)
        cardView.addSubview(dateLabel)

        NSLayoutConstraint.activate([

            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),

            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 20
            ),

            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -20
            ),

            cardView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
            ),

            unreadDot.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 16
            ),

            unreadDot.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 20
            ),

            unreadDot.widthAnchor.constraint(
                equalToConstant: 8
            ),

            unreadDot.heightAnchor.constraint(
                equalToConstant: 8
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: unreadDot.trailingAnchor,
                constant: 10
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -16
            ),

            titleLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 16
            ),

            bodyLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 6
            ),

            bodyLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),

            bodyLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),

            dateLabel.topAnchor.constraint(
                equalTo: bodyLabel.bottomAnchor,
                constant: 10
            ),

            dateLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),

            dateLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),

            dateLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -16
            )
        ])
    }

    func configure(
        with notification: NotificationInboxItem
    ) {

        titleLabel.text = notification.title

        bodyLabel.text = notification.body

        unreadDot.isHidden =
            notification.isRead

        titleLabel.font = .systemFont(
            ofSize: 16,
            weight:
                notification.isRead
                ? .medium
                : .semibold
        )

        let formatter = DateFormatter()

        formatter.locale =
            Locale(identifier: "tr_TR")

        formatter.dateFormat =
            "d MMMM · HH:mm"

        dateLabel.text =
            formatter.string(
                from: notification.createdAt
            )
    }
}
