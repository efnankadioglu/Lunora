//
//  ProgressViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProgressViewController: UIViewController {

    @IBOutlet weak var scrollContentView: UIScrollView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var bottomSummaryView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var headerStatusLabel: UILabel!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var headerContainerView: UIView!
    
    private let contentStackView = UIStackView()
    private let tasksCardView = TasksCardView()
    private let bottomSummaryCardView = BottomSummaryCardView()
    private let programPlaceholderView = UIView()
    private let programProgressCardView = ProgramProgressCardView()
    private let programBadgeCardView = ProgramBadgeCardView()
    private var selectedProgram: Program?
    private var programInfoStates: [Bool] = [false, false, false, false, false]
    private let programInfoIcons: [String] = ["🪞", "⚜️", "🦋", "☀", "💫"]
    private var currentStreak: Int = 0

    private var tasks: [DailyTask] = []
    private var taskStates: [DailyTaskUIState] = []
    private let enrollmentRepository = EnrollmentRepository()
    private let db = Firestore.firestore()
    private var activeEnrollment: ActiveEnrollment?
    private var todayLog: DailyLog?
    private var allDailyLogs: [DailyLog] = []
    
    private weak var activeCoachMark: LunoraCoachMarkView?
    private weak var guidedEmptyStateView: UIView?
    
    private var isFinalizingEnrollment = false
    private var handledCompletedEnrollmentId: String?
    
    private lazy var completionLoadingOverlay: UIView = {

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        view.alpha = 0
        return view
    }()

    private lazy var completionLoadingCard: UIView = {

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = UIColor(
            red: 1.0,
            green: 0.98,
            blue: 0.99,
            alpha: 1
        )

        view.layer.cornerRadius = 24

        view.layer.shadowColor =
            UIColor.black.cgColor

        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(
            width: 0,
            height: 8
        )

        return view
    }()

    private lazy var completionLoadingIndicator: UIActivityIndicatorView = {

        let indicator =
            UIActivityIndicatorView(style: .medium)

        indicator.translatesAutoresizingMaskIntoConstraints =
            false

        indicator.hidesWhenStopped = true

        return indicator
    }()

    private lazy var completionLoadingLabel: UILabel = {

        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints =
            false

        label.text = "Programın tamamlanıyor ✨"

        label.font =
            .systemFont(
                ofSize: 17,
                weight: .semibold
            )

        label.textColor = UIColor(
            red: 35/255,
            green: 45/255,
            blue: 63/255,
            alpha: 1
        )

        label.textAlignment = .center

        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        setupContentStack()
        bindTaskActions()
        setupBottomSummaryCard()
        setupSegmentControl()
        showTodayContent()
        loadProfileImage()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileDidUpdate),
            name: .lunoraProfileDidUpdate,
            object: nil
        )

        // Geçici olarak cache'i temizliyoruz.
        // Çünkü artık Progress ekranı kararını Firestore lifecycle kontrolünden almalı.
        ProgressCacheManager.shared.clear()
        // loadProgressFromCache()

        fetchActiveEnrollmentAndLog()
        updateHeaderUI()
        
        endJourneyButton.addTarget(self, action: #selector(didTapEndJourney), for: .touchUpInside)
        
        NetworkMonitor.shared.onConnectionRestored = { [weak self] in
            self?.syncPendingProgressActions()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadProfileImage()
        syncPendingProgressActions()

        let shouldOpenTodayTab = UserDefaults.standard.bool(forKey: "shouldOpenProgressTodayTab")
        if shouldOpenTodayTab {
            segmentControl.selectedSegmentIndex = 0
            showTodayContent()
            UserDefaults.standard.set(false, forKey: "shouldOpenProgressTodayTab")
        }

        fetchActiveEnrollmentAndLog()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
        userProfileImageView.clipsToBounds = true
    }

    private func setupScreen() {

        view.backgroundColor = UIColor(
            red: 246/255,
            green: 238/255,
            blue: 244/255,
            alpha: 1
        )

        scrollContentView.alwaysBounceVertical = true
        scrollContentView.showsVerticalScrollIndicator = false
        scrollContentView.contentInsetAdjustmentBehavior = .never

        // Program adı uzun olduğunda ... ile kesilmesin.
        if let programNameLabel = findProgramNameLabel() {
            programNameLabel.numberOfLines = 1
            programNameLabel.adjustsFontSizeToFitWidth = true
            programNameLabel.minimumScaleFactor = 0.68
            programNameLabel.lineBreakMode = .byClipping
        }
    }

        private func setupContentStack() {
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.axis = .vertical
            contentStackView.alignment = .fill
            contentStackView.distribution = .fill
            contentStackView.spacing = 16

            contentContainerView.addSubview(contentStackView)

            NSLayoutConstraint.activate([
                contentStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 16),
                contentStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 20),
                contentStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -20),
                contentStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -16)
            ])
        }

    private func loadTasks(for program: Program, dayNumber: Int? = nil) {
        selectedProgram = program

        let targetDay = dayNumber ?? activeEnrollment?.currentDay ?? todayLog?.dayNumber ?? 1

        if let programDay = program.days?.first(where: { $0.dayNumber == targetDay }) {
            tasks = programDay.tasks
            print("🟢 Gün \(targetDay) görevleri days içinden yüklendi:", tasks.count)
        } else {
            tasks = program.dailyTasks
            print("🟡 Eski dailyTasks formatı yüklendi:", tasks.count)
        }

        taskStates = tasks.map {
            DailyTaskUIState(
                taskId: $0.id,
                isCompleted: false,
                isExpanded: false
            )
        }

        tasksCardView.configure(tasks: tasks, states: taskStates)
        updateBottomSummaryUI()
    }

        private func bindTaskActions() {
            tasksCardView.onToggleTaskCompletion = { [weak self] taskId in
                self?.toggleCompletion(for: taskId)
            }

            tasksCardView.onToggleTaskExpansion = { [weak self] taskId in
                self?.toggleExpansion(for: taskId)
             }
        }
    
    private func setHeaderVisibility(isVisible: Bool) {
        headerContainerView.isHidden = !isVisible
    }
    
    private func updateHeaderUI() {
        guard let selectedProgram = selectedProgram,
              let todayLog = todayLog else {
            setHeaderVisibility(isVisible: false)
            headerStatusLabel.text = "Gün - / - · 0 gün streak 🔥"
            findProgramNameLabel()?.text = ""
            return
        }

        setHeaderVisibility(isVisible: true)

        findProgramNameLabel()?.text = selectedProgram.name

        let displayDay = min(todayLog.dayNumber, selectedProgram.durationDays)
        let currentDayText = "Gün \(displayDay) / \(selectedProgram.durationDays)"
        let streakText = "\(currentStreak) gün streak 🔥"

        headerStatusLabel.text = "\(currentDayText) · \(streakText)"

        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
    }
    
    private func loadProfileImage() {

        guard let uid = Auth.auth().currentUser?.uid else {

            applyAvatarUI(
                image: UIImage(named: "defaultAvatar")
            )

            return
        }

        // MARK: - 1. Önce cihazdaki local profil fotoğrafını kullan

        if let profile = ProfileStore.shared.fetchProfile(uid: uid),
           let imageData = profile.avatarImageData,
           let image = UIImage(data: imageData) {

            print("✅ Progress: profil fotoğrafı localden yüklendi")

            applyAvatarUI(
                image: image
            )

            return
        }


        // MARK: - 2. Local fotoğraf yoksa mevcut online sistem

        db.collection("profiles")
            .document(uid)
            .getDocument { [weak self] snapshot, error in

                guard let self = self else {
                    return
                }

                guard
                    error == nil,
                    let data = snapshot?.data(),
                    let urlString =
                        data["profileImageURL"] as? String,
                    let url = URL(string: urlString)
                else {

                    DispatchQueue.main.async {

                        self.applyAvatarUI(
                            image: UIImage(
                                named: "defaultAvatar"
                            )
                        )
                    }

                    return
                }


                URLSession.shared.dataTask(
                    with: url
                ) { [weak self] data, _, _ in

                    guard let self = self else {
                        return
                    }

                    let image: UIImage?

                    if let data = data {
                        image = UIImage(data: data)
                    } else {
                        image = UIImage(
                            named: "defaultAvatar"
                        )
                    }

                    DispatchQueue.main.async {

                        self.applyAvatarUI(
                            image:
                                image
                                ?? UIImage(
                                    named: "defaultAvatar"
                                )
                        )
                    }

                }.resume()
            }
    }

    @objc private func handleProfileDidUpdate() {
        loadProfileImage()
    }
        
    
   
    
    private func applyAvatarUI(image: UIImage?) {
        userProfileImageView.image = image
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
    }
    
    private func updateBottomSummaryUI() {
        let requiredTaskIds = Set(tasks.filter { $0.isRequired != false }.map { $0.id })

        let completedRequiredCount = taskStates.filter {
            $0.isCompleted && requiredTaskIds.contains($0.taskId)
        }.count

        let totalRequiredCount = requiredTaskIds.count
        let remainingTimeText = calculateRemainingTimeText()

        bottomSummaryCardView.configure(
            mantra: "Her küçük adım, büyük değişimin parçası.",
            streakText: "\(currentStreak)",
            completedText: "\(completedRequiredCount)/\(totalRequiredCount)",
            remainingText: remainingTimeText
        )
    }
    
    private func calculateOverallProgramProgress(
        for program: Program
    ) -> (completed: Int, total: Int) {

        // Yeni program formatı: görevler gün gün tutuluyor
        if let programDays = program.days, !programDays.isEmpty {

            let totalRequiredTaskCount = programDays.reduce(0) { total, day in
                let requiredTasks = day.tasks.filter {
                    $0.isRequired != false
                }

                return total + requiredTasks.count
            }

            var completedRequiredTaskCount = 0

            for log in allDailyLogs {

                guard let programDay = programDays.first(where: {
                    $0.dayNumber == log.dayNumber
                }) else {
                    continue
                }

                let requiredTaskIds = Set(
                    programDay.tasks
                        .filter { $0.isRequired != false }
                        .map { $0.id }
                )

                let completedForThisDay = log.completedTaskIds.filter {
                    requiredTaskIds.contains($0)
                }.count

                completedRequiredTaskCount += completedForThisDay
            }

            return (
                completed: completedRequiredTaskCount,
                total: totalRequiredTaskCount
            )
        }

        // Eski program formatı için fallback
        let requiredDailyTasks = program.dailyTasks.filter {
            $0.isRequired != false
        }

        let requiredDailyTaskIds = Set(
            requiredDailyTasks.map { $0.id }
        )

        let totalRequiredTaskCount =
            requiredDailyTasks.count * max(1, program.durationDays)

        let completedRequiredTaskCount = allDailyLogs.reduce(0) {
            partialResult,
            log in

            let completedForThisDay = log.completedTaskIds.filter {
                requiredDailyTaskIds.contains($0)
            }.count

            return partialResult + completedForThisDay
        }

        return (
            completed: completedRequiredTaskCount,
            total: totalRequiredTaskCount
        )
    }

    private func buildProgramProgressCardData() -> ProgramProgressCardData? {
        guard let selectedProgram = selectedProgram else {
            return nil
        }

        let totalDays = max(1, selectedProgram.durationDays)

        let currentDay: Int
        if let todayLog = todayLog {
            currentDay = min(todayLog.dayNumber, totalDays)
        } else {
            currentDay = 1
        }

        let progressCounts = calculateOverallProgramProgress(
            for: selectedProgram
        )

        let totalTaskCount = progressCounts.total
        let completedTaskCount = progressCounts.completed

        let progressRatio: Double

        if totalTaskCount > 0 {
            progressRatio =
                Double(completedTaskCount) /
                Double(totalTaskCount)
        } else {
            progressRatio = 0
        }

        let progressPercent = Int(
            (progressRatio * 100.0).rounded()
        )

        let safeProgressPercent = min(
            max(progressPercent, 0),
            100
        )

        let legendItems: [ProgramProgressCardLegendItem] = [
            ProgramProgressCardLegendItem(
                color: UIColor(
                    red: 222/255,
                    green: 120/255,
                    blue: 174/255,
                    alpha: 1
                ),
                title: "Genel İlerleme",
                valueText: "\(safeProgressPercent)%",
                chartValue: CGFloat(progressRatio)
            )
        ]

        print(
            "🌸 Genel ilerleme:",
            "\(completedTaskCount)/\(totalTaskCount)",
            "=%\(safeProgressPercent)"
        )

        return ProgramProgressCardData(
            currentDay: currentDay,
            totalDays: totalDays,
            progressPercent: safeProgressPercent,
            donutCenterPercent: safeProgressPercent,
            legendItems: legendItems
        )
    }

    private func updateProgramProgressCardUI() {
        guard let data = buildProgramProgressCardData() else { return }
        programProgressCardView.configure(with: data)
    }
    
    private func applyLocalTaskToggle(
        taskId: String,
        completedTaskIds: [String],
        isCompleted: Bool
    ) {
        guard let todayLog = todayLog else { return }

        let updatedTodayLog = DailyLog(
            logId: todayLog.logId,
            enrollmentId: todayLog.enrollmentId,
            userId: todayLog.userId,
            programId: todayLog.programId,
            dateKey: todayLog.dateKey,
            dayNumber: todayLog.dayNumber,
            completedTaskIds: completedTaskIds,
            isCompleted: isCompleted,
            completedAt: todayLog.completedAt,
            createdAt: todayLog.createdAt,
            updatedAt: todayLog.updatedAt
        )

        self.todayLog = updatedTodayLog

        self.taskStates = self.taskStates.map { state in
            var newState = state
            newState.isCompleted = completedTaskIds.contains(state.taskId)
            return newState
        }

        if let existingIndex = self.allDailyLogs.firstIndex(where: { $0.dateKey == updatedTodayLog.dateKey }) {
            self.allDailyLogs[existingIndex] = updatedTodayLog
        } else {
            self.allDailyLogs.append(updatedTodayLog)
        }

        self.tasksCardView.update(states: self.taskStates)
        self.updateHeaderUI()
        self.updateBottomSummaryUI()
        self.updateProgramProgressCardUI()
        self.updateProgramBadgeCardUI()
        self.saveProgressToCache()
    }
    
    private func toggleCompletion(for taskId: String) {
        
        guard !isFinalizingEnrollment else {
            print("🟡 Program finalization devam ediyor.")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
                   print("🔴 toggleCompletion: userId yok")
                   return
               }

               guard let activeEnrollment = activeEnrollment else {
                   print("🔴 toggleCompletion: activeEnrollment yok")
                   return
               }

        guard let todayLog = todayLog else {
            print("🔴 toggleCompletion: todayLog yok")
            return
        }

        var updatedTaskIds = todayLog.completedTaskIds

        if updatedTaskIds.contains(taskId) {
            updatedTaskIds.removeAll { $0 == taskId }
        } else {
            updatedTaskIds.append(taskId)
        }
        
        let requiredTasks = tasks.filter { $0.isRequired != false }
        let requiredTaskIds = Set(requiredTasks.map { $0.id })

        let completedRequiredCount = updatedTaskIds.filter { requiredTaskIds.contains($0) }.count
        let totalRequiredTaskCount = requiredTasks.count

        let isTryingToCompleteTask = !todayLog.completedTaskIds.contains(taskId)
        let isLastTask = completedRequiredCount == totalRequiredTaskCount
        let programDuration = selectedProgram?.durationDays ?? 0
        let isLastDay = todayLog.dayNumber >= programDuration
//        let shouldFinalizeAfterSave =
//            isTryingToCompleteTask &&
//            isLastTask &&
//            isLastDay

//        let shouldSkipPopup = UserDefaults.standard.bool(forKey: "skipCompletionPopupOnce")
//
//        if shouldSkipPopup {
//            UserDefaults.standard.set(false, forKey: "skipCompletionPopupOnce")
//        }
//
//        if !shouldSkipPopup && isTryingToCompleteTask && isLastTask && isLastDay {
//            showCompletionPopup(for: taskId)
//            return
//        }
        
        if isTryingToCompleteTask &&
            isLastTask &&
            isLastDay {

            showCompletionPopup(for: taskId)
            return
        }

        let completionRate = totalRequiredTaskCount > 0
            ? Double(completedRequiredCount) / Double(totalRequiredTaskCount)
            : 0

        let isCompleted = completionRate >= 0.5
        
        if !NetworkMonitor.shared.isConnected {
            print("🟡 Offline mod: değişiklik pending queue'ya yazılacak")

            applyLocalTaskToggle(
                taskId: taskId,
                completedTaskIds: updatedTaskIds,
                isCompleted: isCompleted
            )

            let pendingAction = PendingProgressAction(
                id: UUID(),
                userId: userId,
                enrollmentId: activeEnrollment.enrollmentId,
                dateKey: todayLog.dateKey,
                completedTaskIds: updatedTaskIds,
                isCompleted: isCompleted,
                createdAt: Date()
            )

            PendingProgressManager.shared.add(pendingAction)
            return
        }

        enrollmentRepository.updateCompletedTaskIds(
            userId: userId,
            enrollmentId: activeEnrollment.enrollmentId,
            dateKey: todayLog.dateKey,
            completedTaskIds: updatedTaskIds,
            isCompleted: isCompleted
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let updatedLog):
                    self.todayLog = updatedLog

                    self.taskStates = self.taskStates.map { state in
                        var newState = state
                        newState.isCompleted = updatedLog.completedTaskIds.contains(state.taskId)
                        return newState
                    }

                    self.tasksCardView.update(states: self.taskStates)

                    self.updateBottomSummaryUI()
                    
                    self.enrollmentRepository.refreshUserStreak(
                        userId: userId,
                        todayLog: updatedLog
                    ) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let streakData):
                                self.currentStreak = streakData.currentStreak

                                self.enrollmentRepository.fetchAllDailyLogs(
                                    userId: userId,
                                    enrollmentId: activeEnrollment.enrollmentId
                                ) { logsResult in
                                    DispatchQueue.main.async {
                                        switch logsResult {
                                        case .success(let logs):
                                            self.allDailyLogs = logs

                                        case .failure(let error):
                                            print("🔴 Tüm daily loglar alınamadı:", error.localizedDescription)
                                            self.allDailyLogs = []
                                        }

                                        self.updateHeaderUI()
                                        self.updateBottomSummaryUI()
                                        self.updateProgramProgressCardUI()
                                        self.updateProgramBadgeCardUI()
                                        self.saveProgressToCache()
                                        print("✅ User streak güncellendi:", streakData.currentStreak)
                                    }
                                }
                            case .failure(let error):
                                print("🔴 User streak güncellenemedi:", error.localizedDescription)
                            }
                        }
                    }

                    print("✅ toggleCompletion güncellendi")
                    print("✅ completedTaskIds:", updatedLog.completedTaskIds)
                    print("✅ isCompleted:", updatedLog.isCompleted)
                    
