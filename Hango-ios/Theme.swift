import UIKit

enum AppTheme {
    // Hanji-inspired neutrals + dancheong accents
    struct Colors {
        // Backgrounds
        static let hanjiBackground = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 20/255, green: 20/255, blue: 18/255, alpha: 1.0)   // deep ink paper
            : UIColor(red: 250/255, green: 247/255, blue: 238/255, alpha: 1.0) // hanji ivory
        }
        static let surface = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 32/255, green: 32/255, blue: 30/255, alpha: 1.0)
            : UIColor(red: 255/255, green: 252/255, blue: 244/255, alpha: 1.0)
        }
        static let ink = UIColor { _ in UIColor(red: 26/255, green: 26/255, blue: 28/255, alpha: 1.0) }
        static let inkOnDark = UIColor.white

        // Accents (dancheong palette)
        static let danGreen = UIColor(red: 0/255, green: 143/255, blue: 119/255, alpha: 1.0)   // 청록
        static let danRed   = UIColor(red: 190/255, green: 47/255, blue: 45/255, alpha: 1.0)   // 단청 홍
        static let danBlue  = UIColor(red: 28/255, green: 98/255, blue: 168/255, alpha: 1.0)   // 군청
        static let danGold  = UIColor(red: 212/255, green: 175/255, blue: 55/255, alpha: 1.0)  // 금장
        static let danJade  = UIColor(red: 108/255, green: 174/255, blue: 124/255, alpha: 1.0) // 옥색

        // Lines / borders
        static let softLine = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.08)
            : UIColor(white: 0.0, alpha: 0.12)
        }

        // Feedback
        static let success = UIColor(red: 72/255, green: 156/255, blue: 89/255, alpha: 1.0)
        static let failure = UIColor(red: 196/255, green: 64/255, blue: 64/255, alpha: 1.0)
        static let blocked = UIColor(red: 230/255, green: 154/255, blue: 60/255, alpha: 1.0) // amber
    }

    struct Fonts {
        // Prefer system to avoid bundling; use rounded for friendlier learning tone
        static func displayLarge() -> UIFont {
            UIFont.systemFont(ofSize: 28, weight: .semibold)
        }
        static func tileSymbol() -> UIFont {
            UIFont.systemFont(ofSize: 28, weight: .bold)
        }
        static func body() -> UIFont {
            UIFont.systemFont(ofSize: 16, weight: .regular)
        }
        static func labelSmall() -> UIFont {
            UIFont.systemFont(ofSize: 13, weight: .medium)
        }
    }

    struct Metrics {
        static let cornerRadius: CGFloat = 14
        static let tileRadius: CGFloat = 12
        static let tileBorderWidth: CGFloat = 1
        static let shadowRadius: CGFloat = 10
        static let shadowOpacity: Float = 0.12
        static let shadowYOffset: CGFloat = 6
    }

    static func applyNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.hanjiBackground
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.ink,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: Colors.ink,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        UINavigationBar.appearance().tintColor = Colors.danBlue
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
