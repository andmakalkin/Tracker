import Foundation

@objc(DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer {
    
    // MARK: - Public Methods
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(
                String(describing: DaysValueTransformer.self)
            )
        )
    }
    
    // MARK: - Helpers
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<Weekday> else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        if let data = value as? Data {
            return try? JSONDecoder().decode(
                Set<Weekday>.self,
                from: data
            )
        }
        
        if let data = value as? NSData {
            return try? JSONDecoder().decode(
                Set<Weekday>.self,
                from: data as Data
            )
        }
        
        return nil
    }
}
