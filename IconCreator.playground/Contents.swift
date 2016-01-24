//: Playground - noun: a place where people can play

import UIKit

class IconCreator {
    let fileManager = NSFileManager.defaultManager()
    let docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

    var rootPath: String {
        return "\(docPath)/IconCreator/"
    }

    var backgroundColor = UIColor.grayColor()
    var textColor = UIColor.whiteColor()
    var lengths: [CGFloat] = [
        // Phone
        120.0,
        180.0,
        // Store
        1024.0,
    ]
    var fontSizeScale: CGFloat = 0.75
    var fontKernScale: CGFloat = 0.0
    var fontOffsetXScale: CGFloat = 0.0
    var fontOffsetYScale: CGFloat = 0.0
    var fontName = ".SFUIDisplay-Ultralight"
    var string = "S"

    init() {
        try? fileManager.createDirectoryAtPath(
            rootPath,
            withIntermediateDirectories: false,
            attributes: nil
        )
    }

    func preview() -> [UIImage] {
        return lengths.map { create($0) }
    }

    func save() {
        for length in lengths {
            let image = create(length)

            let filename = "icon\(Int(length)).png"
            let data = UIImagePNGRepresentation(image)!

            fileManager.createFileAtPath(
                "\(rootPath)\(filename)",
                contents: data,
                attributes: nil
            )
        }
    }

    private func create(length: CGFloat) -> UIImage {
        let size = CGSizeMake(length, length)
        let rect = CGRectMake(0.0, 0.0, length, length)

        let offsetX = length * fontOffsetXScale
        let offsetY = length * fontOffsetYScale

        let opaque = true
        let scale: CGFloat = 1.0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)

        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, rect)

        let attributes = textAttributes(length)
        let frame = string.boundingRectWithSize(
            size,
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            attributes: attributes,
            context: nil
        )

        string.drawInRect(
            CGRectOffset(
                rect,
                0.0 + offsetX,
                CGRectGetMidY(rect) - CGRectGetMidY(frame) + offsetY
            ),
            withAttributes: attributes
        )

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }

    private func textAttributes(length: CGFloat) -> [String : AnyObject] {
        let fontSize = length * fontSizeScale
        let fontKern = length * fontKernScale

        let defaultStyle = NSParagraphStyle.defaultParagraphStyle()
        let style = defaultStyle.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .Center
        let attributes = [
            NSFontAttributeName: UIFont(name: fontName, size: fontSize)!,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: style,
            NSKernAttributeName: fontKern,
        ]

        return attributes
    }

    class func loadFont(name: String) {
        let font = NSBundle.mainBundle().URLForResource(name, withExtension: nil)!
        CTFontManagerRegisterFontsForURL(font, CTFontManagerScope.Process, nil)
    }
}

let creator = IconCreator()
creator.preview()

creator.save()
print("$ open \(creator.rootPath)")

let creator2 = IconCreator()
IconCreator.loadFont("Pacifico.ttf")
creator2.fontName = "Pacifico"
creator2.fontSizeScale = 0.6
creator2.preview()

let creator3 = IconCreator()
IconCreator.loadFont("FontAwesome.otf")
creator3.fontName = "FontAwesome"
creator3.string = "\u{f09b}"
creator3.preview()

let creator4 = IconCreator()
IconCreator.loadFont("devicons.ttf")
creator4.fontName = "icomoon"
creator4.string = "\u{e655}"
creator4.fontSizeScale = 0.9
creator4.backgroundColor = UIColor.orangeColor()
creator4.lengths = [150.0]
creator4.preview()

let creator5 = IconCreator()
creator5.string = "qq"
creator5.fontSizeScale = 0.6
creator5.fontKernScale = -0.07
creator5.fontOffsetXScale = -0.04
creator5.fontOffsetYScale = -0.08
creator5.preview()