//                    if shouldFinalizeAfterSave {
//
//                        self.finalizeCurrentEnrollment(
//                            userId: userId,
//                            enrollment: activeEnrollment
//                        )
//
//                        return
//                    }

                    
                    self.enrollmentRepository.refreshEnrollmentProgressSummary(
                        userId: userId,
                        enrollment: activeEnrollment
                    ) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                print("✅ Enrollment summary güncellendi")

                                self.enrollmentRepository.fetchActiveEnrollment(userId: userId) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(let refreshedEnrollment):
                                            guard let refreshedEnrollment = refreshedEnrollment else { return }

                                            self.activeEnrollment = refreshedEnrollment
                                            self.updateHeaderUI()
                                            self.updateBottomSummaryUI()
                                            self.updateProgramProgressCardUI()
                                            self.saveProgressToCache()

                                        case .failure(let error):
                                            print("🔴 Enrollment yeniden alınamadı:", error.localizedDescription)
                                        }
                                    }
                                }

                            case .failure(let error):
                                print("🔴 Enrollment summary güncellenemedi:", error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    print("🔴 toggleCompletion update hatası:", error.localizedDescription)
                }
            }
        }
    }
    
    private func finalizeCurrentEnrollment(
        userId: String,
        enrollment: ActiveEnrollment
    ) {

        guard !isFinalizingEnrollment else {
            return
        }

        isFinalizingEnrollment = true

        enrollmentRepository.finalizeEnrollment(
            userId: userId,
            enrollment: enrollment,
            trigger: .lastTask
        ) { [weak self] result in

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }

                switch result {

                case .failure(let error):

                    self.isFinalizingEnrollment = false

                    print(
                        "🔴 Program finalization hatası:",
                        error.localizedDescription
                    )

                    let alert = UIAlertController(
                        title: "Program henüz kapatılamadı",
                        message:
                            "Son görevin kaydedildi. Program sonucu şu anda kesinleştirilemedi. Lunora Progress ekranını tekrar açtığında işlemi yeniden kontrol edecek.",
                        preferredStyle: .alert
                    )

                    alert.addAction(
                        UIAlertAction(
                            title: "Tamam",
                            style: .default
                        )
                    )

                    self.present(
                        alert,
                        animated: true
                    )

                case .success(let lifecycleResult):

                    self.isFinalizingEnrollment = false

                    switch lifecycleResult {

                    case .completedWithBadge(let finalizedEnrollment):

                        self.handleProgramCompletedWithBadge(
                            userId: userId,
                            enrollment: finalizedEnrollment
                        )

                    case .completedWithoutBadge(let finalizedEnrollment):

                        self.handleProgramCompletedWithoutBadge(
                            userId: userId,
                            enrollment: finalizedEnrollment
                        )

                    case .stillActive(let enrollment):

                        // Repository son günün gerçekten tamamlanmadığını
                        // tespit ettiyse UI kendi başına programı bitirmez.
                        self.activeEnrollment = enrollment

                        print(
                            "🟡 Program henüz finalization şartlarını sağlamıyor."
                        )

                    case .noActiveEnrollment:

                        self.resetActiveProgramState()
                    }
                }
            }
        }
    }
    
    
