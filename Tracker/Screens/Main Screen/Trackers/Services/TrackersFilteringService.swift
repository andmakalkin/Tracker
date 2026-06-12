import Foundation

final class TrackersFilteringService {
    
    // MARK: - Public Methods
    func makeSectionsToShow(
        from categories: [TrackerCategory],
        completedTrackers: [TrackerRecord],
        pinnedTrackers: [TrackerPin],
        selectedDate: Date,
        searchText: String
    ) -> [TrackerSection] {
        let selectedWeekday = convertDateToWeekday(selectedDate)
        
        let completedTrackerIDsOnSelectedDate = makeCompletedTrackerIDs(
            from: completedTrackers,
            selectedDate: selectedDate
        )
        
        let completedDaysCountByTrackerID = makeCompletedDaysCountByTrackerID(
            from: completedTrackers
        )
        
        let pinnedTrackerIDsOnSelectedDate = makePinnedTrackerIDs(
            from: pinnedTrackers,
            selectedDate: selectedDate
        )
        
        let visibleCategories = makeVisibleCategories(
            from: categories,
            selectedWeekday: selectedWeekday,
            completedTrackerIDsOnSelectedDate: completedTrackerIDsOnSelectedDate,
            completedDaysCountByTrackerID: completedDaysCountByTrackerID,
            searchText: searchText
        )
        
        let pinnedTrackersToShow = makePinnedTrackersToShow(
            from: visibleCategories,
            pinnedTrackerIDsOnSelectedDate: pinnedTrackerIDsOnSelectedDate
        )
        
        let categorySections = makeCategorySectionsToShow(
            from: visibleCategories,
            pinnedTrackerIDsOnSelectedDate: pinnedTrackerIDsOnSelectedDate
        )
        
        if pinnedTrackersToShow.isEmpty {
            return categorySections
        }
        
        let pinnedSection = TrackerSection(
            title: "Закреплённые",
            trackers: pinnedTrackersToShow,
            kind: .pinned
        )
        
        return [pinnedSection] + categorySections
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
    
    func makePinnedTrackerIDs(
        from pinnedTrackers: [TrackerPin],
        selectedDate: Date
    ) -> Set<UUID> {
        Set(
            pinnedTrackers
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
    
    // MARK: - Helpers
    private func makeVisibleCategories(
        from categories: [TrackerCategory],
        selectedWeekday: Weekday,
        completedTrackerIDsOnSelectedDate: Set<UUID>,
        completedDaysCountByTrackerID: [UUID: Int],
        searchText: String
    ) -> [TrackerCategory] {
        categories.compactMap { category in
            let filteredTrackers = category.trackers
                .filter { tracker in
                    shouldShowTracker(
                        tracker,
                        selectedWeekday: selectedWeekday,
                        completedTrackerIDsOnSelectedDate: completedTrackerIDsOnSelectedDate,
                        completedDaysCountByTrackerID: completedDaysCountByTrackerID
                    ) && matchesSearchText(
                        tracker,
                        searchText: searchText
                    )
                }
                .sorted {
                    compareTrackersByTitleAndID($0, $1)
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
    
    private func makePinnedTrackersToShow(
        from visibleCategories: [TrackerCategory],
        pinnedTrackerIDsOnSelectedDate: Set<UUID>
    ) -> [Tracker] {
        visibleCategories
            .flatMap { $0.trackers }
            .filter { pinnedTrackerIDsOnSelectedDate.contains($0.id) }
            .sorted {
                compareTrackersByTitleAndID($0, $1)
            }
    }
    
    private func makeCategorySectionsToShow(
        from visibleCategories: [TrackerCategory],
        pinnedTrackerIDsOnSelectedDate: Set<UUID>
    ) -> [TrackerSection] {
        visibleCategories.compactMap { category in
            let trackers = category.trackers.filter {
                !pinnedTrackerIDsOnSelectedDate.contains($0.id)
            }
            
            guard !trackers.isEmpty else {
                return nil
            }
            
            return TrackerSection(
                title: category.title,
                trackers: trackers,
                kind: .category(id: category.categoryID)
            )
        }
    }
    
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
    
    private func compareTrackersByTitleAndID(
        _ lhs: Tracker,
        _ rhs: Tracker
    ) -> Bool {
        let titleComparison = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        
        if titleComparison == .orderedSame {
            return lhs.id.uuidString < rhs.id.uuidString
        }
        
        return titleComparison == .orderedAscending
    }
    
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
    
    private func matchesSearchText(
        _ tracker: Tracker,
        searchText: String
    ) -> Bool {
        let trimmedSearchText = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedSearchText.isEmpty else {
            return true
        }
        
        return tracker.title.localizedCaseInsensitiveContains(trimmedSearchText)
    }
}
