//
//  CompletedProgramsViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import FirebaseAuth

final class CompletedProgramsViewController: UIViewController {

    private let enrollmentRepository = EnrollmentRepository()
    private var completedItems: [CompletedProgramDisplayItem] = []
    private let summaryHeaderView = CompletedSummaryHeaderView()
    private weak var activeCoachMark: LunoraCoachMarkView?
    
    private let tableView = UITableView()
    private let pageBackgroundColor = UIColor(named: "lunoraPink") ?? UIColor(
        red: 246/255,
        green: 238/255,
        blue: 244/255,
        alpha: 1
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = pageBackgroundColor
        setupTableView()
        setupHeaderView()
        loadCompletedPrograms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCompletedPrograms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("🧭 GUIDED: Completed viewDidAppear")

        DispatchQueue.main.async { [weak self] in
            self?.showCompletedGuidedOnboardingIfNeeded()
        }
    }
    
    private func showCompletedGuidedOnboardingIfNeeded() {

        guard activeCoachMark == nil else {
            return
        }

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let manager = GuidedOnboardingManager.shared

        print(
            "🧭 GUIDED Completed active:",
            manager.isActive(for: uid)
        )

        print(
            "🧭 GUIDED Completed step:",
            manager.currentStep(for: uid)?.rawValue ?? "nil"
        )

        guard manager.isActive(for: uid) else {
            return
        }

        guard manager.currentStep(for: uid) == .completed else {
            return
        }

        view.layoutIfNeeded()
        tableView.layoutIfNeeded()

        guard let hostView =
            tabBarController?.view ?? viewIfLoaded
        else {
            return
        }

        activeCoachMark =
            GuidedOnboardingCoordinator.shared.present(
                uid: uid,
                step: .completed,
                over: hostView,
                targetView: summaryHeaderView,

                // Bu son coach mark.
                // Henüz Manager'ı finish etme.
                advanceOnPrimary: false,

                onPrimary: { [weak self] in

                    guard let self else {
                        return
                    }

                    self.activeCoachMark = nil

                    print(
                        "🧭 GUIDED: Completed anlatımı bitti → final modal"
                    )

                    GuidedOnboardingCompletionView.present(
                        over: hostView
                    ) { [weak self] in

                        guard let self else {
                            return
                        }

                        GuidedOnboardingManager.shared.finish(
                            for: uid
                        )

                        print(
                            "🧭 GUIDED: Onboarding tamamen tamamlandı ✨"
                        )

                        self.tabBarController?.selectedIndex = 0
                    }
                },

                onSkip: { [weak self] in
                    self?.activeCoachMark = nil
                }
            )
    }

    private func loadCompletedPrograms() {

        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 Completed: userId yok")
            return
        }

        ProgramService.shared.fetchAllPrograms { [weak self] programs in

            guard let self = self else {
                return
            }

            self.enrollmentRepository.fetchCompletedEnrollments(
                userId: userId
            ) { [weak self] result in

                DispatchQueue.main.async {

                    guard let self = self else {
                        return
                    }

                    switch result {

                    case .success(let enrollments):

                        self.completedItems =
                            enrollments.compactMap { enrollment in

                                guard
                                    let program =
                                        programs.first(
                                            where: {
                                                $0.id ==
                                                enrollment.programId
                                            }
                                        )
                                else {

                                    print(
                                        "🔴 Completed: program bulunamadı:",
                                        enrollment.programId
                                    )

                                    return nil
                                }

                                return CompletedProgramDisplayItem(
                                    enrollmentId:
                                        enrollment.enrollmentId,

                                    programName:
                                        program.name,

                                    imageName:
                                        program.badgeImageName
                                        ?? program.imageName,

                                    durationText:
                                        program.durationText,

                                    completedDateText:
                                        self.formatCompletedDate(
                                            enrollment
                                                .completedAt?
                                                .dateValue()
                                        ),

                                    completionNote:
                                        enrollment.completionNote,

                                    completedDaysCount:
                                        enrollment.completedDaysCount,

                                    elements:
                                        program.elements
                                )
                            }

                        self.tableView.reloadData()

                        let totalPrograms =
                            self.completedItems.count

                        let badgeImages =
                            self.completedItems.map {
                                $0.imageName
                            }

                        self.enrollmentRepository
                            .fetchTotalActivityDays(
                                userId: userId
                            ) { [weak self] activityDaysResult in

                                guard let self = self else {
                                    return
                                }

                                let totalActivityDays: Int

                                switch activityDaysResult {

                                case .success(let days):

                                    totalActivityDays = days

                                    print(
                                        "🟣 Completed toplam aktivite günü:",
                                        days
                                    )

                                case .failure(let error):

                                    print(
                                        "🔴 Toplam aktivite günü hesaplanamadı:",
                                        error.localizedDescription
                                    )

                                    totalActivityDays = 0
                                }

                                self.enrollmentRepository
                                    .fetchLongestFullTaskStreak(
                                        userId: userId,
                                        programs: programs
                                    ) { [weak self] streakResult in

                                        DispatchQueue.main.async {

                                            guard let self = self else {
                                                return
                                            }

                                            let longestFullTaskStreak: Int

                                            switch streakResult {

                                            case .success(let streak):

                                                longestFullTaskStreak =
                                                    streak

                                            case .failure(let error):

                                                print(
                                                    "🔴 Longest full task streak hesaplanamadı:",
                                                    error.localizedDescription
                                                )

                                                longestFullTaskStreak = 0
                                            }

                                            let headerData =
                                                CompletedSummaryHeaderData(
                                                    completedProgramCount:
                                                        totalPrograms,

                                                    totalCompletedDays:
                                                        totalActivityDays,

                                                    bestStreakText:
                                                        "\(longestFullTaskStreak)",

                                                    badgeImageNames:
                                                        badgeImages
                                                )

                                            self.summaryHeaderView
                                                .configure(
                                                    with: headerData
                                                )

                                            self.tableView
                                                .tableHeaderView =
                                                self.summaryHeaderView
                                        }
                                    }
                            }

                        print(
                            "🟢 Completed item count:",
                            self.completedItems.count
                        )

                    case .failure(let error):

                        print(
                            "🔴 Completed kayıtları alınamadı:",
                            error.localizedDescription
                        )
                    }
                }
            }
        }
    }

    private func formatCompletedDate(_ date: Date?) -> String {
        guard let date = date else {
            return "Tarih yok"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = pageBackgroundColor
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = pageBackgroundColor 
        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            CompletedProgramTableViewCell.self,
            forCellReuseIdentifier: CompletedProgramTableViewCell.identifier
        )

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
extension CompletedProgramsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CompletedProgramTableViewCell.identifier,
            for: indexPath
        ) as? CompletedProgramTableViewCell else {
            return UITableViewCell()
        }

        let item = completedItems[indexPath.row]
        cell.configure(with: item)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 180
    }
    private func setupHeaderView() {
        summaryHeaderView.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 450
        )

        summaryHeaderView.onTapAddProgram = { [weak self] in
            self?.tabBarController?.selectedIndex = 0
        }

        tableView.tableHeaderView = summaryHeaderView
    }
}
