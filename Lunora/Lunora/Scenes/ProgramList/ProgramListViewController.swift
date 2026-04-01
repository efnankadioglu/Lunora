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
    
    @IBOutlet weak var mercuryRetrogradeView: UIButton!
    @IBOutlet weak var venusRetrogradeView: UIButton!
    @IBOutlet weak var marsRetrogradeView: UIButton!
    @IBOutlet weak var saturnRetrogradeView: UIButton!
    @IBOutlet weak var newMoonView: UIButton!
    @IBOutlet weak var fullMoonView: UIButton!
    @IBOutlet weak var lunarEclipseView: UIButton!
    @IBOutlet weak var solarEclipseView: UIButton!
    
    
    private var programs: [Program] = []
//    private var popupBackgroundView: UIView?
    private var tooltipView: UIView?
    
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
    
//    private func showTooltip(from button: UIButton, text: String) {
//        
//        // varsa eski tooltip’i kaldır
//        tooltipView?.removeFromSuperview()
//        
//        let tooltip = UIView()
//        tooltip.backgroundColor = .black
//        tooltip.layer.cornerRadius = 12
//        tooltip.translatesAutoresizingMaskIntoConstraints = false
//        
//        let label = UILabel()
//        label.text = text
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        tooltip.addSubview(label)
//        self.view.addSubview(tooltip)
//        
//        NSLayoutConstraint.activate([
//            tooltip.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
//            tooltip.centerXAnchor.constraint(equalTo: button.centerXAnchor),
//            tooltip.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
//            
//            label.topAnchor.constraint(equalTo: tooltip.topAnchor, constant: 10),
//            label.bottomAnchor.constraint(equalTo: tooltip.bottomAnchor, constant: -10),
//            label.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor, constant: 10),
//            label.trailingAnchor.constraint(equalTo: tooltip.trailingAnchor, constant: -10)
//        ])
//        
//        tooltip.alpha = 0
//        UIView.animate(withDuration: 0.2) {
//            tooltip.alpha = 1
//        }
//        
//        self.tooltipView = tooltip
//        
//        // 2 saniye sonra otomatik kaybolsun
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.hideTooltip()
//        }
//    }
//    
//    private func hideTooltip() {
//        UIView.animate(withDuration: 0.7, animations: {
//            self.tooltipView?.alpha = 0
//        }) { _ in
//            self.tooltipView?.removeFromSuperview()
//            self.tooltipView = nil
//        }
//    }
    private func showTooltip(from button: UIButton, text: String) {
        
        // varsa eskiyi kaldır
        tooltipView?.removeFromSuperview()
        
        let tooltip = UIView()
        tooltip.backgroundColor = .black
        tooltip.layer.cornerRadius = 12
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        tooltip.addSubview(label)
        self.view.addSubview(tooltip)
        
        NSLayoutConstraint.activate([
            tooltip.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            tooltip.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            tooltip.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
            
            label.topAnchor.constraint(equalTo: tooltip.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: tooltip.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: tooltip.trailingAnchor, constant: -10)
        ])
        
        tooltip.alpha = 0
        UIView.animate(withDuration: 0.2) {
            tooltip.alpha = 1
        }
        
        self.tooltipView = tooltip
        
        // 🔥 ÖNEMLİ: ekranın boş alanına tıklama ekliyoruz
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: self.view)
        
        // Eğer tooltip'e tıklamadıysa kapat
        if let tooltip = tooltipView, !tooltip.frame.contains(location) {
            hideTooltip()
        }
    }
    private func hideTooltip() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tooltipView?.alpha = 0
        }) { _ in
            self.tooltipView?.removeFromSuperview()
            self.tooltipView = nil
        }
    }
    
    
    
    
    
    
    @IBAction func mercuryRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "İletişimde yavaşla. Hızlı cevap vermek yerine anlamayı seç. Eski konular geri gelirse çözmek için fırsattır. Yaz, düşün, gözlemle. Netlik dışarıda değil, içeride oluşur.")
    }
    
    @IBAction func venusRetrogradeViewTapped(_ sender: UIButton) {
    }
    @IBAction func marsRetrogradeViewTapped(_ sender: UIButton) {
    }
    @IBAction func saturnRetrogradeViewTapped(_ sender: UIButton) {
    }
    @IBAction func newMoonViewTapped(_ sender: UIButton) {
    }
    @IBAction func fullMoonViewTapped(_ sender: UIButton) {
    }
    @IBAction func lunarEclipseViewTapped(_ sender: UIButton) {
    }
    
    @IBAction func solarEclipseViewTapped(_ sender: UIButton) {
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
