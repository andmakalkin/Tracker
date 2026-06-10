import UIKit

@objc(ColorValueTransformer)
final class ColorValueTransformer: NSSecureUnarchiveFromDataTransformer {
    
    // MARK: - Type Properties
    override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }
    
    // MARK: - Public Methods
    static func register() {
        ValueTransformer.setValueTransformer(
            ColorValueTransformer(),
            forName: NSValueTransformerName(
                String(describing: ColorValueTransformer.self)
            )
        )
    }
}
