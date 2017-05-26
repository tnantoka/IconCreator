//: Playground - noun: a place where people can play

import UIKit

CreatorConfiguration.loadFont(name: "Italiana-Regular.ttf")


let iconCreator = IconCreator()
iconCreator.config.fontName = "Italiana"
iconCreator.lengths = [180.0]
iconCreator.config.string = "IC"
iconCreator.config.fontKernScaleY = -0.14
iconCreator.config.fontOffsetScaleX = -0.06
iconCreator.config.fontSizeScaleY = 0.84
iconCreator.config.backgroundColor = UIColor(red: 237.0 / 255.0, green: 237.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
iconCreator.config.textColor = UIColor(white: 0.0, alpha: 0.87)
iconCreator.config.grid = .preview
iconCreator.config.gridColor = .green

iconCreator.preview().first

iconCreator.save()
print("$ open \(iconCreator.rootPath)")


let logoCreator = LogoCreator()
logoCreator.config.fontName = iconCreator.config.fontName
logoCreator.sizes = [CGSize(width: 600.0, height: 150.0)]
logoCreator.config.string = "IconCreator".uppercased()
logoCreator.config.backgroundColor = iconCreator.config.backgroundColor
logoCreator.config.textColor = iconCreator.config.textColor
logoCreator.config.fontSizeScaleY = 0.6
logoCreator.config.grid = .none
logoCreator.preview().first

logoCreator.save()
print("$ open \(logoCreator.rootPath)")
