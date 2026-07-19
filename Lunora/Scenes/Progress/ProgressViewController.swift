//
//  ProgressViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import FirebaseAuth

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
    private var activeEnrollment: ActiveEnrollment?
    private var todayLog: DailyLog?
    private var allDailyLogs: [DailyLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        setupContentStack()
        bindTaskActions()
        setupBottomSummaryCard()
        setupSegmentControl()
        showTodayContent()
        loadProfileImage()

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
            view.backgroundColor = UIColor(red: 246/255, green: 238/255, blue: 244/255, alpha: 1)

            scrollContentView.alwaysBounceVertical = true
            scrollContentView.showsVerticalScrollIndicator = false
            scrollContentView.contentInsetAdjustmentBehavior = .never
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
            userProfileImageView.image = UIImage(named: "defaultAvatar")
            return
        }

        setHeaderVisibility(isVisible: true)

        findProgramNameLabel()?.text = selectedProgram.name

        let displayDay = min(todayLog.dayNumber, selectedProgram.durationDays)
        let currentDayText = "Gün \(displayDay) / \(selectedProgram.durationDays)"
        let streakText = "\(currentStreak) gün streak 🔥"

        headerStatusLabel.text = "\(currentDayText) · \(streakText)"

        if userProfileImageView.image == nil {
            userProfileImageView.image = UIImage(named: "defaultAvatar")
        }

        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
    }
        
    
    private func getDefaultAvatar(for uid: String) -> UIImage? {
        
//        Default avatar BURAYI UNUTMA BURADAN EKLE !!
        return nil
    }
    
    private func resolveAvatarImage(for uid: String) -> UIImage? {
        
        if let profile = ProfileStore.shared.fetchProfile(uid: uid),
           let data = profile.avatarImageData,
           let image = UIImage(data: data) {
            return image
        }

        if let defaultAvatar = getDefaultAvatar(for: uid) {
            return defaultAvatar
        }

        return UIImage(named: "defaultAvatar")
    }
    
    private func loadProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            applyAvatarUI(image: UIImage(named: "defaultAvatar"))
            return
        }

        let avatar = resolveAvatarImage(for: uid)
        applyAvatarUI(image: avatar)
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
    
    private func buildElementProgressItems(
        from tasks: [DailyTask],
        completedTaskIds: Set<String>
    ) -> [ElementProgressItem] {
        
        let elementOrder = ["fire", "water", "air", "earth"]
        
        let groupedTasks = Dictionary(grouping: tasks) { task in
            task.elementKey ?? "unknown"
        }
        
        var items: [ElementProgressItem] = []
        
        for key in elementOrder {
            guard let elementTasks = groupedTasks[key], !elementTasks.isEmpty else {
                continue
            }
            
            let completedCount = elementTasks.filter {
                completedTaskIds.contains($0.id)
            }.count
            
            let firstTask = elementTasks[0]
            
            let item = ElementProgressItem(
                key: key,
                name: firstTask.elementName ?? key,
                emoji: firstTask.elementEmoji ?? "✨",
                totalCount: elementTasks.count,
                completedCount: completedCount
            )
            
            items.append(item)
        }
        
        return items
    }
    
    private func allProgramTasks(for program: Program) -> [DailyTask] {
        if let days = program.days, !days.isEmpty {
            return days.flatMap { $0.tasks }
        }

        return program.dailyTasks
    }

    private func completedTaskIdsAcrossProgram() -> Set<String> {
        return Set(allDailyLogs.flatMap { $0.completedTaskIds })
    }
    

    private func programElementsToShow(for program: Program, allTasks: [DailyTask]) -> [ProgramElement] {
        if let elements = program.programElements, !elements.isEmpty {
            return elements
        }

        let elementKeysInTasks = Set(allTasks.compactMap { $0.elementKey })

        if elementKeysInTasks.isEmpty {
            return [
                ProgramElement(key: "general", name: "Genel", emoji: "✨")
            ]
        }

        let defaultElements: [ProgramElement] = [
            ProgramElement(key: "fire", name: "Ateş", emoji: "🔥"),
            ProgramElement(key: "water", name: "Su", emoji: "💧"),
            ProgramElement(key: "air", name: "Hava", emoji: "🌬️"),
            ProgramElement(key: "earth", name: "Toprak", emoji: "🌍")
        ]

        return defaultElements.filter { elementKeysInTasks.contains($0.key) }
    }

    private func buildElementProgressItems(
        for program: Program,
        allTasks: [DailyTask],
        completedTaskIds: Set<String>
    ) -> [ElementProgressItem] {

        let elements = programElementsToShow(for: program, allTasks: allTasks)

        let groupedTasks = Dictionary(grouping: allTasks) { task in
            task.elementKey ?? "general"
        }

        return elements.map { element in
            let elementTasks = groupedTasks[element.key] ?? []

            let completedCount = elementTasks.filter {
                completedTaskIds.contains($0.id)
            }.count

            return ElementProgressItem(
                key: element.key,
                name: element.name,
                emoji: element.emoji,
                totalCount: elementTasks.count,
                completedCount: completedCount
            )
        }
    }

    private func colorForElementKey(_ key: String) -> UIColor {
        switch key {
        case "fire":
            return UIColor(red: 241/255, green: 64/255, blue: 154/255, alpha: 1)
        case "water":
            return UIColor(red: 80/255, green: 160/255, blue: 255/255, alpha: 1)
        case "air":
            return UIColor(red: 156/255, green: 77/255, blue: 255/255, alpha: 1)
        case "earth":
            return UIColor(red: 80/255, green: 190/255, blue: 150/255, alpha: 1)
        case "general":
            return UIColor(red: 222/255, green: 120/255, blue: 174/255, alpha: 1)
        default:
            return UIColor.systemGray
        }
    }

