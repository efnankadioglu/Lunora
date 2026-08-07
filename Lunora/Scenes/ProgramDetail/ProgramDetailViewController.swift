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

    case details(
        duration: String,
        difficulty: String,
        flexibility: String
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

    private var activeEnrollment: ActiveEnrollment?


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


    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)

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


    // MARK: - UI Setup

    private func setupUI() {

        view.backgroundColor = ProgramDetailTheme.backgroundColor
        tableView.backgroundColor = ProgramDetailTheme.backgroundColor

        view.addSubview(headerView)
        headerView.addSubview(titleLabel)

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

            titleLabel.bottomAnchor.constraint(
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
                greaterThanOrEqualToConstant: 48
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
                duration: makeDurationText(for: program),
                difficulty: "\(program.difficultyLevel) / \(program.difficultyScale)",
                flexibility: makeElementText(for: program)
            )
        )


        // MARK: Badge

        sections.append(
            .badge(
                title: "Tamamladığında Kazanacağın Rozet",
                subtitle: program.badgeDescription,
                imageName: program.badgeImageName ?? program.imageName
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
                    title: "💡 Eğer bu problemlere sahipsen doğru programı seçtin",
                    items: problems
                )
            )
        }


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


        case .details(
            let duration,
            let difficulty,
            let flexibility
        ):

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailsCardCell",
                for: indexPath
            ) as! DetailsCardCell

            cell.configure(
                duration: duration,
                difficulty: difficulty,
                flexibility: flexibility
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
