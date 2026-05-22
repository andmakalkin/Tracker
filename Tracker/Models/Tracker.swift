import UIKit

struct Tracker: Equatable  {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Schedule?
    
    init(
        id: UUID = UUID(),
        title: String,
        color: UIColor,
        emoji: String,
        schedule: Schedule?
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
