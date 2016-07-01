//: Playground - noun: a place where people can play

import UIKit

CreatorConfiguration.loadFont("Italiana-Regular.ttf")


let iconCreator = IconCreator()
iconCreator.config.fontName = "Italiana"
iconCreator.lengths = [120.0]
iconCreator.config.string = "IC"
iconCreator.config.fontKernScaleY = -0.14
iconCreator.config.fontOffsetScaleX = -0.06
iconCreator.config.fontSizeScaleY = 0.84
iconCreator.config.backgroundColor = UIColor.whiteColor()
iconCreator.config.textColor = UIColor(white: 0.0, alpha: 0.87)

iconCreator.preview()

//creator.save()
print("$ open \(iconCreator.rootPath)")


let logoCreator = LogoCreator()
logoCreator.config.fontName = iconCreator.config.fontName
logoCreator.sizes = [CGSizeMake(600.0, 150.0)]
logoCreator.config.string = "IconCreator".uppercaseString
logoCreator.config.backgroundColor = iconCreator.config.backgroundColor
logoCreator.config.textColor = iconCreator.config.textColor
logoCreator.config.fontSizeScaleY = 0.6
logoCreator.preview()

logoCreator.save()
print("$ open \(logoCreator.rootPath)")
