# FTFontSelector

[![Version](http://cocoapod-badges.herokuapp.com/v/FTFontSelector/badge.png)](http://cocoadocs.org/docsets/FTFontSelector)
[![Platform](http://cocoapod-badges.herokuapp.com/p/FTFontSelector/badge.png)](http://cocoadocs.org/docsets/FTFontSelector)

FTFontSelector implements a clone of the font selector that can be found in
Apple’s iOS Pages application.

![iPad Font Families](https://raw.github.com/Fingertips/FTFontSelector/master/Project/Screenshots/iPad%20Font%20Families.png)

![iPad Font Family Members](https://raw.github.com/Fingertips/FTFontSelector/master/Project/Screenshots/iPad%20Font%20Family%20Members.png)

![iPhone Font Families](https://raw.github.com/Fingertips/FTFontSelector/master/Project/Screenshots/iPhone%20Font%20Families.png)

![iPhone Font Family Members](https://raw.github.com/Fingertips/FTFontSelector/master/Project/Screenshots/iPhone%20Font%20Family%20Members.png)

For now it targets the current iOS 6 look, because we won’t know what Apple’s
version in iOS 7 will look like yet.


## Usage

The one exposed class that you need to work with is `FTFontSelectorController`.
This class is a self contained `UINavigationController` subclass that provides
all the required features.

To use it on the iPhone, it’s common to add the controller instance as a child
view controller in the same place that the keyboard is normally shown. On iPad
it’s common to show the controller in a `UIPopoverController`.

See the example app in `Project` for examples on both devices. Note that the
iPhone version uses a bit of a hack by adding the view to the `UITextView`’s
`inputView`. In Pages the keyboard is actually dismissed beforehand, so keep
this in mind.


## Installation

FTFontSelector is available through [CocoaPods](http://cocoapods.org), to
install it simply add the following line to your Podfile:

    pod "FTFontSelector"

Alternatively, add all the source files in `Classes` and the resource bundle at
`Assets/FTFontSelector.bundle` to your Xcode project and add `CoreText` to the
‘frameworks build phase’.


## Author

Eloy Durán, eloy.de.enige@gmail.com


## License

FTFontSelector is available under the MIT license. See the LICENSE file for
more info.
