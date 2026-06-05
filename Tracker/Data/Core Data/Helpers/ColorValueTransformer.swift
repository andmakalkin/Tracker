import UIKit

@objc(ColorValueTransformer)
final class ColorValueTransformer: NSSecureUnarchiveFromDataTransformer {
    static func register() {
        ValueTransformer.setValueTransformer(
            ColorValueTransformer(),
            forName: NSValueTransformerName(
                String(describing: ColorValueTransformer.self)
            )
        )
    }
    
    override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }
}