//    private func showCompletionPopup(for taskId: String) {
//        
//        let popup = ConfirmationPopupView()
//
//        popup.titleText = "Son adımdasın ✨"
//        popup.messageText = "Bu görevi tamamladığında program bitecek. Devam etmek istiyor musun?"
//        popup.cancelTitle = "Vazgeç"
//        popup.confirmTitle = "Devam et"
//
//        popup.onConfirm = { [weak self] in
//
//            UserDefaults.standard.set(
//                true,
//                forKey: "skipCompletionPopupOnce"
//            )
//
//            self?.toggleCompletion(for: taskId)
//        }
//        popup.onCancel = {
//            // hiçbir şey yapma
//        }
//
//        popup.present(in: self.view)
//    }
    
    private func showProgramCompletionLoading() {

        guard completionLoadingOverlay.superview == nil
        else {
            return
        }

        completionLoadingOverlay.addSubview(
            completionLoadingCard
        )

        completionLoadingCard.addSubview(
            completionLoadingIndicator
        )

        completionLoadingCard.addSubview(
            completionLoadingLabel
        )

        view.addSubview(
            completionLoadingOverlay
        )

        NSLayoutConstraint.activate([

            completionLoadingOverlay.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            completionLoadingOverlay.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            completionLoadingOverlay.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            completionLoadingOverlay.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            completionLoadingCard.centerXAnchor.constraint(
                equalTo: completionLoadingOverlay.centerXAnchor
            ),

            completionLoadingCard.centerYAnchor.constraint(
                equalTo: completionLoadingOverlay.centerYAnchor
            ),

            completionLoadingCard.leadingAnchor.constraint(
                greaterThanOrEqualTo:
                    completionLoadingOverlay.leadingAnchor,
                constant: 36
            ),

            completionLoadingCard.trailingAnchor.constraint(
                lessThanOrEqualTo:
                    completionLoadingOverlay.trailingAnchor,
                constant: -36
            ),

            completionLoadingIndicator.topAnchor.constraint(
                equalTo:
                    completionLoadingCard.topAnchor,
                constant: 24
            ),

            completionLoadingIndicator.centerXAnchor.constraint(
                equalTo:
                    completionLoadingCard.centerXAnchor
            ),

            completionLoadingLabel.topAnchor.constraint(
                equalTo:
                    completionLoadingIndicator.bottomAnchor,
                constant: 14
            ),

            completionLoadingLabel.leadingAnchor.constraint(
                equalTo:
                    completionLoadingCard.leadingAnchor,
                constant: 24
            ),

            completionLoadingLabel.trailingAnchor.constraint(
                equalTo:
                    completionLoadingCard.trailingAnchor,
                constant: -24
            ),

            completionLoadingLabel.bottomAnchor.constraint(
                equalTo:
                    completionLoadingCard.bottomAnchor,
                constant: -24
            )
        ])

        completionLoadingIndicator.startAnimating()

        UIView.animate(
            withDuration: 0.18
        ) {
            self.completionLoadingOverlay.alpha = 1
        }
    }


    private func hideProgramCompletionLoading() {

        guard completionLoadingOverlay.superview != nil
        else {
            return
        }

        UIView.animate(
            withDuration: 0.15,
            animations: {

                self.completionLoadingOverlay.alpha = 0

            },
            completion: { _ in

                self.completionLoadingIndicator.stopAnimating()

                self.completionLoadingOverlay.removeFromSuperview()

                self.completionLoadingCard.removeFromSuperview()
            }
        )
    }
    
