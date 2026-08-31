import UIKit
import FirebaseAuth

private enum ProgramDetailTheme {

    static let backgroundColor = UIColor(
        red: 255 / 255,
        green: 235 / 255,
        blue: 246 / 255,
        alpha: 1
    )

    static let cardColor = UIColor.white.withAlphaComponent(0.72)

    static let innerCardColor = UIColor.white.withAlphaComponent(0.52)

    static let accentColor = UIColor(
        red: 247 / 255,
        green: 83 / 255,
        blue: 154 / 255,
        alpha: 1
    )

    static let primaryTextColor = UIColor.label.withAlphaComponent(0.88)

    static let secondaryTextColor = UIColor.label.withAlphaComponent(0.62)
}

enum ProgramDetailSection {
    case text(
        title: String?,
        body: String
    )

    case bullets(
        title: String,
        items: [String]
    )
    
    case activities(
        title: String,
        items: [ProgramActivityType]
    )
    
    case requirements(
        title: String,
        items: [ProgramRequirementItem]
    )
    
    case skyCompatibility(
        compatibility: ProgramSkyCompatibility
    )
    
    case journeyStages(
        title: String,
        stages: [ProgramJourneyStage]
    )

    case details(
        duration: String,
        dailyDuration: String,
        difficulty: String,
        elementItems: [String]
    )

    case badge(
        title: String,
        subtitle: String,
        imageName: String
    )
}

final class ProgramDetailViewController: UIViewController {

    // MARK: - Data

    private let program: Program

    private var sections: [ProgramDetailSection] = []

    private let enrollmentRepository = EnrollmentRepository()
    
//    private let skyCompatibilityProvider = MockProgramSkyCompatibilityProvider()
    
    private let skyCompatibilityProvider = SimpleProgramSkyCompatibilityProvider()

    private var activeEnrollment: ActiveEnrollment?
    private weak var activeCoachMark: LunoraCoachMarkView?


