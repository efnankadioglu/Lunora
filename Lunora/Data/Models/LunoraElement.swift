//
//  LunoraElement.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 4.05.2026.
//

import UIKit

// MARK: - Lunora Element Type

enum LunoraElement: String, CaseIterable {
    case fire = "Ateş"
    case earth = "Toprak"
    case air = "Hava"
    case water = "Su"
    case akasha = "Akasha"
    
    var emoji: String {
        switch self {
        case .fire:
            return "🔥"
        case .earth:
            return "🌍"
        case .air:
            return "🌬️"
        case .water:
            return "💧"
        case .akasha:
            return "🌌"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .air:
            return UIColor(hex: "#EAF4FF")
        case .water:
            return UIColor(hex: "#DDF7F7")
        case .fire:
            return UIColor(hex: "#FFE0E5")
        case .earth:
            return UIColor(hex: "#E8F0DD")
        case .akasha:
            return UIColor(hex: "#EEE6FF")
        }
    }
    
    var subtitleColor: UIColor {
        switch self {
        case .air:
            return UIColor(hex: "#77AEEB")
        case .water:
            return UIColor(hex: "#55B8C7")
        case .fire:
            return UIColor(hex: "#F1788C")
        case .earth:
            return UIColor(hex: "#7B9A5B")
        case .akasha:
            return UIColor(hex: "#9B7BE8")
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .air:
            return UIColor(hex: "#244A99")
        case .water:
            return UIColor(hex: "#0E6175")
        case .fire:
            return UIColor(hex: "#A92F48")
        case .earth:
            return UIColor(hex: "#3F5F2A")
        case .akasha:
            return UIColor(hex: "#4B2C91")
        }
    }
}

// MARK: - Insight State

enum ElementInsightState {
    case empty
    case firstTrace
    case highlighted
    case strengthened
}

// MARK: - Element Balance Card ViewModel

struct ElementBalanceCardViewModel {
    let title: String
    let mainText: String
    let subtitle: String
    let backgroundColor: UIColor
    let subtitleColor: UIColor
    let titleColor: UIColor
}

// MARK: - Element Card Factory

enum ElementBalanceCardFactory {
    
    static func makeEmptyCard() -> ElementBalanceCardViewModel {
        return ElementBalanceCardViewModel(
            title: "Element Dengesi",
            mainText: "Element yolculuğun başlıyor ✨",
            subtitle: "İlk programını tamamladığında burada sana özel bir iz oluşacak.",
            backgroundColor: UIColor(hex: "#F4ECF7"),
            subtitleColor: UIColor(hex: "#A47BB7"),
            titleColor: UIColor(hex: "#5B3A66")
        )
    }
    
    static func makeCard(
        element: LunoraElement,
        count: Int
    ) -> ElementBalanceCardViewModel {
        
        let state = insightState(for: count)
        
        switch state {
        case .empty:
            return makeEmptyCard()
            
        case .firstTrace:
            return ElementBalanceCardViewModel(
                title: "Element Dengesi",
                mainText: "İlk \(element.rawValue) izini bıraktın \(element.emoji)",
                subtitle: firstTraceSubtitle(for: element),
                backgroundColor: element.backgroundColor,
                subtitleColor: element.subtitleColor,
                titleColor: element.titleColor
            )
            
        case .highlighted:
            return ElementBalanceCardViewModel(
                title: "Element Dengesi",
                mainText: "Öne çıkan elementin: \(element.emoji) \(element.rawValue)",
                subtitle: highlightedSubtitle(for: element),
                backgroundColor: element.backgroundColor,
                subtitleColor: element.subtitleColor,
                titleColor: element.titleColor
            )
            
        case .strengthened:
            return ElementBalanceCardViewModel(
                title: "Element Dengesi",
                mainText: "\(element.rawValue) elementin güçleniyor \(element.emoji)",
                subtitle: strengthenedSubtitle(for: element),
                backgroundColor: element.backgroundColor,
                subtitleColor: element.subtitleColor,
                titleColor: element.titleColor
            )
        }
    }
    
    private static func insightState(for count: Int) -> ElementInsightState {
        if count <= 0 {
            return .empty
        } else if count == 1 {
            return .firstTrace
        } else if count == 2 || count == 3 {
            return .highlighted
        } else {
            return .strengthened
        }
    }
    
    private static func firstTraceSubtitle(for element: LunoraElement) -> String {
        switch element {
        case .air:
            return "Zihin, farkındalık ve bakış açısı alanında ilk adımın görünür oldu."
        case .water:
            return "Duygularını anlama ve iç sesini duyma alanında ilk adımın görünür oldu."
        case .fire:
            return "Cesaret, motivasyon ve harekete geçme alanında ilk adımın görünür oldu."
        case .earth:
            return "Düzen, güven ve köklenme alanında ilk adımın görünür oldu."
        case .akasha:
            return "İçsel anlam, sezgisel farkındalık ve ruhsal derinlik alanında ilk adımın görünür oldu."
        }
    }
    
    private static func highlightedSubtitle(for element: LunoraElement) -> String {
        switch element {
        case .air:
            return "Düşünce, iletişim ve farkındalık alanında daha net bir yön oluşuyor."
        case .water:
            return "Duygusal farkındalık, sezgi ve içe dönüş alanında derinleşiyorsun."
        case .fire:
            return "Cesaret, özgüven ve aksiyon alma alanında daha güçlü bir yön oluşuyor."
        case .earth:
            return "Rutin, istikrar ve içsel güven alanında daha sağlam bir yön oluşuyor."
        case .akasha:
            return "İçsel rehberlik, anlam arayışı ve ruhsal farkındalık alanında derinleşiyorsun."
        }
    }
    
    private static func strengthenedSubtitle(for element: LunoraElement) -> String {
        switch element {
        case .air:
            return "Zihinsel açıklık, ifade gücü ve yeni bakış açıları yolculuğunda belirginleşmiş."
        case .water:
            return "Duygularını tanıma, sezgine güvenme ve kendine şefkatle yaklaşma yolculuğun belirginleşmiş."
        case .fire:
            return "İrade, motivasyon ve kendini ortaya koyma enerjin yolculuğunda belirginleşmiş."
        case .earth:
            return "Düzen kurma, bedenle bağını güçlendirme ve istikrar yaratma yolculuğun belirginleşmiş."
        case .akasha:
            return "Sezgisel bilgelik, içsel anlam ve bütünlük hissi yolculuğunda belirginleşmiş."
        }
    }
}

// MARK: - Element Parser

enum LunoraElementParser {
    
    static func parseElements(from text: String) -> [LunoraElement] {
        let normalizedText = normalize(text)
        
        var elements: [LunoraElement] = []
        
        if normalizedText.contains("ates") || normalizedText.contains("fire") {
            elements.append(.fire)
        }
        
        if normalizedText.contains("toprak") || normalizedText.contains("earth") {
            elements.append(.earth)
        }
        
        if normalizedText.contains("hava") || normalizedText.contains("air") {
            elements.append(.air)
        }
        
        if normalizedText.contains("su") || normalizedText.contains("water") {
            elements.append(.water)
        }
        
        if normalizedText.contains("akasha") || normalizedText.contains("akash") {
            elements.append(.akasha)
        }
        
        return Array(Set(elements))
    }
    
    private static func normalize(_ text: String) -> String {
        return text
            .lowercased(with: Locale(identifier: "tr_TR"))
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ğ", with: "g")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "ş", with: "s")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ç", with: "c")
    }
}

// MARK: - UIColor Hex Helper

extension UIColor {
    
    convenience init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHex = cleanHex.replacingOccurrences(of: "#", with: "")
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
