import Foundation

final class Storage {
    
    // MARK: - Type Properties
    static let shared = Storage()
    static let categoriesDidChangeNotification = Notification.Name("CategoriesDidChange")
    static let completedTrackersDidChangeNotification = Notification.Name("CompletedTrackersDidChange")
    
    // MARK: - Data
    private(set) var categories = [TrackerCategory]()
    
    private(set) var completedTrackers = [TrackerRecord]() {
        didSet {
            NotificationCenter.default.post(
                name: Storage.completedTrackersDidChangeNotification,
                object: self
            )
        }
    }
    
    // MARK: - Initialization
    private init() {
        //addTestCase()
    }
    
    // MARK: - Public Methods
    func addCategoryIfNeeded(title: String) {
        guard !categories.contains(
            where: { $0.title == title }
        ) else {
            return
        }
        
        let category = TrackerCategory(
            title: title,
            trackers: []
        )
        
        categories.append(category)
        
        print("""
        
        ✅ [Storage] addCategoryIfNeeded: добавлена новая категория
           title: \(title)
        """)
    }
    
    func addTracker(_ tracker: Tracker, categoryTitle: String) {
        addCategoryIfNeeded(title: categoryTitle)
        
        guard let index = categories.firstIndex(
            where: {$0.title == categoryTitle}
        ) else {
            print("\n❌ [Storage] addTracker: не удалось добавить трекер, категория не найдена")
            return
        }
        
        var newTrackers = categories[index].trackers
        newTrackers.append(tracker)
        
        let newCategory = TrackerCategory(
            title: categories[index].title,
            trackers: newTrackers
        )
        
        categories[index] = newCategory
        
        print("""
        
        ✅ [Storage] addTracker: добавлен новый трекер в категорию \(categoryTitle)
           id: \(tracker.id)
           title: \(tracker.title)
           color: \(tracker.color)
           emoji: \(tracker.emoji)
           schedule: \(convertScheduleToString(tracker.schedule))
        """)
        
        NotificationCenter.default.post(
            name: Storage.categoriesDidChangeNotification,
            object: self
        )
    }
    
    func addCompletedTracker(_ completedTracker: TrackerRecord) {
        var newCompletedTrackers = completedTrackers
        newCompletedTrackers.append(completedTracker)
        
        print("""
        
        ✅ [Storage] addCompletedTracker: добавлена запись о выполнении трекера
           id: \(completedTracker.id), date: \(completedTracker.date)
        """)
        
        completedTrackers = newCompletedTrackers
    }
    
    func removeCompletedTracker(_ completedTracker: TrackerRecord) {
        var newCompletedTrackers = completedTrackers
        
        guard let index = newCompletedTrackers.firstIndex(of: completedTracker) else {
            return
        }
        
        newCompletedTrackers.remove(at: index)
        
        print("""
        
        ✅ [Storage] removeCompletedTracker: удалена запись о выполнении трекера
           id: \(completedTracker.id), date: \(completedTracker.date)
        """)
        
        completedTrackers = newCompletedTrackers
    }
    
    // MARK: - Private Methods
    private func addTestCase() {
        let category1 = "Дела по дому"
        let category2 = "Очень важные дела"
        let category3 = "Менее важные дела"
        
        let tracker1 = Tracker(
            title: "Убраться в комнате",
            color: TrackerColor.randomColor(),
            emoji: TrackerEmoji.randomEmoji(),
            schedule: Schedule(selectedDays: [.sunday])
        )
        
        let tracker2 = Tracker(
            title: "Полить цветы",
            color: TrackerColor.randomColor(),
            emoji: TrackerEmoji.randomEmoji(),
            schedule: Schedule(selectedDays: [.sunday])
        )
        
        let tracker3 = Tracker(
            title: "Помыть посуду",
            color: TrackerColor.randomColor(),
            emoji: TrackerEmoji.randomEmoji(),
            schedule: Schedule(selectedDays: [.friday, .sunday, .saturday, .tuesday])
        )
        
        let tracker4 = Tracker(
            title: "Вынести мусор",
            color: TrackerColor.randomColor(),
            emoji: TrackerEmoji.randomEmoji(),
            schedule: Schedule(selectedDays: [.thursday, .sunday, .saturday, .tuesday])
        )
        
        let tracker5 = Tracker(
            title: "Погулять с собакой",
            color: TrackerColor.randomColor(),
            emoji: TrackerEmoji.randomEmoji(),
            schedule: Schedule(selectedDays: [.monday, .tuesday, .thursday,
                                              .friday, .saturday, .sunday])
        )
        
        let tracker6 = Tracker(
            title: "Посмотреть новый фильм Соррентино",
            color: TrackerColor.randomColor(),
            emoji: TrackerEmoji.randomEmoji(),
            schedule: nil
        )
        
        let tracker7 = Tracker(
            title: "Постирать спортивную форму",
            color: TrackerColor.randomColor(),
            emoji: TrackerEmoji.randomEmoji(),
            schedule: Schedule(selectedDays: [.monday, .sunday])
        )
        
        addTracker(tracker1, categoryTitle: category1)
        addTracker(tracker2, categoryTitle: category1)
        addTracker(tracker3, categoryTitle: category1)
        addTracker(tracker4, categoryTitle: category2)
        addTracker(tracker5, categoryTitle: category2)
        addTracker(tracker6, categoryTitle: category3)
        addTracker(tracker7, categoryTitle: category3)
    }
    
    // MARK: - Helpers
    private func convertScheduleToString(_ schedule: Schedule?) -> String {
        guard
            let schedule,
            !schedule.selectedDays.isEmpty
        else {
            return "nil"
        }
        
        let week = Weekday.allCases
        var sortedScheduleString = [String]()
        
        week.forEach {
            if schedule.selectedDays.contains($0) {
                sortedScheduleString.append($0.rawValue)
            }
        }
        
        return sortedScheduleString.joined(separator: ", ")
    }
}