//    private func buildProgramProgressCardData() -> ProgramProgressCardData? {
//        guard let selectedProgram = selectedProgram else {
//            return nil
//        }
//
//        let totalDays = max(1, selectedProgram.durationDays)
//
//        let currentDay: Int
//        if let todayLog = todayLog {
//            currentDay = min(todayLog.dayNumber, totalDays)
//        } else {
//            currentDay = 1
//        }
//
//        let totalTaskCountPerDay = max(1, tasks.count)
//        let totalPossibleTaskCompletions = totalDays * totalTaskCountPerDay
//
//        let validTaskIds = Set(tasks.map { $0.id })
//
//        // ✅ Sadece bu programa ait task id'lerini say
//        let totalCompletedTaskCount = allDailyLogs.reduce(0) { result, log in
//            let validCompletedIds = log.completedTaskIds.filter { validTaskIds.contains($0) }
//            return result + validCompletedIds.count
//        }
//
//        let progressRatio = Double(totalCompletedTaskCount) / Double(totalPossibleTaskCompletions)
//        let progressPercent = Int((progressRatio * 100.0).rounded())
//        let colorPalette: [UIColor] = [
//            UIColor(red: 241/255, green: 64/255, blue: 154/255, alpha: 1),
//            UIColor(red: 156/255, green: 77/255, blue: 255/255, alpha: 1),
//            UIColor(red: 92/255, green: 99/255, blue: 235/255, alpha: 1),
//            UIColor(red: 204/255, green: 70/255, blue: 255/255, alpha: 1),
//            UIColor(red: 255/255, green: 170/255, blue: 80/255, alpha: 1),
//            UIColor(red: 80/255, green: 190/255, blue: 180/255, alpha: 1),
//            UIColor(red: 120/255, green: 130/255, blue: 255/255, alpha: 1),
//            UIColor(red: 255/255, green: 120/255, blue: 150/255, alpha: 1)
//        ]
//
//        let completedTaskIdsForToday = Set(
//            taskStates
//                .filter { $0.isCompleted }
//                .map { $0.taskId }
//        )
//
//        let elementItems = buildElementProgressItems(
//            from: tasks,
//            completedTaskIds: completedTaskIdsForToday
//        )
//
//        let legendItems: [ProgramProgressCardLegendItem] = elementItems.enumerated().map { index, item in
//            let chartValue = CGFloat(item.percentage) / 100.0
//            
//            return ProgramProgressCardLegendItem(
//                color: colorPalette[index % colorPalette.count],
//                title: "\(item.emoji) \(item.name)",
//                valueText: "\(item.percentage)%",
//                chartValue: chartValue
//            )
//        }
//
//        print("🟣 totalDays:", totalDays)
//        print("🟣 totalTaskCountPerDay:", totalTaskCountPerDay)
//        print("🟣 totalPossibleTaskCompletions:", totalPossibleTaskCompletions)
//        print("🟣 totalCompletedTaskCount:", totalCompletedTaskCount)
//        print("🟣 progressPercent:", progressPercent)
//
//        return ProgramProgressCardData(
//            currentDay: currentDay,
//            totalDays: totalDays,
//            progressPercent: progressPercent,
//            donutCenterPercent: progressPercent,
//            legendItems: legendItems
//        )
//    }
    
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

        let allTasks = allProgramTasks(for: selectedProgram)

        let requiredTasks = allTasks.filter { $0.isRequired != false }
        let requiredTaskIds = Set(requiredTasks.map { $0.id })

        let completedTaskIds = completedTaskIdsAcrossProgram()
        let completedRequiredTaskIds = completedTaskIds.filter {
            requiredTaskIds.contains($0)
        }

        let totalRequiredTaskCount = max(1, requiredTasks.count)
        let totalCompletedRequiredTaskCount = completedRequiredTaskIds.count

        let progressRatio = Double(totalCompletedRequiredTaskCount) / Double(totalRequiredTaskCount)
        let progressPercent = Int((progressRatio * 100.0).rounded())

        let elementItems = buildElementProgressItems(
            for: selectedProgram,
            allTasks: allTasks,
            completedTaskIds: completedTaskIds
        )