    // MARK: - UI

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ProgramDetailTheme.backgroundColor
        return view
    }()


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 26,
            weight: .bold
        )

        label.textColor = .label
        label.textAlignment = .center

        label.numberOfLines = 2

        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75

        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        label.textColor = ProgramDetailTheme.secondaryTextColor
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()


    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.separatorStyle = .none

        tableView.backgroundColor = .clear

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150

        tableView.showsVerticalScrollIndicator = false

        tableView.contentInset = UIEdgeInsets(
            top: 8,
            left: 0,
            bottom: 8,
            right: 0
        )

        return tableView
    }()


    private let bottomContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ProgramDetailTheme.backgroundColor
        return view
    }()


    private lazy var startButton: GradientPrimaryButton = {
        let button = GradientPrimaryButton()

        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(
            "Bugün Kendim İçin Başlıyorum 🌟",
            for: .normal
        )

        button.setTitleColor(
            .white,
            for: .normal
        )

        button.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )

        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8

        button.addTarget(
            self,
            action: #selector(didTapProgramStartButton),
            for: .touchUpInside
        )

        return button
    }()


    // MARK: - Init

    init(program: Program) {
        self.program = program

        super.init(
            nibName: nil,
            bundle: nil
        )
    }


    required init?(coder: NSCoder) {
        fatalError(
            "ProgramDetailViewController storyboard üzerinden oluşturulmamalı."
        )
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        hidesBottomBarWhenPushed = true

        setupUI()
        setupConstraints()
        setupTableView()
        configureUI()
        buildSections()
        fetchActiveEnrollmentDetails()
    }
    
    override func viewDidAppear(
        _ animated: Bool
    ) {
        super.viewDidAppear(animated)

        print(
            "🧭 GUIDED: ProgramDetail viewDidAppear"
        )

        showGuidedOnboardingIfNeeded()
    }
    
    // MARK: - Guided Onboarding

    private func showGuidedOnboardingIfNeeded() {

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
            "🧭 GUIDED Detail active:",
            manager.isActive(
                for: uid
            )
        )

        print(
            "🧭 GUIDED Detail step:",
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
            ) == .programDetail
        else {
            return
        }

        view.layoutIfNeeded()

        activeCoachMark =
            GuidedOnboardingCoordinator
                .shared
                .present(
                    uid: uid,
                    step:
                        .programDetail,
                    over:
                        view,
                    targetView:
                        headerView,
                    onPrimary: {
                        [weak self] in

                        guard let self else {
                            return
                        }

                        self.activeCoachMark = nil

                        let tabBarController =
                            self.tabBarController

                        let programNavigationController =
                            self.navigationController

                        // Önce Progress tabına geç
                        tabBarController?.selectedIndex = 1

                        // Sonra Programs navigation stack'ini
                        // arka planda temizle
                        programNavigationController?
                            .popToRootViewController(
                                animated: false
                            )
                    },
                    onSkip: {
                        [weak self] in

                        self?.activeCoachMark = nil
                    }
                )
    }


    // MARK: - UI Setup

    private func setupUI() {

        view.backgroundColor = ProgramDetailTheme.backgroundColor
        tableView.backgroundColor = ProgramDetailTheme.backgroundColor

        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)

        view.addSubview(tableView)

        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(startButton)
    }


    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // MARK: Header

            headerView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            headerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            headerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),


            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 18
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 24
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor,
                constant: -24
            ),

            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),

            subtitleLabel.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 28
            ),

            subtitleLabel.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor,
                constant: -28
            ),

            subtitleLabel.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: -16
            ),


            // MARK: Bottom Container

            bottomContainerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            bottomContainerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            bottomContainerView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),


            // MARK: Start Button

            startButton.topAnchor.constraint(
                equalTo: bottomContainerView.topAnchor,
                constant: 18
            ),

            startButton.leadingAnchor.constraint(
                equalTo: bottomContainerView.leadingAnchor,
                constant: 24
            ),

            startButton.trailingAnchor.constraint(
                equalTo: bottomContainerView.trailingAnchor,
                constant: -24
            ),

            startButton.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 60
            ),

            startButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -12
            ),


            // MARK: TableView

            tableView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo: bottomContainerView.topAnchor
            )
        ])
    }


    private func configureUI() {
        titleLabel.text = program.name
        subtitleLabel.text = program.detailPageSubtitle ?? program.oneSentenceSummary
    }


    // MARK: - TableView

    private func setupTableView() {

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            TextCardCell.self,
            forCellReuseIdentifier: "TextCardCell"
        )

        tableView.register(
            BulletCardCell.self,
            forCellReuseIdentifier: "BulletCardCell"
        )
        
        tableView.register(
            ActivityTypesCell.self,
            forCellReuseIdentifier: "ActivityTypesCell"
        )
        
        tableView.register(
            ProgramRequirementsCell.self,
            forCellReuseIdentifier: "ProgramRequirementsCell"
        )
        
        tableView.register(
            ProgramSkyCompatibilityCell.self,
            forCellReuseIdentifier: "ProgramSkyCompatibilityCell"
        )
        
        tableView.register(
            ProgramJourneyStagesCell.self,
            forCellReuseIdentifier: "ProgramJourneyStagesCell"
        )

        tableView.register(
            DetailsCardCell.self,
            forCellReuseIdentifier: "DetailsCardCell"
        )

        tableView.register(
            BadgeRewardCell.self,
            forCellReuseIdentifier: "BadgeRewardCell"
        )
    }


    // MARK: - Sections

    private func buildSections() {

        sections.removeAll()


        // MARK: Program Details

        sections.append(
            .details(
                duration: program.durationText,
                dailyDuration: makeDailyDurationText(for: program),
                difficulty: "\(program.difficultyLevel)/\(program.difficultyScale)",
                elementItems: makeElementItems(for: program)
            )
        )

        // MARK: Summary

        let summary = program.oneSentenceSummary
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if !summary.isEmpty {

            sections.append(
                .text(
                    title: nil,
                    body: summary
                )
            )
        }


        // MARK: Problems

        let problems = program.coreProblems.filter {

            !$0.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty
        }

        if !problems.isEmpty {

            sections.append(
                .bullets(
                    title: "Bu program sana iyi gelebilir eğer...",
                    items: problems
                )
            )
        }
        
        // MARK: Activity Types

        if let activityTypes = program.activityTypes,
           !activityTypes.isEmpty {

            sections.append(
                .activities(
                    title: "Bu programda seni neler bekliyor?",
                    items: activityTypes
                )
            )
        }
        
        // MARK: Program Requirements

        if let requirements = program.programRequirements,
           !requirements.items.isEmpty {

            sections.append(
                .requirements(
                    title: "Bu yolculuk için ihtiyacın olanlar",
                    items: requirements.items
                )
            )
        }
        
        // MARK: Sky Compatibility

        if let skyCompatibility =
            skyCompatibilityProvider.compatibility(for: program) {

            sections.append(
                .skyCompatibility(
                    compatibility: skyCompatibility
                )
            )
        }
        
        // MARK: Journey Stages

        if let journeyStages = program.journeyStages,
           !journeyStages.isEmpty {

            sections.append(
                .journeyStages(
                    title: "Bu program nasıl ilerler?",
                    stages: journeyStages
                )
            )
        }
        
        // MARK: Badge

        sections.append(
            .badge(
                title: "Tamamladığında Kazanacağın Rozet",
                subtitle: program.badgeDescription,
                imageName: program.badgeImageName ?? program.imageName
            )
        )


        // MARK: Full Text

        for item in program.fullText {

            let text = item.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            guard !text.isEmpty else {
                continue
            }

            let parts = text.components(
                separatedBy: "\n"
            )

            let title = parts.first

            let body = parts
                .dropFirst()
                .joined(separator: "\n")

            sections.append(
                .text(
                    title: title,
                    body: body
                )
            )
        }


        tableView.reloadData()
    }


    // MARK: - Helpers

    private func makeDurationText(
        for program: Program
    ) -> String {

        return """
        \(program.durationText)
        \(program.dailyDurationText)
        """
    }
    
    private func makeDailyDurationText(
        for program: Program
    ) -> String {

        return program.dailyDurationText
            .replacingOccurrences(
                of: "Günlük süre:",
                with: ""
            )
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
    }

    private func makeElementText(
        for program: Program
    ) -> String {

        if let programElements = program.programElements,
           !programElements.isEmpty {

            return programElements
                .map {
                    "\($0.emoji) \($0.name)"
                }
                .joined(separator: "\n")
        }

        return program.elements
    }
    
    private func makeElementItems(
        for program: Program
    ) -> [String] {

        if let programElements = program.programElements,
           !programElements.isEmpty {

            return programElements.map {
                "\($0.emoji) \($0.name)"
            }
        }

        let raw = program.elements
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return raw
    }


    private func makeDayRoadmapItems(
        for program: Program
    ) -> [String] {

        guard let days = program.days,
              !days.isEmpty else {
            return []
        }

        return days.map { day in
            "Gün \(day.dayNumber): \(day.title)"
        }
    }


    // MARK: - Program Start

    @objc
    private func didTapProgramStartButton() {

        if activeEnrollment?.programId == program.id {

            showSimpleAlert(
                title: "Bu program zaten aktif",
                message: "Şu anda devam ettiğin program bu."
            )

            return
        }


        if activeEnrollment != nil {

            showSimpleAlert(
                title: "Zaten aktif programın var",
                message: "Yeni bir programa başlamak için mevcut programını tamamlamalısın."
            )

            return
        }


        let popup = ConfirmationPopupView()

        popup.titleText = "Hazır mısın?"

        popup.messageText = """
        Bu yolculuk seni değiştirebilir.
        Başlamak ister misin? ✨
        """

        popup.cancelTitle = "Vazgeç"
        popup.confirmTitle = "Başla"


        popup.onCancel = {
            print("❌ Vazgeçildi")
        }


        popup.onConfirm = { [weak self] in

            guard let self else {
                return
            }

            guard let userId = Auth.auth().currentUser?.uid else {

                self.showSimpleAlert(
                    title: "Hata",
                    message: "Kullanıcı oturumu bulunamadı."
                )

                return
            }


            self.enrollmentRepository.startProgram(
                userId: userId,
                programId: self.program.id
            ) { result in

                DispatchQueue.main.async {

                    switch result {

                    case .success(let enrollmentId):

                        print(
                            "✅ Detail program başladı:",
                            enrollmentId
                        )

                        UserDefaults.standard.set(
                            true,
                            forKey: "shouldOpenProgressTodayTab"
                        )

                        self.fetchActiveEnrollmentDetails()

                        self.tabBarController?.selectedIndex = 1


                    case .failure(let error):

                        if let customError = error as? EnrollmentStartError,
                           customError == .alreadyHasActiveProgram {

                            self.showSimpleAlert(
                                title: "Zaten aktif programın var",
                                message: "Yeni bir programa başlamak için mevcut programını tamamlamalısın."
                            )

                        } else {

                            self.showSimpleAlert(
                                title: "Hata",
                                message: error.localizedDescription
                            )
                        }
                    }
                }
            }
        }


        popup.present(in: view)
    }


    // MARK: - Active Enrollment

    private func fetchActiveEnrollmentDetails() {

        guard let userId = Auth.auth().currentUser?.uid else {

            print("🔴 Detail: userId yok")

            activeEnrollment = nil

            return
        }


        enrollmentRepository.fetchActiveEnrollment(
            userId: userId
        ) { [weak self] result in

            DispatchQueue.main.async {

                guard let self else {
                    return
                }


                switch result {

                case .success(let enrollment):

                    self.activeEnrollment = enrollment


                    guard let enrollment else {

                        print(
                            "🟡 Detail aktif enrollment yok"
                        )

                        return
                    }


                    print(
                        "🟢 Detail aktif enrollment bulundu"
                    )

                    print(
                        "🟢 Detail enrollmentId:",
                        enrollment.enrollmentId
                    )

                    print(
                        "🟢 Detail programId:",
                        enrollment.programId
                    )


                    self.enrollmentRepository.getOrCreateTodayLog(
                        userId: userId,
                        enrollment: enrollment
                    ) { result in

                        DispatchQueue.main.async {

                            switch result {

                            case .success(let dailyLog):

                                print(
                                    "✅ Bugünün daily log'u hazır"
                                )

                                print(
                                    "✅ logId:",
                                    dailyLog.logId
                                )

                                print(
                                    "✅ dateKey:",
                                    dailyLog.dateKey
                                )

                                print(
                                    "✅ dayNumber:",
                                    dailyLog.dayNumber
                                )

                                print(
                                    "✅ completedTaskIds:",
                                    dailyLog.completedTaskIds
                                )


                            case .failure(let error):

                                print(
                                    "🔴 DailyLog alınamadı/oluşturulamadı:",
                                    error.localizedDescription
                                )
                            }
                        }
                    }


                case .failure(let error):

                    print(
                        "🔴 Detail aktif enrollment okunamadı:",
                        error.localizedDescription
                    )
                }
            }
        }
    }


    // MARK: - Alert

    private func showSimpleAlert(
        title: String,
        message: String
    ) {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Tamam",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }
}


