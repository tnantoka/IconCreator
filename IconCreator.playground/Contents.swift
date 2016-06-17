//: Playground - noun: a place where people can play

import UIKit

// MARK: - Define Utilities

struct CreatorConfiguration {
    var backgroundColor = UIColor.grayColor()
    var textColor = UIColor.whiteColor()
    var fontSizeScaleY: CGFloat = 0.75
    var fontKernScaleY: CGFloat = 0.0
    var fontOffsetScaleX: CGFloat = 0.0
    var fontOffsetScaleY: CGFloat = 0.0
    var fontName = ".SFUIDisplay-Ultralight"
    var string = "S"
    var beforeDraw: (CGContext, CGSize) -> Void = { _, _ in }
    var afterDraw: (CGContext, CGSize) -> Void = { _, _ in }

    static func loadFont(name: String) {
        let font = NSBundle.mainBundle().URLForResource(name, withExtension: nil)!
        CTFontManagerRegisterFontsForURL(font, CTFontManagerScope.Process, nil)
    }

    init() {
    }

    init(string: String) {
        self.string = string
    }
}

protocol Creator {
    var sizes: [CGSize] { get set }
    var prefix: String { get }
    var config: CreatorConfiguration { get }
    var extname: String { get }
    var scale: CGFloat { get }

    func suffix(size: CGSize) -> String
    func data(image: UIImage) -> NSData
}

extension Creator {
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
        try? fileManager.createDirectoryAtPath(
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

class IconCreator: Creator {
    var prefix: String {
        return "icon"
    }
    var extname: String {
        return "png"
    }
    var scale: CGFloat {
        return 1.0
    }

    var lengths: [CGFloat] = [
        // Phone
        120.0,
        180.0,
        // Store
        1024.0,
    ]
    var sizes: [CGSize] {
        get {
            return lengths.map { CGSizeMake($0, $0) }
        }
        set {}
    }

    var config = CreatorConfiguration()

    func suffix(size: CGSize) -> String {
        return "\(Int(size.width))"
    }

    func data(image: UIImage) -> NSData {
        return UIImagePNGRepresentation(image)!
    }
}

class LogoCreator: Creator {
    var prefix: String {
        return "logo"
    }
    var extname: String {
        return "pdf"
    }
    var scale: CGFloat {
        return 3.0
    }

    var sizes = [CGSizeMake(200.0, 100.0)]

    var config = CreatorConfiguration(string: "String")

    func suffix(size: CGSize) -> String {
        return "\(Int(size.width))x\(Int(size.height))"
    }

    func data(image: UIImage) -> NSData {
        let data = NSMutableData()
        let consumer = CGDataConsumerCreateWithCFData(data)
        var box = CGRectMake(0, 0, image.size.width, image.size.height)

        let context = CGPDFContextCreate(consumer, &box, nil)

        CGContextBeginPage(context, &box)
        CGContextDrawImage(context, box, image.CGImage)
        CGContextEndPage(context)

        return data
    }
}

// MARK: - Create Icons

let creator = IconCreator()
creator.preview()

creator.save()
print("$ open \(creator.rootPath)")

let creator2 = IconCreator()
CreatorConfiguration.loadFont("Pacifico.ttf")
creator2.config.fontName = "Pacifico"
creator2.config.fontSizeScaleY = 0.6
creator2.preview()

let creator3 = IconCreator()
CreatorConfiguration.loadFont("FontAwesome.otf")
creator3.config.fontName = "FontAwesome"
creator3.config.string = "\u{f09b}"
creator3.preview()

let creator4 = IconCreator()
CreatorConfiguration.loadFont("devicons.ttf")
creator4.config.fontName = "icomoon"
creator4.config.string = "\u{e655}"
creator4.config.fontSizeScaleY = 0.9
creator4.config.backgroundColor = UIColor.orangeColor()
creator4.lengths = [150.0]
creator4.preview()

let creator5 = IconCreator()
creator5.config.string = "qq"
creator5.config.fontSizeScaleY = 0.6
creator5.config.fontKernScaleY = -0.07
creator5.config.fontOffsetScaleX = -0.04
creator5.config.fontOffsetScaleY = -0.08
creator5.preview()

let creator6 = IconCreator()
creator6.config.beforeDraw = { context, size in
    CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor)

    CGContextBeginPath(context)
    CGContextMoveToPoint(context, size.width * 0.5, size.width * 0.2)
    CGContextAddLineToPoint(context, size.width * 0.2, size.width * 0.8)
    CGContextAddLineToPoint(context, size.width * 0.8, size.width * 0.8)
    CGContextClosePath(context)

    CGContextFillPath(context)
}
creator6.config.afterDraw = { context, size in
    CGContextSetFillColorWithColor(context, UIColor.orangeColor().CGColor)

    CGContextBeginPath(context)
    CGContextMoveToPoint(context, size.width * 0.5, size.width * 0.35)
    CGContextAddLineToPoint(context, size.width * 0.325, size.width * 0.725)
    CGContextAddLineToPoint(context, size.width * 0.675, size.width * 0.725)
    CGContextClosePath(context)

    CGContextFillPath(context)
}
creator6.preview()

// MARK: - Create Logo

let logoCreator = LogoCreator()
logoCreator.preview()

logoCreator.save()
print("$ open \(logoCreator.rootPath)")
