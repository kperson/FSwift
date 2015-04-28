# [FSwift](https://github.com/kperson/FSwift/) [![Build Status](https://api.travis-ci.org/kperson/FSwift.png?branch=master)](https://travis-ci.org/kperson/FSwift)

FSwift is a framework for functional programming in Swift.  The goal is provide missing functional pieces for Apple's Swift language.  If you are not familiar with functional programming, I would recommend watching [Functional Principles for Object-Oriented Development - Jessica Kerr](https://www.youtube.com/watch?v=GpXsQ-NIKXY).  It is a great introduction for those coming from an object-oriented background.

## Features

* *Future and Promises* -- manage current operations using a simple Future and Promises implementation
* *Array Extensions* -- perform functional operations like reduce, map reduce, and fold
* *Time Extensions* -- convert integers to NSTimeintevals (e.g. let time = 5.minutes)

## Installation

* Run `xcodebuild -project FSwift.xcodeproj -scheme FSwift -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO` in the project directory
* Right before \*\* BUILD SUCCEEDED \*\* you should see a line like `/usr/bin/touch -c /Users/username/Library/Developer/Xcode/DerivedData/FSwift-eayrcnolmowzoocyokeqxabfpbmt/Build/Products/Debug-iphonesimulator/FSwift.framework`  
* In your Xcode target, in the general tab, add the framework file (FSwift.framework) to Embedded Binaries.   **Remove the framework from Linked Frameworks and Libraries, if it is present there.**

##Usage
`import FSwift` in your Swift file.

More info coming soon!
