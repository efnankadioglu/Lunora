

import UIKit

enum ProgramDetailSection {
    case text(title: String?, body: String)
    case bullets(title: String, items: [String])
    case details(duration: String, difficulty: String, flexibility: String)
    case badge(title: String, subtitle: String, imageName: String)
}

final class ProgramDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Data
    var program: Program!   // ProgramList’ten push/segue ile set edilecek
    private var sections: [ProgramDetailSection] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            titleLabel.text = program?.name
            self.hidesBottomBarWhenPushed = true

            setupTableView()
            buildSections()
        }

        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(TextCardCell.self, forCellReuseIdentifier: "TextCardCell")
            tableView.register(BulletCardCell.self, forCellReuseIdentifier: "BulletCardCell")
            tableView.register(DetailsCardCell.self, forCellReuseIdentifier: "DetailsCardCell")
            tableView.register(BadgeRewardCell.self, forCellReuseIdentifier: "BadgeRewardCell")
            
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 150
        }

        private func buildSections() {
            sections.removeAll()
            
            sections.append(.details(
                duration: program.durationText,
                difficulty: "\(program.difficultyLevel) / \(program.difficultyScale)",
                flexibility: program.elements
//                flexibility:"AKASHA ENERGY"
            ))
            
            // EKLEDİM: Rozet kutucuğu
            sections.append(.badge(
                title: "Tamamladığında Kazanacağın Rozet",
                subtitle: program.badgeDescription,
                imageName: program.imageName
            ))

            let summary = program.oneSentenceSummary.trimmingCharacters(in: .whitespacesAndNewlines)
            if !summary.isEmpty {
                sections.append(.text(title: nil, body: summary))
            }

            let problems = program.coreProblems.filter {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            if !problems.isEmpty {
                sections.append(.bullets(
                    title: "💡 Eğer bu problemlere sahipsen doğru programı seçtin",
                    items: problems
                ))
            }

            for item in program.fullText {
                
                let text = item.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { continue }

                // metni satırlara ayır
                let parts = text.components(separatedBy: "\n")

                let title = parts.first
                let body = parts.dropFirst().joined(separator: "\n")

                sections.append(.text(
                    title: title,
                    body: body
                ))
            }
            tableView.reloadData()
        }
    }
 
extension ProgramDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = sections[indexPath.row]

        switch item {
        case .text(let title, let body):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCardCell", for: indexPath) as! TextCardCell
            cell.configure(title: title, body: body)
            return cell

        case .bullets(let title, let items):
            let cell = tableView.dequeueReusableCell(withIdentifier: "BulletCardCell", for: indexPath) as! BulletCardCell
            cell.configure(title: title, bullets: items)
            return cell

        case .details(let duration, let difficulty, let flexibility):
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCardCell", for: indexPath) as! DetailsCardCell
            cell.configure(duration: duration, difficulty: difficulty, flexibility: flexibility)
            return cell
        case .badge(title: let title, subtitle: let subtitle, imageName: let imageName):
            let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeRewardCell", for: indexPath) as! BadgeRewardCell
            cell.configure(title: title, subtitle: subtitle, imageName: imageName)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ProgramDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
