import UIKit

public struct CreatorConfiguration {
    public var backgroundColor = UIColor.grayColor()
    public var textColor = UIColor.whiteColor()
    public var fontSizeScaleY: CGFloat = 0.75
    public var fontKernScaleY: CGFloat = 0.0
    public var fontOffsetScaleX: CGFloat = 0.0
    public var fontOffsetScaleY: CGFloat = 0.0
    public var fontName = ".SFUIDisplay-Ultralight"
    public var string = "S"
    public var beforeDraw: (CGContext, CGSize) -> Void = { _, _ in }
    public var afterDraw: (CGContext, CGSize) -> Void = { _, _ in }
    
    public static func loadFont(name: String) {
        let font = NSBundle.mainBundle().URLForResource(name, withExtension: nil)!
        CTFontManagerRegisterFontsForURL(font, CTFontManagerScope.Process, nil)
    }
    
    init() {
    }
    
    init(string: String) {
        self.string = string
    }
}

public protocol Creator {
    var sizes: [CGSize] { get set }
    var config: CreatorConfiguration { get }
    
    var prefix: String { get }
    var extname: String { get }
    var scale: CGFloat { get }
    
    func suffix(size: CGSize) -> String
    func data(image: UIImage) -> NSData
}

public extension Creator {
    var fileManager: NSFileManager {
        return NSFileManager.defaultManager()
    }
    var docPath: String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    }
    var rootPath: String {
        return "\(docPath)/\(self.prefix.capitalizedString)Creator/"
    }
    
    func preview() -> [UIImage] {
        return sizes.map { create($0) }
    }
    
    func save() {
        let _ = try? fileManager.createDirectoryAtPath(
            rootPath,
            withIntermediateDirectories: false,
            attributes: nil
        )
        
        for size in sizes {
            let image = create(size)
            
            let filename = "\(prefix)\(suffix(size)).\(extname)"
            let data = self.data(image)
            
            fileManager.createFileAtPath(
                "\(rootPath)\(filename)",
                contents: data,
                attributes: nil
            )
        }
    }
    
    private func create(size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: size)
        
        let offsetX = size.width * config.fontOffsetScaleX
        let offsetY = size.height * config.fontOffsetScaleY
        
        let opaque = true
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, config.backgroundColor.CGColor)
        CGContextFillRect(context, rect)
        
        config.beforeDraw(context, size)
        
        let attributes = textAttributes(size)
        let frame = config.string.boundingRectWithSize(
            size,
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        config.string.drawInRect(
            CGRectOffset(
                rect,
                0.0 + offsetX,
                CGRectGetMidY(rect) - CGRectGetMidY(frame) + offsetY
            ),
            withAttributes: attributes
        )
        
        config.afterDraw(context, size)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func textAttributes(size: CGSize) -> [String : AnyObject] {
        let fontSize = size.height * config.fontSizeScaleY
        let fontKern = size.height * config.fontKernScaleY
        
        let defaultStyle = NSParagraphStyle.defaultParagraphStyle()
        let style = defaultStyle.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .Center
        let attributes = [
            NSFontAttributeName: UIFont(name: config.fontName, size: fontSize)!,
            NSForegroundColorAttributeName: config.textColor,
            NSParagraphStyleAttributeName: style,
            NSKernAttributeName: fontKern,
            ]
        
        return attributes
    }
}

public class IconCreator: Creator {
    public var lengths: [CGFloat] = [
        // Phone
        120.0,
        180.0,
        // Store
        1024.0,
        ]
    public var sizes: [CGSize] {
        get {
            return lengths.map { CGSizeMake($0, $0) }
        }
        set {}
    }
    public var config = CreatorConfiguration()
    
    public var prefix: String {
        return "icon"
    }
    public var extname: String {
        return "png"
    }
    public var scale: CGFloat {
        return 1.0
    }
    
    public func suffix(size: CGSize) -> String {
        return "\(Int(size.width))"
    }
    
    public func data(image: UIImage) -> NSData {
        return UIImagePNGRepresentation(image)!
    }
    
    public init() {
        
    }
}

public class LogoCreator: Creator {
    public var sizes = [CGSizeMake(200.0, 100.0)]
    public var config = CreatorConfiguration(string: "String")
    
    public var prefix: String {
        return "logo"
    }
    public var extname: String {
        return "pdf"
    }
    public var scale: CGFloat {
        return 3.0
    }
    
    public func suffix(size: CGSize) -> String {
        return "\(Int(size.width))x\(Int(size.height))"
    }
    
    public func data(image: UIImage) -> NSData {
        let data = NSMutableData()
        let consumer = CGDataConsumerCreateWithCFData(data)
        var box = CGRectMake(0, 0, image.size.width, image.size.height)
        
        let context = CGPDFContextCreate(consumer, &box, nil)
        
        CGContextBeginPage(context, &box)
        CGContextDrawImage(context, box, image.CGImage)
        CGContextEndPage(context)
        
        return data
    }
    
    public init() {
        
    }
}
