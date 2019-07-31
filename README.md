# Xcode Project
![swift >= 4.0](https://img.shields.io/badge/swift-%3E%3D4.0-brightgreen.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)


## Usage
```swift
import XcodeProj
    let project = try XcodeProject(fromURL: url)
    project.targets // Get an array of targets
    project.resources // Access to the files/groups within the project
    
import PBXProj
    let pbxFile = try PBXProj(fromURL: url)
    pbxFile.project // The project for this file
    pbxFile.mainGroup // Access tot he files/groups within the project
    pbxFile.objects // The array of objects within the file
```

## Dependencies

* **[Codable Helpers](https://github.com/TheAngryDarling/SwiftCodableHelpers)** - A collection of helper methods, classes, and protocols when working with Encodable and Decodable
* **[Code Timer](https://github.com/TheAngryDarling/SwiftCodeTimer)** - Provides a few help functions attached to the Timer class for timing code blocks (closures).
* **[Nillable](https://github.com/TheAngryDarling/SwiftNillable)** - Package used to identify nil/NSNull objects when stored in Any format
* **[Raw Representable Helpers](https://github.com/TheAngryDarling/SwiftRawRepresentableHelpers)** - Provides helper methods for interchanging between a RawRepresentable and its RawValue
* **[String IANA Character Set Encoding](https://github.com/TheAngryDarling/SwiftStringIANACharacterSetEncoding)** - IANA Character Set Encoding Conversion
* **[Swift Class Collections](https://github.com/TheAngryDarling/SwiftClassCollections)** - Package used to work with swift class based collections that are equivalent to Array and Dictionary
* **[Swift Patches](https://github.com/TheAngryDarling/SwiftPatches)** - Provides some of the missing classes/method when changing between different swift versions
* **[Version Kit](https://github.com/TheAngryDarling/SwiftVersionKit)** - Provides the ability to store, parse, edit, and compare version strings

## Author

* **Tyler Anger** - *Initial work* - [TheAngryDarling](https://github.com/TheAngryDarling)

## License

This project is licensed under Apache License v2.0 - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
While try to map out the format of the PBX Project File and other Xcode project files I used the following references:
[Wikipedia](https://en.wikipedia.org/wiki/Xcode)
[Monobjc](http://www.monobjc.net/xcode-project-file-format.html)
[Serialization](https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/JSONSerialization.swift)
