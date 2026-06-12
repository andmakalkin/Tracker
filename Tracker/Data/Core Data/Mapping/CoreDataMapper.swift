import UIKit

final class CoreDataMapper {
    
    // MARK: - Types
    enum CoreDataMapperError: Error {
        case trackerMappingFailed
        case categoryMappingFailed
        case trackerRecordMappingFailed
        case trackerPinMappingFailed
    }
    
    // MARK: - Public Methods
    func makeTracker(from trackerEntity: TrackerCoreData) throws -> Tracker {
        guard
            let trackerID = trackerEntity.trackerID,
            let title = trackerEntity.title,
            let emoji = trackerEntity.emoji,
            let color = trackerEntity.color as? UIColor,
            let schedule = trackerEntity.schedule as? Set<Weekday>
        else {
            throw CoreDataMapperError.trackerMappingFailed
        }
        
        return Tracker(
            id: trackerID,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func makeTrackerCategory(
        from categoryEntity: TrackerCategoryCoreData
    ) throws -> TrackerCategory {
        guard
            let categoryID = categoryEntity.categoryID,
            let title = categoryEntity.title
        else {
            throw CoreDataMapperError.categoryMappingFailed
        }
        
        let trackerEntities = categoryEntity.trackers as? Set<TrackerCoreData> ?? []
        let trackers = try trackerEntities.map { trackerEntity in
            try makeTracker(from: trackerEntity)
        }
        
        return TrackerCategory(
            categoryID: categoryID,
            title: title,
            trackers: trackers
        )
    }
    
    func makeTrackerRecord(
        from trackerRecordEntity: TrackerRecordCoreData
    ) throws -> TrackerRecord {
        guard
            let date = trackerRecordEntity.date,
            let trackerID = trackerRecordEntity.tracker?.trackerID
        else {
            throw CoreDataMapperError.trackerRecordMappingFailed
        }
        
        return TrackerRecord(
            trackerID: trackerID,
            date: date
        )
    }
    
    func makeTrackerPin(
        from trackerPinEntity: TrackerPinCoreData
    ) throws -> TrackerPin {
        guard
            let date = trackerPinEntity.date,
            let trackerID = trackerPinEntity.tracker?.trackerID
        else {
            throw CoreDataMapperError.trackerPinMappingFailed
        }
        
        return TrackerPin(
            trackerID: trackerID,
            date: date
        )
    }
}
