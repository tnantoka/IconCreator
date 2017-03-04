import UIKit

public enum CreatorGrid {
    case none, preview, previewAndSave
}

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
    public var grid = CreatorGrid.none
    public var gridColor = UIColor.lightGray
    
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
        return sizes.map { create(size: $0, previewing: true) }
    }
    
    func save() {
        let _ = try? fileManager.createDirectory(
            atPath: rootPath,
            withIntermediateDirectories: false,
            attributes: nil
        )
        
        for size in sizes {
            let image = create(size: size, previewing: false)
            
            let filename = "\(prefix)\(suffix(size: size)).\(extname)"
            let data = self.data(image: image)
            
            fileManager.createFile(
                atPath: "\(rootPath)\(filename)",
                contents: data,
                attributes: nil
            )
        }
    }
    
    private func create(size: CGSize, previewing: Bool) -> UIImage {
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

        if config.grid == .preview && previewing || config.grid == .previewAndSave {
            drawGrid(context: context, size: size)
        }

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
    
    private func drawGrid(context: CGContext, size: CGSize) {
        config.gridColor.setStroke()
        context.setLineWidth(size.height * 0.002)
        
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
 
        context.move(to: CGPoint(x: center.x, y: 0.0))
        context.addLine(to: CGPoint(x: center.x, y: size.height))

        context.move(to: CGPoint(x: 0.0, y: center.y))
        context.addLine(to: CGPoint(x: size.width, y: center.y))

        context.move(to: CGPoint(x: 0.0, y: 0.0))
        context.addLine(to: CGPoint(x: size.width, y: size.height))

        context.move(to: CGPoint(x: size.width, y: 0.0))
        context.addLine(to: CGPoint(x: 0.0, y: size.height))

        context.move(to: CGPoint(x: center.x + goldenRatio(length: center.x), y: 0.0))
        context.addLine(to: CGPoint(x: center.x + goldenRatio(length: center.x), y: size.height))

        let gr1 = goldenRatio(length: center.x)

        context.move(to: CGPoint(x: center.x - gr1, y: 0.0))
        context.addLine(to: CGPoint(x: center.x - gr1, y: size.height))

        context.move(to: CGPoint(x: 0.0, y: center.y + gr1))
        context.addLine(to: CGPoint(x: size.width, y: center.y + gr1))

        context.move(to: CGPoint(x: 0.0, y: center.y - gr1))
        context.addLine(to: CGPoint(x: size.width, y: center.y - gr1))

        context.addEllipse(in: CGRect.init(
            x: center.x - gr1,
            y: center.y - gr1,
            width: gr1 * 2.0,
            height: gr1 * 2.0
        ))

        context.addArc(center: center, radius: sqrt(pow(gr1, 2) + pow(gr1, 2)), startAngle: 0, endAngle: CGFloat(M_PI) * 2.0, clockwise: false)

        let gr2 = goldenRatio(length: goldenRatio(length: goldenRatio(length: size.width)))

        context.move(to: CGPoint(x: gr2, y: 0.0))
        context.addLine(to: CGPoint(x: gr2, y: size.height))

        context.move(to: CGPoint(x: size.width - gr2, y: 0.0))
        context.addLine(to: CGPoint(x: size.width - gr2, y: size.height))

        context.move(to: CGPoint(x: 0.0, y: gr2))
        context.addLine(to: CGPoint(x: size.width, y: gr2))

        context.move(to: CGPoint(x: 0.0, y: size.height - gr2))
        context.addLine(to: CGPoint(x: size.width, y: size.height - gr2))

        context.addEllipse(in: CGRect.init(
            x: gr2,
            y: gr2,
            width: size.width - gr2 * 2.0,
            height: size.width - gr2 * 2.0
        ))

        context.strokePath()
    }

    private func goldenRatio(length: CGFloat) -> CGFloat {
        return length / 2.618
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
