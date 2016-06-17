//: Playground - noun: a place where people can play

import UIKit

CreatorConfiguration.loadFont(name: "Megrim.ttf")


let iconCreator = IconCreator()
iconCreator.config.fontName = "Megrim"
iconCreator.lengths += [76.0, 152.0, 167.0]
iconCreator.config.string = "E"
iconCreator.config.fontOffsetScaleY = 0.05
iconCreator.config.fontOffsetScaleX = -0.01
iconCreator.config.fontSizeScaleY = 0.9
iconCreator.config.backgroundColor = UIColor(red: 118.0 / 255.0, green: 122 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)
iconCreator.preview()

iconCreator.save()
print("$ open \(iconCreator.rootPath)")


let logoCreator = LogoCreator()
logoCreator.config.fontName = iconCreator.config.fontName
logoCreator.sizes = [CGSize(width: 160, height: 48)]
logoCreator.config.string = "Edhita"
logoCreator.config.fontOffsetScaleX = -0.01
logoCreator.config.fontOffsetScaleY = 0.05
logoCreator.config.backgroundColor = iconCreator.config.backgroundColor
logoCreator.config.fontSizeScaleY = 1.13
logoCreator.preview()

logoCreator.save()
print("$ open \(logoCreator.rootPath)")
