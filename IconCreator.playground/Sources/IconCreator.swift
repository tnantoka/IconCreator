import UIKit

public struct CreatorConfiguration {
    public var backgroundColor = UIColor.gray
    public var textColor = UIColor.white
    public var fontSizeScaleY: CGFloat = 0.75
    public var fontKernScaleY: CGFloat = 0.0
    public var fontOffsetScaleX: CGFloat = 0.0
    public var fontOffsetScaleY: CGFloat = 0.0
    public var fontName = ".SFUIDisplay-Ultralight"
    public var string = "S"
    public var beforeDraw: (CGContext, CGSize) -> Void = { _, _ in }
    public var afterDraw: (CGContext, CGSize) -> Void = { _, _ in }
    
    public static func loadFont(name: String) {
        let font = Bundle.main.url(forResource: name, withExtension: nil)!
        CTFontManagerRegisterFontsForURL(font as CFURL, CTFontManagerScope.process, nil)
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
    func data(image: UIImage) -> Data
}

public extension Creator {
    var fileManager: FileManager {
        return FileManager.default
    }
    var docPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    var rootPath: String {
        return "\(docPath)/\(self.prefix.capitalized)Creator/"
    }
    
    func preview() -> [UIImage] {
        return sizes.map { create(size: $0) }
    }
    
    func save() {
        let _ = try? fileManager.createDirectory(
            atPath: rootPath,
            withIntermediateDirectories: false,
            attributes: nil
        )
        
        for size in sizes {
            let image = create(size: size)
            
            let filename = "\(prefix)\(suffix(size: size)).\(extname)"
            let data = self.data(image: image)
            
            fileManager.createFile(
                atPath: "\(rootPath)\(filename)",
                contents: data,
                attributes: nil
            )
        }
    }
    
    private func create(size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        let offsetX = size.width * config.fontOffsetScaleX
        let offsetY = size.height * config.fontOffsetScaleY
        
        let opaque = true
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(config.backgroundColor.cgColor)
        context.fill(rect)
        
        config.beforeDraw(context, size)
        
        let attributes = textAttributes(size: size)
        let frame = config.string.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        config.string.draw(
            in: rect.offsetBy(
                dx: 0.0 + offsetX,
                dy: rect.midY - frame.midY + offsetY
            ),
            withAttributes: attributes
        )
        
        config.afterDraw(context, size)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    private func textAttributes(size: CGSize) -> [String : Any] {
        let fontSize = size.height * config.fontSizeScaleY
        let fontKern = size.height * config.fontKernScaleY
        
        let defaultStyle = NSParagraphStyle.default
        let style = defaultStyle.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .center
        let attributes: [String : Any] = [
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
            return lengths.map { CGSize(width: $0, height: $0) }
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
    
    public func data(image: UIImage) -> Data {
        return UIImagePNGRepresentation(image)!
    }
    
    public init() {
        
    }
}

public class LogoCreator: Creator {
    public var sizes = [CGSize(width: 200.0, height: 100.0)]
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
    
    public func data(image: UIImage) -> Data {
        let data = NSMutableData()
        let consumer = CGDataConsumer(data: data)
        var box = CGRect(origin: .zero, size: image.size)

        let context = CGContext(consumer: consumer!, mediaBox: &box, nil)!
        
        context.beginPDFPage(nil)
        context.draw(image.cgImage!, in: box)
        context.endPDFPage()
        context.closePDF()
        
        return data as Data
    }
    
    public init() {
        
    }
}
