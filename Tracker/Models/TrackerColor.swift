import UIKit

struct TrackerColor {
    static let colors: [UIColor] = (1...18).map {
        UIColor(named: "YP Color selection " + String($0)) ?? .ypRed
    }
    
    static func randomColor() -> UIColor {
        colors.randomElement() ?? .ypRed
    }
}
