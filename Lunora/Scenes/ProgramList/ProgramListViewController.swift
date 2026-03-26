//
//  ProgramListViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.10.2025.
//

import UIKit
import FirebaseDatabase
class ProgramListViewController: UIViewController {
    
    @IBOutlet weak var astrologyCard: UIView!
    @IBOutlet weak var programsCardView: UIView!
    @IBOutlet weak var programsTableView: UITableView!
    
    private var programs: [Program] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTableView()
            loadPrograms()
            testFirebaseConnection()
        }
    
    func testFirebaseConnection() {
        // Firebase referansını oluşturuyoruz
        let ref = Database.database().reference()
        
        // Veritabanına "test_mesaji" adında bir dal açıp içine yazı yazıyoruz
        ref.child("test_mesaji").setValue("Selam Efnan! Bağlantı başarılı 🚀") { error, _ in
            if let error = error {
                print("Eyvah! Veri gönderilemedi: \(error.localizedDescription)")
            } else {
                print("Yaşasın! Veri başarıyla Firebase'e uçtu.")
            }
        }
    }
        
        private func setupUI() {
            applyCardStyle(to: astrologyCard)
            applyCardStyle(to: programsCardView)
        }
        
        private func setupTableView() {
            programsTableView.delegate = self
            programsTableView.dataSource = self
            
            programsTableView.separatorStyle = .none
            programsTableView.backgroundColor = .clear
//            programsTableView.rowHeight = UITableView.automaticDimension
//            programsTableView.estimatedRowHeight = 180
            programsTableView.rowHeight = 220
            programsTableView.showsVerticalScrollIndicator = false
            
            programsTableView.register(
                UINib(nibName: "ProgramTableViewCell", bundle: nil),
                forCellReuseIdentifier: "ProgramTableViewCell"
            )
        }
        
        private func loadPrograms() {
            programs = ProgramLoader.loadPrograms()
            programsTableView.reloadData()
        }
        
        private func applyCardStyle(
            to view: UIView,
            cornerRadius: CGFloat = 24,
            shadowOpacity: Float = 0.08,
            shadowRadius: CGFloat = 16,
            shadowOffset: CGSize = CGSize(width: 0, height: 6)
        ) {
            view.layer.cornerRadius = cornerRadius
            view.layer.masksToBounds = false
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = shadowOpacity
            view.layer.shadowRadius = shadowRadius
            view.layer.shadowOffset = shadowOffset
            
            DispatchQueue.main.async {
                let path = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRadius)
                view.layer.shadowPath = path.cgPath
            }
        }
    }


extension ProgramListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // EKLEDİM: Her programı ayrı bir section yaptım ki section footer ile araya boşluk verebilelim
    func numberOfSections(in tableView: UITableView) -> Int {
        return programs.count
    }
    
    // DEĞİŞTİRDİM: Artık her section içinde sadece 1 cell var
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProgramTableViewCell",
            for: indexPath
        ) as! ProgramTableViewCell
        
        // DEĞİŞTİRDİM: indexPath.row yerine indexPath.section kullanıyoruz
        let program = programs[indexPath.section]
        cell.configure(with: program)
        return cell
    }
    
    // EKLEDİM: Kartlar arası boşluk
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    // EKLEDİM: Footer görünmesin, sadece şeffaf boşluk olarak çalışsın
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("✅ didSelect çalıştı: \(indexPath.row)")
        print("nav var mı:", navigationController != nil)
        
        // DEĞİŞTİRDİM: Burada da row yerine section kullanıyoruz
        let selectedProgram = programs[indexPath.section]
        print("Seçilen program:", selectedProgram.name)
        
        let storyboard = UIStoryboard(name: "ProgramDetail", bundle: nil)
            
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "ProgramDetailViewController"
        ) as? ProgramDetailViewController {
                
            vc.program = selectedProgram
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