// MARK: - UITableViewDataSource

extension ProgramDetailViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        sections.count
    }


    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let item = sections[indexPath.row]


        switch item {

        case .text(
            let title,
            let body
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TextCardCell",
                for: indexPath
            ) as! TextCardCell

            cell.configure(
                title: title,
                body: body
            )

            return cell


        case .bullets(
            let title,
            let items
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BulletCardCell",
                for: indexPath
            ) as! BulletCardCell

            cell.configure(
                title: title,
                bullets: items
            )

            return cell
            
        case .activities(
            let title,
            let items
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ActivityTypesCell",
                for: indexPath
            ) as! ActivityTypesCell

            cell.configure(
                title: title,
                items: items
            )

            return cell
            
        case .requirements(
            let title,
            let items
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProgramRequirementsCell",
                for: indexPath
            ) as! ProgramRequirementsCell

            cell.configure(
                title: title,
                items: items
            )

            return cell
            
        case .skyCompatibility(
            let compatibility
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProgramSkyCompatibilityCell",
                for: indexPath
            ) as! ProgramSkyCompatibilityCell

            cell.configure(
                compatibility: compatibility
            )

            return cell
            
        case .journeyStages(
            let title,
            let stages
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProgramJourneyStagesCell",
                for: indexPath
            ) as! ProgramJourneyStagesCell

            cell.configure(
                title: title,
                stages: stages
            )

            return cell


        case .details(
            let duration,
            let dailyDuration,
            let difficulty,
            let elementItems
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailsCardCell",
                for: indexPath
            ) as! DetailsCardCell

            cell.configure(
                duration: duration,
                dailyDuration: dailyDuration,
                difficulty: difficulty,
                elementItems: elementItems

            )
            return cell


        case .badge(
            let title,
            let subtitle,
            let imageName
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BadgeRewardCell",
                for: indexPath
            ) as! BadgeRewardCell

            cell.configure(
                title: title,
                subtitle: subtitle,
                imageName: imageName
            )

            return cell
        }
    }
}


// MARK: - UITableViewDelegate

extension ProgramDetailViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )
    }
}
