# StarPrinting

Star print queue and persistence for iOS and Mac

## Overview

StarPrinting is a CocoaPod for iOS and Mac OS X that is built on top of the StarMicronics [StarIO SDK](http://www.starmicronics.com/support/technologycategorydetail.aspx?id=39). It provides a robust, yet easy-to-use framework with several features.

### Persistent Print Queue
Each printer that your application connects to keeps a queue of all attempted print jobs that is persistent and can only be lost if the application is killed. Print jobs that were never completed will retry for several minutes on a backround thread. If they continue to fail, they will remain paused in the queue until the printer is back online.

### Real-time Status Updates
Each printer also has a heartbeat that checks for printer errors every few seconds. Some of the possible printer statuses are:

 - `Connected`
 - `Connecting`
 - `Disconnected`
 - `Low Paper`
 - `Out of Paper`
 - `Cover Open`
 - `Connection Error`
 - `Print Error`

## Installation

You can install StarPrinting like any other CocoaPod.
See [cocoapods.org](http://cocoapods.org/) for instructions on installing and using CocoaPods.

### Podfile

	platform :ios, '~> 7.0'
	pod "StarPrinting", "~> 0.1"


## Usage



## Examples

A sample application is inlcuded that demonstrates how to connect to the printer, display error messages based on printer status, and print out custom data.

## Contributors

StarPrinting was created by [Matt Newberry](https://github.com/MattNewberry) and [Will Loderhose](https://github.com/Will-Loderhose).

## License

StarPrinting is available under the MIT license. See the LICENSE file for more info.