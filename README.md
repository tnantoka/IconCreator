![](/logo.png)

Create app icons programmatically on Playground with Swift and Xcode.

```
CreatorConfiguration.loadFont("devicons.ttf")
let creator = IconCreator()
creator.config.fontName = "icomoon"
creator.config.string = "\u{e655}"
creator.config.backgroundColor = UIColor.orangeColor()
creator.preview()
```

![](/swift.png)

```
creator.save()
print("$ open \(creator.rootPath)") // $ open /path/to/Documents/IconCreator/
```
## Showcase

[![](/showcase/jsanywhere.png)](http://javascriptanywhere.net/)
[![](http://edhita.bornneet.com/assets/logo.png)](http://edhita.bornneet.com/)
[![](/showcase/140note.png)](http://www.140note.com/)
[![](https://raw.githubusercontent.com/tnantoka/AppBoard/master/AppBoard/Assets.xcassets/AppIcon.appiconset/icon120.png)](https://github.com/tnantoka/AppBoard)
[![](/showcase/remaining.png)](http://remaining.bornneet.com/)
[![](/showcase/iconcreator.png)](/showcase/iconcreator.png)

- [icon.png](/icon.png)
- [logo.pdf](/logo.pdf)

Pull requests are welcome!

## Acknowledgements

- https://www.google.com/fonts/specimen/Pacifico
- https://fortawesome.github.io/Font-Awesome/
- http://vorillaz.github.io/devicons/
- https://github.com/SSA111/SwiftImageToPDFConverter
- https://www.google.com/fonts/specimen/Italiana
- https://www.google.com/fonts/specimen/Megrim

## License

My code is licensed under the MIT license.  
**Each font has its own license!**

## See Also

[tnantoka/ScreenshotCreator](https://github.com/tnantoka/ScreenshotCreator)
