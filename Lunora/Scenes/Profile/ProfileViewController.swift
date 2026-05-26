//
//  ProfileViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileViewController: UIViewController {

    // MARK: - Properties

    private let db = Firestore.firestore()
    private let enrollmentRepository = EnrollmentRepository()

    private var hasActiveJourney: Bool = false
    private var isLoadingDailyInsight = false

    private let pageBackgroundColor = UIColor(named: "lunoraPink") ?? UIColor(
        red: 246/255,
        green: 238/255,
        blue: 244/255,
        alpha: 1
    )

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()

    private let headerContainerView = UIView()
    private let headerGradientLayer = CAGradientLayer()

    private let avatarContainerView = UIView()
    private let avatarImageView = UIImageView()
    private let avatarPlaceholderLabel = UILabel()

    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let motivationLabel = UILabel()

    private let statsStackView = UIStackView()
    private let completedProgramsValueLabel = UILabel()
    private let activeDaysValueLabel = UILabel()
    private let dayStreakValueLabel = UILabel()

    private let currentJourneyCardView = UIView()
    private let currentJourneyTitleLabel = UILabel()
    private let currentJourneyProgramLabel = UILabel()
    private let currentJourneyDayLabel = UILabel()
    private let currentJourneyProgressView = UIProgressView(progressViewStyle: .default)
    private let continueButton = GradientPrimaryButton(type: .system)

    private let achievementsCardView = UIView()
    private let achievementsStackView = UIStackView()
    private let achievementsScrollView = UIScrollView()
    private let achievementsSubtitleLabel = UILabel()

    private let elementCardView = UIView()
    private let elementTitleLabel = UILabel()
    private let elementMainLabel = UILabel()
    private let elementDescriptionLabel = UILabel()

    private let insightCardView = UIView()
    private let insightSectionTitleLabel = UILabel()
    private let insightTitleLabel = UILabel()
    private let insightSubtitleLabel = UILabel()
    private let insightBodyLabel = UILabel()

    private let settingsCardView = UIView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = pageBackgroundColor
        setupUI()
        applyLoadingState()
        loadProfileInfo()
        loadProfileDashboardData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadProfileInfo()
        loadProfileDashboardData()
        loadDailyInsight()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarContainerView.layer.cornerRadius = avatarContainerView.bounds.width / 2
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    // MARK: - Setup UI

    private func setupUI() {
        setupScrollView()
        setupMainStackView()
        setupHeader()
        setupStatsCards()
        setupCurrentJourneyCard()
        setupAchievementsCard()
        setupElementCard()
        setupInsightCard()
        setupSettingsCard()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = pageBackgroundColor
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = pageBackgroundColor

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupMainStackView() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 18
        mainStackView.alignment = .fill

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120)
        ])
    }

    private func setupHeader() {
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.backgroundColor = .white
        headerContainerView.layer.cornerRadius = 24
        headerContainerView.layer.shadowColor = UIColor.black.cgColor
        headerContainerView.layer.shadowOpacity = 0.06
        headerContainerView.layer.shadowRadius = 10
        headerContainerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        headerContainerView.clipsToBounds = false

        avatarContainerView.translatesAutoresizingMaskIntoConstraints = false
        avatarContainerView.backgroundColor = UIColor(hex: "#FFF4FA")
        avatarContainerView.layer.borderWidth = 3
        avatarContainerView.layer.borderColor = UIColor(hex: "#F3D4E8").cgColor
        avatarContainerView.clipsToBounds = true

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(named: "defaultAvatar")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.isHidden = true

        avatarPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarPlaceholderLabel.text = "✿"
        avatarPlaceholderLabel.font = .systemFont(ofSize: 36, weight: .semibold)
        avatarPlaceholderLabel.textAlignment = .center
        avatarPlaceholderLabel.textColor = UIColor(hex: "#E85A9F")

        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(avatarPlaceholderLabel)

        NSLayoutConstraint.activate([
            avatarContainerView.widthAnchor.constraint(equalToConstant: 76),
            avatarContainerView.heightAnchor.constraint(equalToConstant: 76),

            avatarImageView.topAnchor.constraint(equalTo: avatarContainerView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainerView.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarContainerView.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainerView.bottomAnchor),

            avatarPlaceholderLabel.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            avatarPlaceholderLabel.centerYAnchor.constraint(equalTo: avatarContainerView.centerYAnchor)
        ])

        nameLabel.text = "Lunora Soul"
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = UIColor(hex: "#171219")
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1

        usernameLabel.text = "@lunora"
        usernameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        usernameLabel.textColor = UIColor(hex: "#706575")
        usernameLabel.textAlignment = .center
        usernameLabel.numberOfLines = 1

        motivationLabel.text = "You're doing beautifully, keep shining ✨"
        motivationLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        motivationLabel.textColor = UIColor(hex: "#E85A9F")
        motivationLabel.textAlignment = .center
        motivationLabel.numberOfLines = 2

        let headerStack = UIStackView(arrangedSubviews: [
            avatarContainerView,
            nameLabel,
            usernameLabel,
            motivationLabel
        ])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 6

        headerContainerView.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 170),

            headerStack.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 20),
            headerStack.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 24),
            headerStack.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -24),
            headerStack.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -20)
        ])

        mainStackView.addArrangedSubview(headerContainerView)
    }

    private func setupStatsCards() {
        statsStackView.axis = .horizontal
        statsStackView.spacing = 10
        statsStackView.distribution = .fillEqually

        let completedCard = makeStatCard(
            valueLabel: completedProgramsValueLabel,
            initialValue: "0",
            title: "Completed",
            icon: "🏆",
            iconBackgroundColor: UIColor(hex: "#FFF1CC")
        )

        let activeDaysCard = makeStatCard(
            valueLabel: activeDaysValueLabel,
            initialValue: "0",
            title: "Active Days",
            icon: "📅",
            iconBackgroundColor: UIColor(hex: "#EDE3FF")
        )

        let streakCard = makeStatCard(
            valueLabel: dayStreakValueLabel,
            initialValue: "0",
            title: "Day Streak",
            icon: "🔥",
            iconBackgroundColor: UIColor(hex: "#FFD6EA")
        )

        statsStackView.addArrangedSubview(completedCard)
        statsStackView.addArrangedSubview(activeDaysCard)
        statsStackView.addArrangedSubview(streakCard)

        mainStackView.addArrangedSubview(statsStackView)
    }

    private func setupCurrentJourneyCard() {
        currentJourneyCardView.backgroundColor = .white
        currentJourneyCardView.layer.cornerRadius = 26
        currentJourneyCardView.layer.shadowColor = UIColor.black.cgColor
        currentJourneyCardView.layer.shadowOpacity = 0.06
        currentJourneyCardView.layer.shadowRadius = 14
        currentJourneyCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        currentJourneyTitleLabel.text = "Current Journey"
        currentJourneyTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        currentJourneyTitleLabel.textColor = UIColor(hex: "#2D2430")

        currentJourneyProgramLabel.text = "No active journey yet"
        currentJourneyProgramLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        currentJourneyProgramLabel.textColor = UIColor(hex: "#4A3B4F")
        currentJourneyProgramLabel.numberOfLines = 2

        currentJourneyDayLabel.text = "Start a program when you feel ready."
        currentJourneyDayLabel.font = .systemFont(ofSize: 13, weight: .medium)
        currentJourneyDayLabel.textColor = UIColor(hex: "#9A7FA3")
        currentJourneyDayLabel.numberOfLines = 2

        currentJourneyProgressView.progress = 0.0
        currentJourneyProgressView.trackTintColor = UIColor(hex: "#F3DDEA")
        currentJourneyProgressView.progressTintColor = UIColor(hex: "#E85A9F")
        currentJourneyProgressView.layer.cornerRadius = 4
        currentJourneyProgressView.clipsToBounds = true

        continueButton.setTitle("Choose a Program", for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        continueButton.addTarget(self, action: #selector(didTapContinueJourney), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            currentJourneyTitleLabel,
            currentJourneyProgramLabel,
            currentJourneyDayLabel,
            currentJourneyProgressView,
            continueButton
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        currentJourneyCardView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: currentJourneyCardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: currentJourneyCardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: currentJourneyCardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: currentJourneyCardView.bottomAnchor, constant: -20),

            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        mainStackView.addArrangedSubview(currentJourneyCardView)
    }

    private func setupAchievementsCard() {
        achievementsCardView.backgroundColor = .white
        achievementsCardView.layer.cornerRadius = 26
        achievementsCardView.layer.shadowColor = UIColor.black.cgColor
        achievementsCardView.layer.shadowOpacity = 0.06
        achievementsCardView.layer.shadowRadius = 14
        achievementsCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        let titleLabel = UILabel()
        titleLabel.text = "Achievements"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")

        achievementsSubtitleLabel.text = "Your earned badges will bloom here."
        achievementsSubtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        achievementsSubtitleLabel.textColor = UIColor(hex: "#9A7FA3")
        achievementsSubtitleLabel.numberOfLines = 2

        achievementsScrollView.translatesAutoresizingMaskIntoConstraints = false
        achievementsScrollView.showsHorizontalScrollIndicator = false
        achievementsScrollView.alwaysBounceHorizontal = true

        achievementsStackView.translatesAutoresizingMaskIntoConstraints = false
        achievementsStackView.axis = .horizontal
        achievementsStackView.spacing = 14
        achievementsStackView.alignment = .center

        achievementsScrollView.addSubview(achievementsStackView)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, achievementsSubtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [textStack, achievementsScrollView])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 14

        achievementsCardView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: achievementsCardView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: achievementsCardView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: achievementsCardView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: achievementsCardView.bottomAnchor, constant: -20),

            achievementsScrollView.heightAnchor.constraint(equalToConstant: 68),

            achievementsStackView.topAnchor.constraint(equalTo: achievementsScrollView.contentLayoutGuide.topAnchor),
            achievementsStackView.leadingAnchor.constraint(equalTo: achievementsScrollView.contentLayoutGuide.leadingAnchor),
            achievementsStackView.trailingAnchor.constraint(equalTo: achievementsScrollView.contentLayoutGuide.trailingAnchor),
            achievementsStackView.bottomAnchor.constraint(equalTo: achievementsScrollView.contentLayoutGuide.bottomAnchor),
            achievementsStackView.heightAnchor.constraint(equalTo: achievementsScrollView.frameLayoutGuide.heightAnchor)
        ])

        mainStackView.addArrangedSubview(achievementsCardView)
    }

    private func setupElementCard() {
        elementCardView.backgroundColor = UIColor(hex: "#F4ECF7")
        elementCardView.layer.cornerRadius = 26
        elementCardView.layer.shadowColor = UIColor.black.cgColor
        elementCardView.layer.shadowOpacity = 0.06
        elementCardView.layer.shadowRadius = 14
        elementCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        elementTitleLabel.text = "Your Element"
        elementTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        elementTitleLabel.textColor = UIColor(hex: "#5B3A66")

        elementMainLabel.text = "Element journey begins ✨"
        elementMainLabel.font = .systemFont(ofSize: 20, weight: .bold)
        elementMainLabel.textColor = UIColor(hex: "#5B3A66")
        elementMainLabel.numberOfLines = 2

        elementDescriptionLabel.text = "Complete your first program and your inner pattern will gently appear here."
        elementDescriptionLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        elementDescriptionLabel.textColor = UIColor(hex: "#A47BB7")
        elementDescriptionLabel.numberOfLines = 3

        let stack = UIStackView(arrangedSubviews: [
            elementTitleLabel,
            elementMainLabel,
            elementDescriptionLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8

        elementCardView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: elementCardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: elementCardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: elementCardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: elementCardView.bottomAnchor, constant: -20)
        ])

        mainStackView.addArrangedSubview(elementCardView)
    }
    
    private func setupInsightCard() {
        insightCardView.backgroundColor = .white
        insightCardView.layer.cornerRadius = 26
        insightCardView.layer.shadowColor = UIColor.black.cgColor
        insightCardView.layer.shadowOpacity = 0.06
        insightCardView.layer.shadowRadius = 14
        insightCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        insightSectionTitleLabel.text = "Bugünün İçgörüsü"
        insightSectionTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        insightSectionTitleLabel.textColor = UIColor(hex: "#2D2430")
        insightSectionTitleLabel.numberOfLines = 1

        insightTitleLabel.text = "İç sesine dön"
        insightTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        insightTitleLabel.textColor = UIColor(hex: "#E85A9F")
        insightTitleLabel.numberOfLines = 2

        insightSubtitleLabel.text = "Küçük adım da yeterli."
        insightSubtitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        insightSubtitleLabel.textColor = UIColor(hex: "#9A7FA3")
        insightSubtitleLabel.numberOfLines = 2

        insightBodyLabel.text = "Bugün kendine yüklenmeden ilerlemen yeterli. Bir görevi bilinçle tamamlamak bile yolculuğunu canlı tutar."
        insightBodyLabel.font = .systemFont(ofSize: 14, weight: .medium)
        insightBodyLabel.textColor = UIColor(hex: "#7B6A80")
        insightBodyLabel.numberOfLines = 0
        insightBodyLabel.setLineSpacing(4)

        let stack = UIStackView(arrangedSubviews: [
            insightSectionTitleLabel,
            insightTitleLabel,
            insightSubtitleLabel,
            insightBodyLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8

        insightCardView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: insightCardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: insightCardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: insightCardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: insightCardView.bottomAnchor, constant: -20)
        ])

        mainStackView.addArrangedSubview(insightCardView)
    }
    
    

    private func setupSettingsCard() {
        settingsCardView.backgroundColor = .white
        settingsCardView.layer.cornerRadius = 26
        settingsCardView.layer.shadowColor = UIColor.black.cgColor
        settingsCardView.layer.shadowOpacity = 0.06
        settingsCardView.layer.shadowRadius = 14
        settingsCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        let titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#2D2430")

        let editProfile = makeSettingsRow(icon: "person.crop.circle", title: "Edit Profile")
        let notifications = makeSettingsRow(icon: "bell", title: "Notifications")
        let language = makeSettingsRow(icon: "globe", title: "Language")
        let logout = makeSettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", isDestructive: true)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            editProfile,
            notifications,
            language,
            logout
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14

        settingsCardView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: settingsCardView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: settingsCardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: settingsCardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: settingsCardView.bottomAnchor, constant: -20)
        ])

        mainStackView.addArrangedSubview(settingsCardView)
    }

    // MARK: - Firestore Profile Data

    private func loadProfileInfo() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 Profile: userId yok")
            return
        }

        db.collection("profiles").document(userId).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("🔴 Profile bilgisi alınamadı:", error.localizedDescription)
                    self.loadLocalProfileFallback(uid: userId)
                    return
                }

                guard let data = snapshot?.data() else {
                    print("🟡 Profile dokümanı bulunamadı")
                    self.loadLocalProfileFallback(uid: userId)
                    return
                }

                let name = data["name"] as? String
                let username = data["username"] as? String
                let motivation = data["motivation"] as? String
                let profileImageURL = data["profileImageURL"] as? String

                self.nameLabel.text = self.makeDisplayName(from: name, username: username)
                self.usernameLabel.text = self.makeUsernameText(from: username)
                self.motivationLabel.text = self.makeMotivationText(from: motivation)

                if let profileImageURL = profileImageURL,
                   !profileImageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.loadRemoteAvatar(from: profileImageURL)
                } else {
                    self.loadLocalAvatarFallback(uid: userId)
                }

                print("🟢 Profile bilgileri yüklendi")
            }
        }
    }

    private func loadLocalProfileFallback(uid: String) {
        guard let profile = ProfileStore.shared.fetchProfile(uid: uid) else {
            applyDefaultAvatar()
            return
        }

        nameLabel.text = makeDisplayName(from: profile.name, username: profile.username)
        usernameLabel.text = makeUsernameText(from: profile.username)
        motivationLabel.text = makeMotivationText(from: profile.motivation)

        if let data = profile.avatarImageData,
           let image = UIImage(data: data) {
            applyAvatar(image)
        } else {
            applyDefaultAvatar()
        }
    }

    private func loadLocalAvatarFallback(uid: String) {
        guard let profile = ProfileStore.shared.fetchProfile(uid: uid),
              let data = profile.avatarImageData,
              let image = UIImage(data: data) else {
            applyDefaultAvatar()
            return
        }

        applyAvatar(image)
    }

    private func loadRemoteAvatar(from urlString: String) {
        guard let url = URL(string: urlString) else {
            applyDefaultAvatar()
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("🔴 Avatar indirilemedi:", error.localizedDescription)
                    self.applyDefaultAvatar()
                    return
                }

                guard let data = data,
                      let image = UIImage(data: data) else {
                    self.applyDefaultAvatar()
                    return
                }

                self.applyAvatar(image)
            }
        }.resume()
    }

    private func applyAvatar(_ image: UIImage) {
        avatarImageView.image = image
        avatarImageView.isHidden = false
        avatarPlaceholderLabel.isHidden = true
    }

    private func applyDefaultAvatar() {
        if let defaultAvatar = UIImage(named: "defaultAvatar") {
            avatarImageView.image = defaultAvatar
            avatarImageView.isHidden = false
            avatarPlaceholderLabel.isHidden = true
        } else {
            avatarImageView.isHidden = true
            avatarPlaceholderLabel.isHidden = false
        }
    }

    private func makeDisplayName(from name: String?, username: String?) -> String {
        if let name = name,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }

        if let username = username,
           !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return username
        }

        return "Lunora Soul"
    }

    private func makeUsernameText(from username: String?) -> String {
        guard let username = username,
              !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "@lunora"
        }

        if username.hasPrefix("@") {
            return username
        }

        return "@\(username)"
    }

    private func makeMotivationText(from motivation: String?) -> String {
        guard let motivation = motivation,
              !motivation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "You're doing beautifully, keep shining ✨"
        }

        return motivation
    }
    
    // MARK: - Daily Insight

    private func loadDailyInsight() {
        guard !isLoadingDailyInsight else {
            print("🟡 DailyInsight zaten yükleniyor, tekrar çağrı engellendi")
            return
        }

        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 DailyInsight: userId yok")
            applyDailyInsightFallback()
            return
        }

        isLoadingDailyInsight = true
        applyDailyInsightLoadingState()

        DailyInsightService.shared.fetchTodayInsight(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isLoadingDailyInsight = false

                switch result {
                case .success(let insight):
                    self.configureDailyInsight(with: insight)

                case .failure(let error):
                    print("🔴 DailyInsight alınamadı:", error.localizedDescription)
                    self.applyDailyInsightFallback()
                }
            }
        }
    }

    private func applyDailyInsightLoadingState() {
        insightTitleLabel.text = "İçgörün hazırlanıyor"
        insightSubtitleLabel.text = "Bugünün enerjisi okunuyor."
        insightBodyLabel.text = "Kısa bir anda, yolculuğuna eşlik edecek mesaj hazırlanıyor."
    }

    private func configureDailyInsight(with insight: DailyInsight) {
        insightTitleLabel.text = insight.title
        insightSubtitleLabel.text = insight.subtitle
        insightBodyLabel.text = insight.body
        insightBodyLabel.setLineSpacing(4)
    }

    private func applyDailyInsightFallback() {
        let dateKey = makeTodayDateKeyForProfile()
        let fallback = DailyInsight.fallback(dateKey: dateKey)
        configureDailyInsight(with: fallback)
    }

    private func makeTodayDateKeyForProfile() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }

    // MARK: - Real Dashboard Data

    private func applyLoadingState() {
        completedProgramsValueLabel.text = "0"
        activeDaysValueLabel.text = "0"
        dayStreakValueLabel.text = "0"

        configureNoActiveJourney()
        configureAchievements(with: [])
        configureElementEmptyState()
    }

    private func loadProfileDashboardData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 Profile dashboard: userId yok")
            applyEmptyProfileDashboard()
            return
        }

        let programs = ProgramLoader.loadPrograms()

        enrollmentRepository.fetchCompletedEnrollments(userId: userId) { [weak self] completedResult in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch completedResult {
                case .success(let completedEnrollments):
                    let completedProgramCount = completedEnrollments.count
                    let completedDaysFromFinishedPrograms = completedEnrollments.reduce(0) {
                        $0 + $1.completedDaysCount
                    }

                    let badgeImageNames: [String] = completedEnrollments.compactMap { enrollment in
                        guard let program = programs.first(where: { $0.id == enrollment.programId }) else {
                            return nil
                        }

                        return program.badgeImageName ?? program.imageName
                    }

                    let completedItems: [CompletedProgramDisplayItem] = completedEnrollments.compactMap { enrollment in
                        guard let program = programs.first(where: { $0.id == enrollment.programId }) else {
                            return nil
                        }

                        return CompletedProgramDisplayItem(
                            enrollmentId: enrollment.enrollmentId,
                            programName: program.name,
                            imageName: program.badgeImageName ?? program.imageName,
                            durationText: program.durationText,
                            completedDateText: "",
                            completionNote: enrollment.completionNote,
                            completedDaysCount: enrollment.completedDaysCount,
                            elements: program.elements
                        )
                    }

                    self.completedProgramsValueLabel.text = "\(completedProgramCount)"
                    self.configureAchievements(with: badgeImageNames)
                    self.configureElementCard(from: completedItems)

                    self.loadActiveJourneyData(
                        userId: userId,
                        programs: programs,
                        completedDaysFromFinishedPrograms: completedDaysFromFinishedPrograms
                    )

                    self.loadStreakData(userId: userId, programs: programs)

                case .failure(let error):
                    print("🔴 Profile completed enrollments alınamadı:", error.localizedDescription)
                    self.applyEmptyProfileDashboard()
                }
            }
        }
    }

    private func loadActiveJourneyData(
        userId: String,
        programs: [Program],
        completedDaysFromFinishedPrograms: Int
    ) {
        enrollmentRepository.fetchActiveEnrollment(userId: userId) { [weak self] activeResult in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch activeResult {
                case .success(let activeEnrollment):
                    if let activeEnrollment = activeEnrollment,
                       let activeProgram = programs.first(where: { $0.id == activeEnrollment.programId }) {

                        self.hasActiveJourney = true
                        self.configureCurrentJourney(
                            program: activeProgram,
                            enrollment: activeEnrollment
                        )

                        let activeTotalDays = completedDaysFromFinishedPrograms + activeEnrollment.completedDaysCount
                        self.activeDaysValueLabel.text = "\(activeTotalDays)"

                    } else {
                        self.hasActiveJourney = false
                        self.configureNoActiveJourney()
                        self.activeDaysValueLabel.text = "\(completedDaysFromFinishedPrograms)"
                    }

                case .failure(let error):
                    print("🔴 Profile active enrollment alınamadı:", error.localizedDescription)
                    self.hasActiveJourney = false
                    self.configureNoActiveJourney()
                    self.activeDaysValueLabel.text = "\(completedDaysFromFinishedPrograms)"
                }
            }
        }
    }

    private func loadStreakData(userId: String, programs: [Program]) {
        db.collection("users").document(userId).getDocument { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let data = snapshot?.data(),
                   let currentStreak = data["currentStreak"] as? Int {
                    self.dayStreakValueLabel.text = "\(currentStreak)"
                    return
                }

                self.enrollmentRepository.fetchLongestFullTaskStreak(
                    userId: userId,
                    programs: programs
                ) { [weak self] streakResult in
                    DispatchQueue.main.async {
                        guard let self = self else { return }

                        switch streakResult {
                        case .success(let streak):
                            self.dayStreakValueLabel.text = "\(streak)"

                        case .failure(let error):
                            print("🔴 Profile streak alınamadı:", error.localizedDescription)
                            self.dayStreakValueLabel.text = "0"
                        }
                    }
                }
            }
        }
    }

    private func applyEmptyProfileDashboard() {
        completedProgramsValueLabel.text = "0"
        activeDaysValueLabel.text = "0"
        dayStreakValueLabel.text = "0"

        hasActiveJourney = false
        configureNoActiveJourney()
        configureAchievements(with: [])
        configureElementEmptyState()
    }

    private func configureCurrentJourney(
        program: Program,
        enrollment: ActiveEnrollment
    ) {
        currentJourneyProgramLabel.text = program.name

        let displayDay = min(enrollment.currentDay, program.durationDays)
        currentJourneyDayLabel.text = "Day \(displayDay) of \(program.durationDays)"

        let totalDays = max(1, program.durationDays)
        let completedDays = max(0, enrollment.completedDaysCount)
        let progress = Float(completedDays) / Float(totalDays)

        currentJourneyProgressView.setProgress(min(max(progress, 0), 1), animated: true)

        continueButton.setTitle("Continue Today’s Practice", for: .normal)
        continueButton.isEnabled = true
        continueButton.alpha = 1.0
    }

    private func configureNoActiveJourney() {
        currentJourneyProgramLabel.text = "No active journey yet"
        currentJourneyDayLabel.text = "Start a program when you feel ready."
        currentJourneyProgressView.setProgress(0.0, animated: true)

        continueButton.setTitle("Choose a Program", for: .normal)
        continueButton.isEnabled = true
        continueButton.alpha = 1.0
    }

    private func configureAchievements(with badgeImageNames: [String]) {
        achievementsStackView.arrangedSubviews.forEach { view in
            achievementsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if badgeImageNames.isEmpty {
            achievementsSubtitleLabel.text = "Your earned badges will bloom here."
            achievementsStackView.addArrangedSubview(makeEmptyBadgeIcon())
            return
        }

        achievementsSubtitleLabel.text = "Your completed journeys are blooming here."

        for imageName in badgeImageNames {
            achievementsStackView.addArrangedSubview(makeBadgeIcon(imageName: imageName))
        }
    }

    private func configureElementCard(from items: [CompletedProgramDisplayItem]) {
        guard !items.isEmpty else {
            configureElementEmptyState()
            return
        }

        let viewModel = makeElementBalanceCardViewModel(from: items)

        elementCardView.backgroundColor = viewModel.backgroundColor

        elementTitleLabel.text = viewModel.title
        elementTitleLabel.textColor = viewModel.titleColor

        elementMainLabel.text = viewModel.mainText
        elementMainLabel.textColor = viewModel.titleColor

        elementDescriptionLabel.text = viewModel.subtitle
        elementDescriptionLabel.textColor = viewModel.subtitleColor
    }

    private func configureElementEmptyState() {
        elementCardView.backgroundColor = UIColor(hex: "#F4ECF7")

        elementTitleLabel.text = "Your Element"
        elementTitleLabel.textColor = UIColor(hex: "#5B3A66")

        elementMainLabel.text = "Element journey begins ✨"
        elementMainLabel.textColor = UIColor(hex: "#5B3A66")

        elementDescriptionLabel.text = "Complete your first program and your inner pattern will gently appear here."
        elementDescriptionLabel.textColor = UIColor(hex: "#A47BB7")
    }

    private func makeElementBalanceCardViewModel(
        from items: [CompletedProgramDisplayItem]
    ) -> ElementBalanceCardViewModel {

        guard !items.isEmpty else {
            return ElementBalanceCardFactory.makeEmptyCard()
        }

        var elementCounts: [LunoraElement: Int] = [:]

        for item in items {
            let parsedElements = LunoraElementParser.parseElements(from: item.elements)

            for element in parsedElements {
                elementCounts[element, default: 0] += 1
            }
        }

        guard let maxCount = elementCounts.values.max(), maxCount > 0 else {
            return ElementBalanceCardFactory.makeEmptyCard()
        }

        let candidateElements = elementCounts
            .filter { $0.value == maxCount }
            .map { $0.key }

        var selectedElement = candidateElements.first ?? .air

        for item in items {
            let parsedElements = LunoraElementParser.parseElements(from: item.elements)

            if let matchedElement = parsedElements.first(where: { candidateElements.contains($0) }) {
                selectedElement = matchedElement
                break
            }
        }

        return ElementBalanceCardFactory.makeCard(
            element: selectedElement,
            count: maxCount
        )
    }

    // MARK: - Actions

    @objc private func didTapContinueJourney() {
        if hasActiveJourney {
            tabBarController?.selectedIndex = 1
        } else {
            tabBarController?.selectedIndex = 0
        }
    }

    // MARK: - Reusable Views

    private func makeStatCard(
        valueLabel: UILabel,
        initialValue: String,
        title: String,
        icon: String,
        iconBackgroundColor: UIColor
    ) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 22
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 7)

        let iconCircleView = UIView()
        iconCircleView.translatesAutoresizingMaskIntoConstraints = false
        iconCircleView.backgroundColor = iconBackgroundColor
        iconCircleView.layer.cornerRadius = 23
        iconCircleView.clipsToBounds = true

        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        iconLabel.textAlignment = .center

        iconCircleView.addSubview(iconLabel)

        NSLayoutConstraint.activate([
            iconCircleView.widthAnchor.constraint(equalToConstant: 46),
            iconCircleView.heightAnchor.constraint(equalToConstant: 46),

            iconLabel.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor)
        ])

        valueLabel.text = initialValue
        valueLabel.font = .systemFont(ofSize: 25, weight: .bold)
        valueLabel.textColor = UIColor(hex: "#2D2430")
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#9A7FA3")
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [
            iconCircleView,
            valueLabel,
            titleLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 7
        stack.alignment = .center

        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 126),

            stack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: cardView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -8),
            stack.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])

        return cardView
    }

    private func makeBadgeIcon(imageName: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.clipsToBounds = false

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 60),
            container.heightAnchor.constraint(equalToConstant: 60)
        ])

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = .clear

        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func makeEmptyBadgeIcon() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(hex: "#F7E7F1")
        container.layer.cornerRadius = 30
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(hex: "#EAB8D4").cgColor

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 60),
            container.heightAnchor.constraint(equalToConstant: 60)
        ])

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "+"
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = UIColor(hex: "#D65C9E")
        label.textAlignment = .center

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func makeSettingsRow(
        icon: String,
        title: String,
        isDestructive: Bool = false
    ) -> UIView {

        let rowView = UIView()
        rowView.backgroundColor = UIColor(hex: "#FFF7FC")
        rowView.layer.cornerRadius = 18

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = isDestructive ? UIColor(hex: "#D94D6A") : UIColor(hex: "#E85A9F")
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = isDestructive ? UIColor(hex: "#D94D6A") : UIColor(hex: "#3A2A3F")

        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = UIColor(hex: "#C9AFCF")
        chevronImageView.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [
            iconImageView,
            titleLabel,
            UIView(),
            chevronImageView
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12

        rowView.addSubview(stack)

        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(equalToConstant: 52),

            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),

            stack.topAnchor.constraint(equalTo: rowView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
        ])

        return rowView
    }
}
private extension UILabel {
    func setLineSpacing(_ spacing: CGFloat) {
        guard let text = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        self.attributedText = attributedString
    }
}