//        let legendItems: [ProgramProgressCardLegendItem] = elementItems.map { item in
//            let chartValue: CGFloat
//
//            if totalRequiredTaskCount > 0 {
//                let requiredElementTasks = allTasks.filter {
//                    ($0.elementKey ?? "general") == item.key && $0.isRequired != false
//                }
//
//                let requiredElementTaskIds = Set(requiredElementTasks.map { $0.id })
//
//                let completedRequiredElementCount = completedTaskIds.filter {
//                    requiredElementTaskIds.contains($0)
//                }.count
//
//                chartValue = CGFloat(completedRequiredElementCount) / CGFloat(totalRequiredTaskCount)
//            } else {
//                chartValue = 0
//            }
//
//            return ProgramProgressCardLegendItem(
//                color: colorForElementKey(item.key),
//                title: "\(item.emoji) \(item.name)",
//                valueText: "\(item.percentage)%",
//                chartValue: chartValue
//            )
//        }
        
        let legendItems: [ProgramProgressCardLegendItem] = elementItems.map { item in

            let requiredElementTasks = allTasks.filter {
                ($0.elementKey ?? "general") == item.key && $0.isRequired != false
            }

            let requiredElementTaskIds = Set(requiredElementTasks.map { $0.id })

            let completedRequiredElementCount = completedTaskIds.filter {
                requiredElementTaskIds.contains($0)
            }.count

            let elementPercent: Int
            if requiredElementTasks.isEmpty {
                elementPercent = 0
            } else {
                elementPercent = Int((Double(completedRequiredElementCount) / Double(requiredElementTasks.count) * 100).rounded())
            }

            let chartValue: CGFloat
            if totalRequiredTaskCount > 0 {
                chartValue = CGFloat(completedRequiredElementCount) / CGFloat(totalRequiredTaskCount)
            } else {
                chartValue = 0
            }

            return ProgramProgressCardLegendItem(
                color: colorForElementKey(item.key),
                title: "\(item.emoji) \(item.name)",
                valueText: "\(elementPercent)%",
                chartValue: chartValue
            )
        }

        print("🧩 legendItems:", legendItems.map { "\($0.title) value:\($0.valueText) chart:\($0.chartValue)" })

        print("🟣 totalDays:", totalDays)
        print("🟣 allTasks:", allTasks.count)
        print("🟣 requiredTasks:", requiredTasks.count)
        print("🟣 completedRequired:", totalCompletedRequiredTaskCount)
        print("🟣 progressPercent:", progressPercent)

        return ProgramProgressCardData(
            currentDay: currentDay,
            totalDays: totalDays,
            progressPercent: progressPercent,
            donutCenterPercent: progressPercent,
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

        let shouldSkipPopup = UserDefaults.standard.bool(forKey: "skipCompletionPopupOnce")

        if shouldSkipPopup {
            UserDefaults.standard.set(false, forKey: "skipCompletionPopupOnce")
        }

        if !shouldSkipPopup && isTryingToCompleteTask && isLastTask && isLastDay {
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
    
    
    private func showCompletionPopup(for taskId: String) {
        
        let popup = ConfirmationPopupView()

        popup.titleText = "Son adımdasın ✨"
        popup.messageText = "Bu görevi tamamladığında program bitecek. Devam etmek istiyor musun?"
        popup.cancelTitle = "Vazgeç"
        popup.confirmTitle = "Devam et"

        popup.onConfirm = { [weak self] in
            UserDefaults.standard.set(true, forKey: "skipCompletionPopupOnce")
            self?.toggleCompletion(for: taskId)
            self?.showProgramCompletionScreen()
        }
        popup.onCancel = {
            // hiçbir şey yapma
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
      
    private func showEmptyState() {
        setHeaderVisibility(isVisible: false)
        clearContentStack()

        let emptyView = makeEmptyStateView()
        contentStackView.addArrangedSubview(emptyView)

        headerStatusLabel.text = "Henüz aktif programın yok"
        findProgramNameLabel()?.text = ""
        userProfileImageView.image = UIImage(named: "defaultAvatar")

        bottomSummaryCardView.configure(
            mantra: "Başlamak için kendine uygun bir program seç.",
            streakText: "0",
            completedText: "0/0",
            remainingText: "--"
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
    
    private func buildProgramBadgeCardData() -> ProgramBadgeCardData?  {
        guard let selectedProgram = selectedProgram else {
            return nil
        }

        let totalDays = max(1, selectedProgram.durationDays)
        let totalTaskCountPerDay = max(1, tasks.count)
        let totalPossibleTaskCompletions = totalDays * totalTaskCountPerDay

        let totalCompletedTaskCount = allDailyLogs.reduce(0) { partialResult, log in
            partialResult + log.completedTaskIds.count
        }

        let progressRatio = Double(totalCompletedTaskCount) / Double(totalPossibleTaskCompletions)
        let progressPercent = Int((progressRatio * 100.0).rounded())

        let unlockThreshold = 80
        let isUnlocked = progressPercent >= unlockThreshold

        return ProgramBadgeCardData(
            badgeName: "✨ \(selectedProgram.name) Rozeti",
            badgeDescription: "Bu rozeti açmak için ilerlemeni %\(unlockThreshold) seviyesine ulaştır.",
            badgeImageName: selectedProgram.imageName,
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
        self.activeEnrollment = enrollment

        ProgressCacheManager.shared.clear()

        let vc = ProgramCompletionViewController()
        vc.programTitle = enrollment.programName
        vc.programImageName = enrollment.programImageName
        vc.userId = userId
        vc.enrollmentId = enrollment.enrollmentId

        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func handleProgramCompletedWithoutBadge(
        userId: String,
        enrollment: ActiveEnrollment
    ) {
        self.activeEnrollment = nil
        self.todayLog = nil
        self.allDailyLogs = []
        self.currentStreak = 0
        self.selectedProgram = nil
        self.tasks = []
        self.taskStates = []

        ProgressCacheManager.shared.clear()
        showEmptyState()

        let alert = UIAlertController(
            title: "Yolculuğun Tamamlandı 🌙",
            message: "Bu programın süresi tamamlandı. Bu kez rozet kazanmak için gereken ilerleme oranına ulaşamadın, ama attığın adımlar kaydedildi.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yeni Programa Başla", style: .default, handler: { [weak self] _ in
            self?.tabBarController?.selectedIndex = 0
        }))

        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel))

        present(alert, animated: true)
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
    
    private func showProgramCompletionScreen() {
        guard let userId = Auth.auth().currentUser?.uid,
              let activeEnrollment = activeEnrollment else { return }

        let vc = ProgramCompletionViewController()
        vc.programTitle = selectedProgram?.name
        vc.programImageName = selectedProgram?.imageName
        vc.userId = userId
        vc.enrollmentId = activeEnrollment.enrollmentId

        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    }