//    private func completeFinalTaskAndFinishProgram(
//        taskId: String
//    ) {
//
//        guard !isFinalizingEnrollment else {
//            return
//        }
//
//        guard
//            let userId = Auth.auth().currentUser?.uid,
//            let activeEnrollment = activeEnrollment,
//            let todayLog = todayLog
//        else {
//            print("🔴 Final task completion için gerekli veri eksik.")
//            return
//        }
//
//        // Son görevi tamamlanmış listeye ekle.
//        var updatedTaskIds = todayLog.completedTaskIds
//
//        if !updatedTaskIds.contains(taskId) {
//            updatedTaskIds.append(taskId)
//        }
//
//        let requiredTasks =
//            tasks.filter {
//                $0.isRequired != false
//            }
//
//        let requiredTaskIds =
//            Set(requiredTasks.map { $0.id })
//
//        let completedRequiredCount =
//            updatedTaskIds.filter {
//                requiredTaskIds.contains($0)
//            }.count
//
//        let totalRequiredTaskCount =
//            requiredTasks.count
//
//        let completionRate =
//            totalRequiredTaskCount > 0
//            ? Double(completedRequiredCount)
//                / Double(totalRequiredTaskCount)
//            : 0
//
//        let dailyThreshold =
//            min(
//                max(
//                    selectedProgram?
//                        .dailyTaskCompletionThreshold
//                        ?? 0.5,
//                    0.0
//                ),
//                1.0
//            )
//
//        let isDayCompleted =
//            completionRate >= dailyThreshold
//
//        isFinalizingEnrollment = true
//        
//        showProgramCompletionLoading()
//
//        // 1. ÖNCE son task gerçekten Firestore'a yazılır.
//        enrollmentRepository.updateCompletedTaskIds(
//            userId: userId,
//            enrollmentId: activeEnrollment.enrollmentId,
//            dateKey: todayLog.dateKey,
//            completedTaskIds: updatedTaskIds,
//            isCompleted: isDayCompleted
//        ) { [weak self] result in
//
//            DispatchQueue.main.async {
//
//                guard let self = self else {
//                    return
//                }
//
//                switch result {
//
//                case .failure(let error):
//
//                    self.isFinalizingEnrollment = false
//                    self.hideProgramCompletionLoading()
//
//                    print(
//                        "🔴 Son görev kaydedilemedi:",
//                        error.localizedDescription
//                    )
//
//                    let alert = UIAlertController(
//                        title: "Görev kaydedilemedi",
//                        message:
//                            "Son adım şu anda kaydedilemedi. Lütfen tekrar dene.",
//                        preferredStyle: .alert
//                    )
//
//                    alert.addAction(
//                        UIAlertAction(
//                            title: "Tamam",
//                            style: .default
//                        )
//                    )
//
//                    self.present(
//                        alert,
//                        animated: true
//                    )
//
//                case .success(let updatedLog):
//
//                    // Local UI state'i de güncelle.
//                    self.todayLog = updatedLog
//
//                    self.taskStates =
//                        self.taskStates.map { state in
//
//                            var updatedState = state
//
//                            updatedState.isCompleted =
//                                updatedLog.completedTaskIds
//                                    .contains(
//                                        updatedState.taskId
//                                    )
//
//                            return updatedState
//                        }
//
//                    self.tasksCardView.update(
//                        states: self.taskStates
//                    )
//
//                    self.updateBottomSummaryUI()
//
//                    // 2. TASK KAYDI BAŞARILI.
//                    // Şimdi programı gerçekten finalize ediyoruz.
//
//                    self.enrollmentRepository.finalizeEnrollment(
//                        userId: userId,
//                        enrollment: activeEnrollment,
//                        trigger: .lastTask
//                    ) { [weak self] finalizeResult in
//
//                        DispatchQueue.main.async {
//
//                            guard let self = self else {
//                                return
//                            }
//
//                            self.isFinalizingEnrollment = false
//                            self.hideProgramCompletionLoading()
//
//                            switch finalizeResult {
//
//                            case .failure(let error):
//
//                                print(
//                                    "🔴 Program finalize edilemedi:",
//                                    error.localizedDescription
//                                )
//
//                                let alert =
//                                    UIAlertController(
//                                        title:
//                                            "Program tamamlanamadı",
//                                        message:
//                                            error.localizedDescription,
//                                        preferredStyle:
//                                            .alert
//                                    )
//
//                                alert.addAction(
//                                    UIAlertAction(
//                                        title: "Tamam",
//                                        style: .default
//                                    )
//                                )
//
//                                self.present(
//                                    alert,
//                                    animated: true
//                                )
//
//                            case .success(
//                                let lifecycleResult
//                            ):
//
//                                switch lifecycleResult {
//
//                                case .completedWithBadge(
//                                    let finalizedEnrollment
//                                ):
//
//                                    /*
//                                     İŞTE İSTEDİĞİN BAĞLANTI.
//
//                                     Bu fonksiyon:
//                                     → Progress'i boşaltıyor
//                                     → ProgramCompletionViewController
//                                       oluşturuyor
//                                     → present ediyor
//                                    */
//
//                                    self.handleProgramCompletedWithBadge(
//                                        userId: userId,
//                                        enrollment:
//                                            finalizedEnrollment
//                                    )
//
//                                case .completedWithoutBadge(
//                                    let finalizedEnrollment
//                                ):
//
//                                    self.handleProgramCompletedWithoutBadge(
//                                        userId: userId,
//                                        enrollment:
//                                            finalizedEnrollment
//                                    )
//
//                                case .stillActive:
//
//                                    /*
//                                     Buraya gelmemeliyiz.
//                                     Çünkü kullanıcı final günün
//                                     son required task'ını onayladı.
//                                    */
//
//                                    print(
//                                        "🔴 HATA: Son görev tamamlandı fakat repository programı stillActive döndürdü."
//                                    )
//
//                                    let alert =
//                                        UIAlertController(
//                                            title:
//                                                "Program sonucu kesinleştirilemedi",
//                                            message:
//                                                "Son görevin kaydedildi fakat programın tamamlanma durumu oluşturulamadı.",
//                                            preferredStyle:
//                                                .alert
//                                        )
//
//                                    alert.addAction(
//                                        UIAlertAction(
//                                            title: "Tamam",
//                                            style: .default
//                                        )
//                                    )
//
//                                    self.present(
//                                        alert,
//                                        animated: true
//                                    )
//
//                                case .noActiveEnrollment:
//
//                                    self.resetActiveProgramState()
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    private func completeFinalTaskAndFinishProgram(
        taskId: String
    ) {

        guard !isFinalizingEnrollment else {
            return
        }

        guard
            let userId = Auth.auth().currentUser?.uid,
            let activeEnrollment = activeEnrollment,
            let todayLog = todayLog
        else {
            print("🔴 Final task completion için gerekli veri eksik.")
            return
        }

        // MARK: - Son görevi tamamlanmış listeye ekle

        var updatedTaskIds = todayLog.completedTaskIds

        if !updatedTaskIds.contains(taskId) {
            updatedTaskIds.append(taskId)
        }

        let requiredTasks =
            tasks.filter {
                $0.isRequired != false
            }

        let requiredTaskIds =
            Set(requiredTasks.map { $0.id })

        let completedRequiredCount =
            updatedTaskIds.filter {
                requiredTaskIds.contains($0)
            }.count

        let totalRequiredTaskCount =
            requiredTasks.count

        let completionRate =
            totalRequiredTaskCount > 0
            ? Double(completedRequiredCount)
                / Double(totalRequiredTaskCount)
            : 0

        let dailyThreshold =
            min(
                max(
                    selectedProgram?
                        .dailyTaskCompletionThreshold
                        ?? 0.5,
                    0.0
                ),
                1.0
            )

        let isDayCompleted =
            completionRate >= dailyThreshold


        // =====================================================
        // MARK: - OFFLINE FINAL COMPLETION
        // =====================================================

        if !NetworkMonitor.shared.isConnected {

            print("🟡 Offline: son görev local tamamlanıyor")

            // 1. Son görevi local UI/cache'e uygula.
            applyLocalTaskToggle(
                taskId: taskId,
                completedTaskIds: updatedTaskIds,
                isCompleted: isDayCompleted
            )

            // 2. Normal görevlerde kullandığımız mevcut pending sisteme ekle.
//            let pendingProgressAction =
//                PendingProgressAction(
//                    id: UUID(),
//                    userId: userId,
//                    enrollmentId: activeEnrollment.enrollmentId,
//                    dateKey: todayLog.dateKey,
//                    completedTaskIds: updatedTaskIds,
//                    isCompleted: isDayCompleted,
//                    createdAt: Date()
//                )
//
//            PendingProgressManager.shared.add(
//                pendingProgressAction
//            )
//
//            // 3. Ayrıca programın finalize edilmesi gerektiğini kaydet.
//            let pendingFinalization =
//                PendingProgramFinalizationAction(
//                    id: UUID(),
//                    userId: userId,
//                    enrollmentId: activeEnrollment.enrollmentId,
//                    createdAt: Date()
//                )
//
//            PendingProgramFinalizationManager.shared.add(
//                pendingFinalization
//            )
            
            let pendingProgressAction =
                PendingProgressAction(
                    id: UUID(),
                    userId: userId,
                    enrollmentId: activeEnrollment.enrollmentId,
                    dateKey: todayLog.dateKey,
                    completedTaskIds: updatedTaskIds,
                    isCompleted: isDayCompleted,
                    createdAt: Date(),
                    shouldFinalizeProgram: true
                )

            PendingProgressManager.shared.add(
                pendingProgressAction
            )

            print(
                "🟡 Offline program finalization pending action içine kaydedildi:",
                activeEnrollment.enrollmentId
            )
            

            print(
                "🟡 Offline program finalization kuyruğa alındı:",
                activeEnrollment.enrollmentId
            )

            // 4. Local ilerlemeyi hesapla.
            var finalProgressPercent =
                activeEnrollment.progressPercent

            if let selectedProgram = selectedProgram {

                let counts =
                    calculateOverallProgramProgress(
                        for: selectedProgram
                    )

                if counts.total > 0 {
                    finalProgressPercent =
                        (
                            Double(counts.completed)
                            / Double(counts.total)
                        ) * 100.0
                }
            }

            finalProgressPercent =
                min(
                    max(finalProgressPercent, 0),
                    100
                )

            let earnedBadge =
                finalProgressPercent
                >= ProgramCompletionPolicy.badgeUnlockPercent


            // 5. Sadece UI için geçici "completed enrollment" oluştur.
            // Firebase'e bunu yazmıyoruz.
            let localCompletedData: [String: Any] = [

                "userId": activeEnrollment.userId,
                "programId": activeEnrollment.programId,

                "programName":
                    activeEnrollment.programName ?? "",

                "durationDays":
                    activeEnrollment.durationDays,

                "badgeId":
                    activeEnrollment.badgeId,

                "badgeTitle":
                    activeEnrollment.badgeTitle,

                "badgeDescription":
                    activeEnrollment.badgeDescription,

                "badgeImageName":
                    activeEnrollment.badgeImageName,

                "programImageName":
                    activeEnrollment.programImageName,

                "status": "completed",

                "currentDay":
                    activeEnrollment.currentDay,

                "completedDaysCount":
                    activeEnrollment.completedDaysCount,

                "progressPercent":
                    finalProgressPercent,

                "isCompleted": true,

                "isFailed": false,

                "earnedBadge":
                    earnedBadge,

                "badgeEvaluationCompleted":
                    false,

                "finalizationVersion":
                    ProgramCompletionPolicy.finalizationVersion,

                "completionReason":
                    "offline_pending_sync",

                "finalProgressPercent":
                    finalProgressPercent
            ]

            guard
                let localCompletedEnrollment =
                    ActiveEnrollment(
                        documentId:
                            activeEnrollment.enrollmentId,
                        data:
                            localCompletedData
                    )
            else {

                print(
                    "🔴 Offline completed enrollment oluşturulamadı."
                )

                return
            }


            // 6. Kullanıcı açısından program hemen tamamlandı.
            if earnedBadge {

                handleProgramCompletedWithBadge(
                    userId: userId,
                    enrollment:
                        localCompletedEnrollment
                )

            } else {

                handleProgramCompletedWithoutBadge(
                    userId: userId,
                    enrollment:
                        localCompletedEnrollment
                )
            }

            // ÇOK ÖNEMLİ:
            // Buradan sonra online Firestore koduna geçmiyoruz.
            return
        }


        // =====================================================
        // MARK: - ONLINE FINAL COMPLETION
        // =====================================================
        //
        // BURADAN AŞAĞISI SENİN ÇALIŞAN SİSTEMİN.
        // DEĞİŞTİRMİYORUZ.
        // =====================================================

        isFinalizingEnrollment = true

        showProgramCompletionLoading()


        // 1. ÖNCE son task gerçekten Firestore'a yazılır.

        enrollmentRepository.updateCompletedTaskIds(

            userId: userId,

            enrollmentId:
                activeEnrollment.enrollmentId,

            dateKey:
                todayLog.dateKey,

            completedTaskIds:
                updatedTaskIds,

            isCompleted:
                isDayCompleted

        ) { [weak self] result in

            DispatchQueue.main.async {

                guard let self = self else {
                    return
                }


                switch result {


                // MARK: Task save failure

                case .failure(let error):

                    self.isFinalizingEnrollment = false

                    self.hideProgramCompletionLoading()

                    print(
                        "🔴 Son görev kaydedilemedi:",
                        error.localizedDescription
                    )

                    let alert =
                        UIAlertController(
                            title:
                                "Görev kaydedilemedi",
                            message:
                                "Son adım şu anda kaydedilemedi. Lütfen tekrar dene.",
                            preferredStyle:
                                .alert
                        )

                    alert.addAction(
                        UIAlertAction(
                            title: "Tamam",
                            style: .default
                        )
                    )

                    self.present(
                        alert,
                        animated: true
                    )


                // MARK: Task save success

                case .success(let updatedLog):

                    self.todayLog =
                        updatedLog

                    self.taskStates =
                        self.taskStates.map {
                            state in

                            var updatedState =
                                state

                            updatedState.isCompleted =
                                updatedLog
                                    .completedTaskIds
                                    .contains(
                                        updatedState.taskId
                                    )

                            return updatedState
                        }

                    self.tasksCardView.update(
                        states:
                            self.taskStates
                    )

                    self.updateBottomSummaryUI()


                    // 2. Task başarıyla Firestore'a ulaştı.
                    // Şimdi programı finalize ediyoruz.

                    self.enrollmentRepository
                        .finalizeEnrollment(

                            userId:
                                userId,

                            enrollment:
                                activeEnrollment,

                            trigger:
                                .lastTask

                        ) { [weak self] finalizeResult in

                            DispatchQueue.main.async {

                                guard
                                    let self = self
                                else {
                                    return
                                }

                                self.isFinalizingEnrollment =
                                    false

                                self.hideProgramCompletionLoading()


                                switch finalizeResult {


                                // MARK: Finalization failure

                                case .failure(let error):

                                    print(
                                        "🔴 Program finalize edilemedi:",
                                        error.localizedDescription
                                    )

                                    let alert =
                                        UIAlertController(

                                            title:
                                                "Program tamamlanamadı",

                                            message:
                                                error.localizedDescription,

                                            preferredStyle:
                                                .alert
                                        )

                                    alert.addAction(
                                        UIAlertAction(
                                            title:
                                                "Tamam",
                                            style:
                                                .default
                                        )
                                    )

                                    self.present(
                                        alert,
                                        animated:
                                            true
                                    )


                                // MARK: Finalization success

                                case .success(
                                    let lifecycleResult
                                ):

                                    switch lifecycleResult {


                                    case .completedWithBadge(
                                        let finalizedEnrollment
                                    ):

                                        self.handleProgramCompletedWithBadge(

                                            userId:
                                                userId,

                                            enrollment:
                                                finalizedEnrollment
                                        )


                                    case .completedWithoutBadge(
                                        let finalizedEnrollment
                                    ):

                                        self.handleProgramCompletedWithoutBadge(

                                            userId:
                                                userId,

                                            enrollment:
                                                finalizedEnrollment
                                        )


                                    case .stillActive:

                                        print(
                                            "🔴 HATA: Son görev tamamlandı fakat repository programı stillActive döndürdü."
                                        )

                                        let alert =
                                            UIAlertController(

                                                title:
                                                    "Program sonucu kesinleştirilemedi",

                                                message:
                                                    "Son görevin kaydedildi fakat programın tamamlanma durumu oluşturulamadı.",

                                                preferredStyle:
                                                    .alert
                                            )

                                        alert.addAction(
                                            UIAlertAction(
                                                title:
                                                    "Tamam",
                                                style:
                                                    .default
                                            )
                                        )

                                        self.present(
                                            alert,
                                            animated:
                                                true
                                        )


                                    case .noActiveEnrollment:

                                        self.resetActiveProgramState()
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func showCompletionPopup(for taskId: String) {

        let popup = ConfirmationPopupView()

        popup.titleText = "Son adımdasın ✨"
        popup.messageText = "Bu görevi tamamladığında program bitecek. Devam etmek istiyor musun?"
        popup.cancelTitle = "Vazgeç"
        popup.confirmTitle = "Devam et"

        popup.onConfirm = { [weak self] in

            guard let self = self else { return }

            self.completeFinalTaskAndFinishProgram(
                taskId: taskId
            )
        }

        popup.onCancel = {
            // Kullanıcı vazgeçti.
        }

        popup.present(in: self.view)
    }
    
    private func syncPendingProgressActions() {
        let pendingActions = PendingProgressManager.shared.loadAll()

        guard !pendingActions.isEmpty else {
            print("🟢 Pending action yok")
            return
        }

        print("🟡 Pending sync başladı. Action count:", pendingActions.count)

        for action in pendingActions {
            enrollmentRepository.updateCompletedTaskIds(
                userId: action.userId,
                enrollmentId: action.enrollmentId,
                dateKey: action.dateKey,
                completedTaskIds: action.completedTaskIds,
                isCompleted: action.isCompleted
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updatedLog):
                        print("✅ Pending action sync edildi:", action.id)

                        PendingProgressManager.shared.remove(id: action.id)

                        guard let self = self else { return }

                        if self.todayLog?.dateKey == updatedLog.dateKey {
                            self.todayLog = updatedLog

                            self.taskStates = self.taskStates.map { state in
                                var newState = state
                                newState.isCompleted = updatedLog.completedTaskIds.contains(state.taskId)
                                return newState
                            }

                            if let existingIndex = self.allDailyLogs.firstIndex(where: { $0.dateKey == updatedLog.dateKey }) {
                                self.allDailyLogs[existingIndex] = updatedLog
                            } else {
                                self.allDailyLogs.append(updatedLog)
                            }

                            self.tasksCardView.update(states: self.taskStates)
                            self.updateHeaderUI()
                            self.updateBottomSummaryUI()
                            self.updateProgramProgressCardUI()
                            self.updateProgramBadgeCardUI()
                            self.saveProgressToCache()
                        }

                    case .failure(let error):
                        print("🔴 Pending action sync edilemedi:", error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func calculateRemainingTimeText() -> String {
        let calendar = Calendar.current
        let now = Date()

        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else {
            return "--"
        }

        let components = calendar.dateComponents([.hour, .minute], from: now, to: endOfDay)

        let hour = max(0, components.hour ?? 0)
        let minute = max(0, components.minute ?? 0)

        return "\(hour)s \(minute)dk"
    }
    
    private func toggleExpansion(for taskId: String) {
        guard taskStates.firstIndex(where: { $0.taskId == taskId }) != nil else { return }

        for i in taskStates.indices {
            if taskStates[i].taskId == taskId {
                taskStates[i].isExpanded.toggle()
            } else {
                taskStates[i].isExpanded = false
            }
        }

        tasksCardView.update(states: taskStates)

        contentStackView.setNeedsLayout()
        contentStackView.layoutIfNeeded()
        contentContainerView.setNeedsLayout()
        contentContainerView.layoutIfNeeded()
        scrollContentView.setNeedsLayout()
        scrollContentView.layoutIfNeeded()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
      private func setupBottomSummaryCard() {
        bottomSummaryView.backgroundColor = .clear

        bottomSummaryCardView.translatesAutoresizingMaskIntoConstraints = false
        bottomSummaryView.addSubview(bottomSummaryCardView)

        NSLayoutConstraint.activate([
            bottomSummaryCardView.topAnchor.constraint(equalTo: bottomSummaryView.topAnchor, constant: 12),
            bottomSummaryCardView.leadingAnchor.constraint(equalTo: bottomSummaryView.leadingAnchor, constant: 14),
            bottomSummaryCardView.trailingAnchor.constraint(equalTo: bottomSummaryView.trailingAnchor, constant: -14),
            bottomSummaryCardView.bottomAnchor.constraint(equalTo: bottomSummaryView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
               showTodayContent()
           } else {
               showProgramContent()
           }
    }
    private func showTodayContent() {
        clearContentStack()
        contentStackView.addArrangedSubview(tasksCardView)
    }

    private func showProgramContent() {
        clearContentStack()
        contentStackView.addArrangedSubview(programProgressCardView)
        contentStackView.addArrangedSubview(programBadgeCardView)
        addProgramInfoCards()
        contentStackView.addArrangedSubview(endJourneyButton)
    }
    
    private func buildProgramInfoItems(from program: Program) -> [ProgramInfoItem] {
        return [
            ProgramInfoItem(
                title: program.weeklyReflection.title,
                shortDescription: program.weeklyReflection.shortDescription,
                details: program.weeklyReflection.details
            ),
            ProgramInfoItem(
                title: program.goldenRules.title,
                shortDescription: program.goldenRules.shortDescription,
                details: program.goldenRules.details
            ),
            ProgramInfoItem(
                title: program.realImpact.title,
                shortDescription: program.realImpact.shortDescription,
                details: program.realImpact.details
            ),
            ProgramInfoItem(
                title: program.dailyPlanSummary.title,
                shortDescription: program.dailyPlanSummary.shortDescription,
                details: program.dailyPlanSummary.details
            ),
            ProgramInfoItem(
                title: program.processResult.title,
                shortDescription: program.processResult.shortDescription,
                details: program.processResult.details
            )
        ]
    }

    private func addProgramInfoCards() {
        guard let program = selectedProgram else { return }

        let items = buildProgramInfoItems(from: program)

        for (index, item) in items.enumerated() {
            let accordionView = ProgramInfoAccordionView()
            accordionView.configure(
                item: item,
                isExpanded: programInfoStates[index],
                iconText: programInfoIcons[index]
            )

            accordionView.onToggleExpand = { [weak self] in
                self?.toggleProgramInfo(at: index)
            }

            contentStackView.addArrangedSubview(accordionView)
        }
    }

    private func toggleProgramInfo(at index: Int) {
        for i in programInfoStates.indices {
            if i == index {
                programInfoStates[i].toggle()
            } else {
                programInfoStates[i] = false
            }
        }

        showProgramContent()

        contentStackView.setNeedsLayout()
        contentStackView.layoutIfNeeded()
        contentContainerView.setNeedsLayout()
        contentContainerView.layoutIfNeeded()
        scrollContentView.setNeedsLayout()
        scrollContentView.layoutIfNeeded()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didTapEndJourney() {
        let title = "Emin misin?"
        let message = "Gayet iyi gidiyordun. Bu yolculuğu şimdi sonlandırırsan aktif programın kapanacak. Yolculuğu sonlandırmak istediğine emin misin?"

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center

        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .paragraphStyle: titleParagraphStyle,
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]
        )

        let messageParagraphStyle = NSMutableParagraphStyle()
        messageParagraphStyle.alignment = .center

        let attributedMessage = NSAttributedString(
            string: message,
            attributes: [
                .paragraphStyle: messageParagraphStyle,
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )

        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")

        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yolculuğu Sonlandır", style: .destructive, handler: { [weak self] _ in
            self?.confirmEndJourney()
        }))

        present(alert, animated: true)
    }
    
    private func confirmEndJourney() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 endJourney: userId yok")
            return
        }

        guard let activeEnrollment = activeEnrollment else {
            print("🔴 endJourney: activeEnrollment yok")
            return
        }

        enrollmentRepository.endJourney(
            userId: userId,
            enrollmentId: activeEnrollment.enrollmentId
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success:
                    print("✅ Yolculuk sonlandırıldı")

                    self.activeEnrollment = nil
                    self.todayLog = nil
                    self.allDailyLogs = []
                    self.currentStreak = 0
                    self.selectedProgram = nil
                    self.tasks = []
                    self.taskStates = []

                    ProgressCacheManager.shared.clear()
                    self.showEmptyState()

                case .failure(let error):
                    print("🔴 endJourney hata:", error.localizedDescription)

                    let alert = UIAlertController(
                        title: "Bir şeyler ters gitti",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func resetActiveProgramState() {

        activeEnrollment = nil
        todayLog = nil
        allDailyLogs = []

        selectedProgram = nil

        tasks = []
        taskStates = []

        currentStreak = 0

        programInfoStates = [
            false,
            false,
            false,
            false,
            false
        ]

        ProgressCacheManager.shared.clear()

        // Aktif program olmadığı için segmentin eski
        // program içeriğini tekrar açmasını engelliyoruz.
        segmentControl.selectedSegmentIndex = 0
        segmentControl.isEnabled = false

        showEmptyState()
    }
      
    private func showEmptyState() {
        setHeaderVisibility(isVisible: false)
        clearContentStack()

        let emptyView = makeEmptyStateView()
        guidedEmptyStateView = emptyView
        
        contentStackView.addArrangedSubview(emptyView)

        headerStatusLabel.text = "Henüz aktif programın yok"
        findProgramNameLabel()?.text = ""

        bottomSummaryCardView.configure(
            mantra: "Başlamak için kendine uygun bir program seç.",
            streakText: "0",
            completedText: "0/0",
            remainingText: "--"
        )
        
        DispatchQueue.main.async {
            [weak self] in

            self?.showProgressGuidedOnboardingIfNeeded()
        }
    }
    
    private func showProgressGuidedOnboardingIfNeeded() {

        guard activeCoachMark == nil else {
            return
        }

        guard
            let uid = Auth.auth().currentUser?.uid
        else {
            return
        }

        let manager =
            GuidedOnboardingManager.shared

        print(
            "🧭 GUIDED Progress active:",
            manager.isActive(
                for: uid
            )
        )

        print(
            "🧭 GUIDED Progress step:",
            manager.currentStep(
                for: uid
            )?.rawValue ?? "nil"
        )

        guard manager.isActive(
            for: uid
        ) else {
            return
        }

        guard
            manager.currentStep(
                for: uid
            ) == .programProgress
        else {
            return
        }

        guard
            let guidedEmptyStateView
        else {
            print(
                "🧭 GUIDED: Progress empty state hazır değil"
            )
            return
        }

        view.layoutIfNeeded()

        guard let hostView =
            tabBarController?.view
            ?? self.view
        else {
            return
        }

        activeCoachMark =
            GuidedOnboardingCoordinator
                .shared
                .present(
                    uid: uid,
                    step:
                        .programProgress,
                    over:
                        hostView,
                    targetView:
                        guidedEmptyStateView,
                    onPrimary: { [weak self] in
                        guard let self else {
                            return
                        }

                        self.activeCoachMark = nil

                        print(
                            "🧭 GUIDED: Progress → Completed"
                        )

                        self.tabBarController?.selectedIndex = 2
                    },
                    onSkip: {
                        [weak self] in

                        self?.activeCoachMark = nil
                    }
                )
    }
    
    

    private func makeEmptyStateView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 24

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Henüz aktif bir program seçmedin"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(red: 35/255, green: 45/255, blue: 63/255, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Programlar ekranından bir yolculuk seçerek ilerlemeni buradan takip edebilirsin."
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 113/255, green: 122/255, blue: 138/255, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Programlara Git", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 250/255, green: 185/255, blue: 219/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.addTarget(self, action: #selector(didTapGoToPrograms), for: .touchUpInside)

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(button)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            button.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -28),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])

        return container
    }

    @objc private func didTapGoToPrograms() {
        tabBarController?.selectedIndex = 0
    }
    

    private func clearContentStack() {
        contentStackView.arrangedSubviews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    private func findProgramNameLabel() -> UILabel? {
        return view.viewWithTag(101) as? UILabel
    }
    
    private func saveProgressToCache() {
        guard let selectedProgram = selectedProgram,
              let todayLog = todayLog else {
            print("🟡 Cache save atlandı: eksik veri")
            return
        }

        let cachedLogs = allDailyLogs.map {
            CachedDailyLog(
                dateKey: $0.dateKey,
                dayNumber: $0.dayNumber,
                completedTaskIds: $0.completedTaskIds,
                isCompleted: $0.isCompleted
            )
        }

        let cache = ProgressCache(
            programId: selectedProgram.id,
            programName: selectedProgram.name,
            totalDays: selectedProgram.durationDays,
            dateKey: todayLog.dateKey,
            dayNumber: todayLog.dayNumber,
            todayCompletedTaskIds: todayLog.completedTaskIds,
            todayIsCompleted: todayLog.isCompleted,
            currentStreak: currentStreak,
            allDailyLogs: cachedLogs
        )

        ProgressCacheManager.shared.save(cache)
        print("🟢 Progress cache kaydedildi")
    }
    
    
       private func loadProgressFromCache() {
        guard let cache = ProgressCacheManager.shared.load() else {
            print("🟡 Progress cache bulunamadı")
            return
        }

        print("🟢 Progress cache bulundu")
        print("🟢 cache dateKey:", cache.dateKey)
        print("🟢 cache dayNumber:", cache.dayNumber)
        print("🟢 cache todayCompletedTaskIds:", cache.todayCompletedTaskIds)
        print("🟢 cache allDailyLogs count:", cache.allDailyLogs.count)

        let programs = ProgramLoader.loadPrograms()
        if let cachedProgram = programs.first(where: { $0.id == cache.programId }) {
            self.loadTasks(for: cachedProgram)

            DispatchQueue.main.async {
                self.applyCacheToUI(cache)
            }
        }
    }
    
    private func applyCacheToUI(_ cache: ProgressCache) {
        self.currentStreak = cache.currentStreak

        self.todayLog = DailyLog(
            logId: cache.dateKey,
            enrollmentId: "",
            userId: "",
            programId: cache.programId,
            dateKey: cache.dateKey,
            dayNumber: cache.dayNumber,
            completedTaskIds: cache.todayCompletedTaskIds,
            isCompleted: cache.todayIsCompleted,
            completedAt: nil,
            createdAt: nil,
            updatedAt: nil
        )

        self.allDailyLogs = cache.allDailyLogs.map {
            DailyLog(
                logId: $0.dateKey,
                enrollmentId: "",
                userId: "",
                programId: cache.programId,
                dateKey: $0.dateKey,
                dayNumber: $0.dayNumber,
                completedTaskIds: $0.completedTaskIds,
                isCompleted: $0.isCompleted,
                completedAt: nil,
                createdAt: nil,
                updatedAt: nil
            )
        }

        self.taskStates = self.taskStates.map { state in
            var newState = state
            newState.isCompleted = cache.todayCompletedTaskIds.contains(state.taskId)
            return newState
        }

        self.tasksCardView.update(states: self.taskStates)
        self.updateHeaderUI()
        self.updateBottomSummaryUI()
        self.updateProgramProgressCardUI()
        self.updateProgramBadgeCardUI()
    }
    
    private func updateProgramBadgeCardUI() {
        guard let data = buildProgramBadgeCardData() else { return }
        programBadgeCardView.configure(with: data)
    }
    
    private func buildProgramBadgeCardData() -> ProgramBadgeCardData? {
        guard let selectedProgram = selectedProgram else {
            return nil
        }

        let progressCounts = calculateOverallProgramProgress(
            for: selectedProgram
        )

        let progressRatio: Double

        if progressCounts.total > 0 {
            progressRatio =
                Double(progressCounts.completed) /
                Double(progressCounts.total)
        } else {
            progressRatio = 0
        }

        let progressPercent = min(
            max(
                Int((progressRatio * 100.0).rounded()),
                0
            ),
            100
        )

        // Rozet kazanma eşiği
        let unlockThreshold =
            Int(
                ProgramCompletionPolicy
                    .badgeUnlockPercent
            )

        // Yalnızca kilit burada açılıyor.
        // Progress %100'e kadar devam edecek.
        let isUnlocked = progressPercent >= unlockThreshold

        return ProgramBadgeCardData(
            badgeName: "✨ \(selectedProgram.name) Rozeti",
            badgeDescription: "Program ilerlemenin %\(unlockThreshold)'ine ulaştığında bu rozeti kazanırsın.",
            badgeImageName: selectedProgram.badgeImageName ?? selectedProgram.imageName,
            progressPercent: progressPercent,
            unlockThreshold: unlockThreshold,
            isUnlocked: isUnlocked
        )
    }

    
    private func fetchActiveEnrollmentAndLog() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 Progress: userId yok")
            showEmptyState()
            return
        }

        enrollmentRepository.fetchActiveEnrollmentForProgress(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let lifecycleResult):
                    switch lifecycleResult {

                    case .stillActive(let enrollment):
                        print("🟢 Progress lifecycle: program hâlâ aktif")
                        self.prepareActiveProgramScreen(
                            userId: userId,
                            enrollment: enrollment
                        )

                    case .completedWithBadge(let enrollment):
                        print("🟢 Progress lifecycle: program tamamlandı ve rozet kazanıldı")
                        self.handleProgramCompletedWithBadge(
                            userId: userId,
                            enrollment: enrollment
                        )

                    case .completedWithoutBadge(let enrollment):
                        print("🟡 Progress lifecycle: program tamamlandı ama rozet kazanılmadı")
                        self.handleProgramCompletedWithoutBadge(
                            userId: userId,
                            enrollment: enrollment
                        )

                    case .noActiveEnrollment:
                        print("🟡 Progress lifecycle: aktif enrollment yok")
                        self.showEmptyState()
                    }

                case .failure(let error):
                    print("🔴 Progress lifecycle hatası:", error.localizedDescription)
                    self.showEmptyState()
                }
            }
        }
    }
    
    private func prepareActiveProgramScreen(
        userId: String,
        enrollment: ActiveEnrollment
    ) {
        self.activeEnrollment = enrollment
        segmentControl.isEnabled = true

        ProgramService.shared.fetchPrograms { [weak self] programs in
            DispatchQueue.main.async {
                guard let self = self else { return }

                guard let matchedProgram = programs.first(where: { $0.id == enrollment.programId }) else {
                    print("🔴 Progress: Firestore programId ile eşleşen program bulunamadı")
                    self.showEmptyState()
                    return
                }

                self.loadTasks(for: matchedProgram, dayNumber: enrollment.currentDay)

                if self.segmentControl.selectedSegmentIndex == 0 {
                    self.showTodayContent()
                }

                print("🟢 Progress: aktif enrollment bulundu:", enrollment.enrollmentId)

                self.enrollmentRepository.getOrCreateTodayLog(
                    userId: userId,
                    enrollment: enrollment
                ) { [weak self] result in
                    DispatchQueue.main.async {
                        guard let self = self else { return }

                        switch result {
                        case .success(let log):
                            self.applyTodayLogAndLoadSummary(
                                userId: userId,
                                enrollment: enrollment,
                                log: log
                            )

                        case .failure(let error):
                            print("🔴 Progress: DailyLog hatası:", error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    private func applyTodayLogAndLoadSummary(
        userId: String,
        enrollment: ActiveEnrollment,
        log: DailyLog
    ) {
        self.todayLog = log
        
        if let selectedProgram = selectedProgram {
            self.loadTasks(for: selectedProgram, dayNumber: log.dayNumber)
        }

        self.taskStates = self.taskStates.map { state in
            var newState = state
            newState.isCompleted = log.completedTaskIds.contains(state.taskId)
            return newState
        }

        self.tasksCardView.update(states: self.taskStates)

        self.enrollmentRepository.refreshUserStreak(
            userId: userId,
            todayLog: log
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let streakData):
                    self.currentStreak = streakData.currentStreak

                case .failure(let error):
                    print("🔴 User streak okunamadı/güncellenemedi:", error.localizedDescription)
                }

                self.enrollmentRepository.fetchAllDailyLogs(
                    userId: userId,
                    enrollmentId: enrollment.enrollmentId
                ) { logsResult in
                    DispatchQueue.main.async {
                        switch logsResult {
                        case .success(let logs):
                            self.allDailyLogs = logs

                        case .failure(let error):
                            print("🔴 Tüm daily loglar alınamadı:", error.localizedDescription)
                            self.allDailyLogs = []
                        }

                        self.updateHeaderUI()
                        self.updateBottomSummaryUI()
                        self.updateProgramProgressCardUI()
                        self.updateProgramBadgeCardUI()
                        self.saveProgressToCache()

                        print("✅ Progress: bugünün log'u hazır")
                        print("✅ dateKey:", log.dateKey)
                        print("✅ dayNumber:", log.dayNumber)
                        print("✅ completedTaskIds:", log.completedTaskIds)
                    }
                }
            }
        }
    }
    
    private func handleProgramCompletedWithBadge(
        userId: String,
        enrollment: ActiveEnrollment
    ) {

        guard
            handledCompletedEnrollmentId
                != enrollment.enrollmentId
        else {
            return
        }

        handledCompletedEnrollmentId =
            enrollment.enrollmentId

        /*
         Backend artık tamamlandı.
         Progress tarafındaki active state hemen temizlenir.
        */
        resetActiveProgramState()

        /*
         Programlar / Tamamlanan gibi diğer ekranlara
         backend state'in değiştiğini bildiriyoruz.
        */
        NotificationCenter.default.post(
            name: .activeEnrollmentDidChange,
            object: nil
        )

        let vc = ProgramCompletionViewController()

        vc.programTitle =
            enrollment.badgeTitle.isEmpty
            ? enrollment.programName
            : enrollment.badgeTitle

        vc.programImageName =
            enrollment.badgeImageName.isEmpty
            ? enrollment.programImageName
            : enrollment.badgeImageName

        vc.userId = userId
        vc.enrollmentId = enrollment.enrollmentId

        vc.modalPresentationStyle = .fullScreen

        present(
            vc,
            animated: true
        )
    }
    
    private func handleProgramCompletedWithoutBadge(
        userId: String,
        enrollment: ActiveEnrollment
    ) {

        guard
            handledCompletedEnrollmentId
                != enrollment.enrollmentId
        else {
            return
        }

        handledCompletedEnrollmentId =
            enrollment.enrollmentId

        resetActiveProgramState()

        NotificationCenter.default.post(
            name: .activeEnrollmentDidChange,
            object: nil
        )

        let finalPercent =
            Int(
                (
                    enrollment.finalProgressPercent
                    ?? enrollment.progressPercent
                ).rounded()
            )

        let alert = UIAlertController(
            title: "Yolculuğun Tamamlandı 🌙",
            message:
                "Programını tamamladın. Genel ilerlemen %\(finalPercent) oldu. Rozet kazanmak için gereken %\(Int(ProgramCompletionPolicy.badgeUnlockPercent)) eşiğine bu kez ulaşamadın.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Yeni Programa Başla",
                style: .default,
                handler: { [weak self] _ in
                    self?.tabBarController?
                        .selectedIndex = 0
                }
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Tamam",
                style: .cancel
            )
        )

        present(
            alert,
            animated: true
        )
    }
    
    
    private let endJourneyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Yolculuğu Sonlandır", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.25).cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        return button
    }()
    
//    private func showProgramCompletionScreen() {
//        guard let userId = Auth.auth().currentUser?.uid,
//              let activeEnrollment = activeEnrollment else { return }
//
//        let vc = ProgramCompletionViewController()
//        vc.programTitle = selectedProgram?.name
//        vc.programImageName = selectedProgram?.imageName
//        vc.userId = userId
//        vc.enrollmentId = activeEnrollment.enrollmentId
//
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
    
    
    }
extension Notification.Name {
    static let profileImageDidChange = Notification.Name("profileImageDidChange")
}
