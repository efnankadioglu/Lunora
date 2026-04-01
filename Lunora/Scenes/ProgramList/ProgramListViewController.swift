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
    
    private func showTooltip(from button: UIButton, text: String) {
        
        // varsa eskiyi kaldır
        tooltipView?.removeFromSuperview()
        
        // ?? SHADOW CONTAINER (YENİ)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.layer.shadowColor = UIColor.black.cgColor // ??
        containerView.layer.shadowOpacity = 0.1                  // ??
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4) // ??
        containerView.layer.shadowRadius = 8                     // ??
        
        // ?? TOOLTIP (ARTIK İÇ VIEW)
        let tooltip = UIView()
        tooltip.backgroundColor = tooltipColor(for: button)
        tooltip.layer.cornerRadius = 12
        tooltip.clipsToBounds = true // ?? önemli!
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        tooltip.addSubview(label)
        containerView.addSubview(tooltip) // ?? tooltip artık container içine
        
        self.view.addSubview(containerView) // ?? tooltip yerine container ekledik
        
        NSLayoutConstraint.activate([
            
            // ?? container konumu
            containerView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            containerView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
            
            // ?? tooltip container'a tam oturuyor
            tooltip.topAnchor.constraint(equalTo: containerView.topAnchor),
            tooltip.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            tooltip.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tooltip.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // label constraints (aynı)
            label.topAnchor.constraint(equalTo: tooltip.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: tooltip.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: tooltip.trailingAnchor, constant: -10)
        ])
        
        containerView.alpha = 0 // ?? artık tooltip değil container animate ediliyor
        UIView.animate(withDuration: 0.2) {
            containerView.alpha = 1
        }
        
        tooltipView = containerView // ?? referans güncellendi
    
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
    private func tooltipColor(for button: UIButton) -> UIColor {
        switch button {
            
        case mercuryRetrogradeView:
            return UIColor.astroMercuryColor
            
        case venusRetrogradeView:
            return UIColor.astroVenusColor
            
        case marsRetrogradeView:
            return UIColor.astroMarsColor
            
        case saturnRetrogradeView:
            return UIColor.astroSaturnColor
            
        case newMoonView:
            return UIColor.astroNewMoonColor
            
        case fullMoonView:
            return UIColor.astroFullMoonColor
            
        case lunarEclipseView:
            return UIColor.astroLunarEclipseColor
            
        case solarEclipseView:
            return UIColor.astroSolarEclipseColor
            
        default:
            return .black
        }
    }
    @IBAction func mercuryRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "İletişimde yavaşla. Hızlı cevap vermek yerine anlamayı seç. Eski konular geri gelirse çözmek için fırsattır. Yaz, düşün, gözlemle. Netlik dışarıda değil, içeride oluşur.")
        
    }
    @IBAction func venusRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Kalbine dön. İlişkilerde neyi hak ettiğini fark et. Sevgi verirken kendini unutup unutmadığını gözlemle. Eski duygular çıkıyorsa bastırma, dönüştür.")
    }
    @IBAction func marsRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Harekete geçmeden önce niyetini sorgula. Öfke ve sabırsızlık aslında bastırılmış enerjidir. Gücünü dışarıya değil, iç disipline yönlendir.")
    }
    @IBAction func saturnRetrogradeViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Hayat sana aynayı tutar. Kaçtığın sorumluluklar görünür olur. Disiplin kur, küçük ama sürdürülebilir adımlar at. Sabır burada en büyük dönüşüm aracıdır.")
    }
    @IBAction func newMoonViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Yeni bir niyet ek. Küçük bir başlangıç yap. Her şey hemen olmak zorunda değil. Tohum ektiğini hatırla, sürece güven.")
    }
    @IBAction func fullMoonViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Tamamlanma ve bırakma zamanı. Artık sana hizmet etmeyenleri sevgiyle bırak. Duygular yoğunlaşır; bastırmak yerine fark et ve serbest bırak.")
    }
    @IBAction func lunarEclipseViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Duygusal farkındalık artar. Ani fark edişler olabilir. Kontrol etmeye çalışma, sadece gözlemle. İçsel dönüşüm derinleşir.")
    }
    
    @IBAction func solarEclipseViewTapped(_ sender: UIButton) {
        showTooltip(from: sender, text: "Hayat yön değiştirir. Yeni bir kapı açılır. Direnmek yerine akışa güven. Kim olduğunu yeniden tanımlama fırsatıdır.")
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
extension UIColor {
    
    static let astroMercuryColor = UIColor(red: 170/255, green: 195/255, blue: 185/255, alpha: 0.8)
    
    static let astroVenusColor = UIColor(red: 236/255, green: 191/255, blue: 234/255, alpha: 0.8)
    
    static let astroMarsColor = UIColor(red: 240/255, green: 115/255, blue: 115/255, alpha: 0.8)
    
    static let astroSaturnColor = UIColor(red: 158/255, green: 112/255, blue: 112/255, alpha: 0.8)
    
    static let astroNewMoonColor = UIColor(red: 188/255, green: 131/255, blue: 252/255,alpha: 0.8)
    
    static let astroFullMoonColor = UIColor(red: 222/255, green: 195/255, blue: 100/255, alpha: 0.8)
    
    static let astroLunarEclipseColor = UIColor(red: 98/255, green: 85/255, blue: 163/255, alpha: 0.8)
    
    static let astroSolarEclipseColor = UIColor(red: 227/255, green: 121/255, blue: 86/255, alpha: 0.8)
}
