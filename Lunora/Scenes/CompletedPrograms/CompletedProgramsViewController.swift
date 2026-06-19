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

    private func loadCompletedPrograms() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("🔴 Completed: userId yok")
            
            return
        }

        let programs = ProgramLoader.loadPrograms()

        enrollmentRepository.fetchCompletedEnrollments(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let enrollments):
                    self.completedItems = enrollments.compactMap { enrollment in
                        guard let program = programs.first(where: { $0.id == enrollment.programId }) else {
                            print("🔴 Completed: program bulunamadı:", enrollment.programId)
                            return nil
                        }

                        return CompletedProgramDisplayItem(
                            enrollmentId: enrollment.enrollmentId,
                            programName: program.name,
                            imageName: program.badgeImageName ?? program.imageName,
                            durationText: program.durationText,
                            completedDateText: self.formatCompletedDate(enrollment.completedAt?.dateValue()),
                            completionNote: enrollment.completionNote,
                            completedDaysCount: enrollment.completedDaysCount,
                            elements: program.elements
                        )
                    }
                    
                    self.tableView.reloadData()
                    
                    let totalPrograms = self.completedItems.count
                    let totalDays = self.completedItems.reduce(0) { $0 + $1.completedDaysCount }

                    let badgeImages = self.completedItems.map { $0.imageName }

                    let elementCardViewModel = self.makeElementBalanceCardViewModel(
                        from: self.completedItems
                    )
                    
                    self.enrollmentRepository.fetchLongestFullTaskStreak(
                        userId: userId,
                        programs: programs
                    ) { [weak self] streakResult in
                        
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            
                            let longestFullTaskStreak: Int
                            
                            switch streakResult {
                            case .success(let streak):
                                longestFullTaskStreak = streak
                                
                            case .failure(let error):
                                print("🔴 Longest full task streak hesaplanamadı:", error.localizedDescription)
                                longestFullTaskStreak = 0
                            }
                            
                            let headerData = CompletedSummaryHeaderData(
                                completedProgramCount: totalPrograms,
                                totalCompletedDays: totalDays,
                                bestStreakText: "\(longestFullTaskStreak)",
                                badgeImageNames: badgeImages,
                                elementCardViewModel: elementCardViewModel 
                            )
                            
                            self.summaryHeaderView.configure(with: headerData)
                            self.tableView.tableHeaderView = self.summaryHeaderView
                        }
                    }

                    print("🟢 Completed item count:", self.completedItems.count)

                case .failure(let error):
                    print("🔴 Completed kayıtları alınamadı:", error.localizedDescription)
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
            height: 520
        )

        tableView.tableHeaderView = summaryHeaderView
    }
}
