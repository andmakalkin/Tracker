import Foundation

final class TrackersFilteringService {
    
    // MARK: - Public Methods
    func makeCategoriesToShow(
        from categories: [TrackerCategory],
        completedTrackers: [TrackerRecord],
        selectedDate: Date
    ) -> [TrackerCategory] {
        let selectedWeekday = convertDateToWeekday(selectedDate)
        let completedTrackerIdsOnSelectedDate = makeCompletedTrackerIDs(
            from: completedTrackers,
            selectedDate: selectedDate
        )
        
        let completedDaysCountByTrackerId = makeCompletedDaysCountByTrackerID(
            from: completedTrackers
        )
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                shouldShowTracker(
                    tracker,
                    selectedWeekday: selectedWeekday,
                    completedTrackerIDsOnSelectedDate: completedTrackerIdsOnSelectedDate,
                    completedDaysCountByTrackerID: completedDaysCountByTrackerId
                )
            }
            
            guard !filteredTrackers.isEmpty else {
                return nil
            }
            
            return TrackerCategory(
                categoryID: category.categoryID,
                title: category.title,
                trackers: filteredTrackers
            )
        }
    }
    
    func makeCompletedTrackerIDs(
        from completedTrackers: [TrackerRecord],
        selectedDate: Date
    ) -> Set<UUID> {
        Set(
            completedTrackers
                .filter { $0.date == selectedDate }
                .map { $0.trackerID }
        )
    }
    
    func makeCompletedDaysCountByTrackerID(
        from completedTrackers: [TrackerRecord]
    ) -> [UUID: Int] {
        Dictionary(
            grouping: completedTrackers,
            by: { $0.trackerID }
        ).mapValues { $0.count }
    }
    
    // MARK: - Private Methods
    private func shouldShowTracker(
        _ tracker: Tracker,
        selectedWeekday: Weekday,
        completedTrackerIDsOnSelectedDate: Set<UUID>,
        completedDaysCountByTrackerID: [UUID: Int]
    ) -> Bool {
        let schedule = tracker.schedule
        
        if schedule.isEmpty {
            // Нерегулярное событие
            return completedTrackerIDsOnSelectedDate.contains(tracker.id)
            || completedDaysCountByTrackerID[tracker.id] == nil
        } else {
            // Регулярное событие
            return schedule.contains(selectedWeekday)
        }
    }
    
    // MARK: - Helpers
    private func convertDateToWeekday(_ date: Date) -> Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        
        switch weekdayNumber {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return .monday
        }
    }
}
