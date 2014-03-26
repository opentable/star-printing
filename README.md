# StarPrinting

Star print queue and persistence for iOS and Mac

## Overview

StarPrinting is a CocoaPod for iOS and Mac OS X that is built on top of the StarMicronics [StarIO SDK](http://www.starmicronics.com/support/technologycategorydetail.aspx?id=39). It provides a robust, yet easy-to-use framework with several features.

### Persistent Print Queue
Each printer that your application connects to keeps a queue of all attempted print jobs that is persistent and can only be lost if the application is killed. Print jobs that were never completed will retry for several minutes on a backround thread. If they continue to fail, they will remain paused in the queue until the printer is back online.

### Real-time Status Updates
Each printer also has a heartbeat that updates the printer status every few seconds.

The possible printer statuses are:

 - `PrinterStatusConnected` - Online and ready to print
 - `PrinterStatusConnecting` - Establishing a connection to printer
 - `PrinterStatusDisconnected` - Available with no errors but not connected
 - `PrinterStatusLowPaper` - Almost out of paper
 - `PrinterStatusOutOfPaper` - No paper in printer
 - `PrinterStatusCoverOpen` - Cover of printer is open
 - `PrinterStatusConnectionError` - Could not establish a connection to the printer
 - `PrinterStatusLostConnectionError` - Lost connection to the printer (probably due to the power being turned off or losing connection from network)
 - `PrinterStatusPrintError` - Invalid print data sent to printer
 - `PrinterStatusIncompatible` - Printer is not compatible with current version of StarPrinting
 - `PrinterStatusUnkownError` - An unknown error was encountered

## Installation

You can install StarPrinting like any other CocoaPod.
See [cocoapods.org](http://cocoapods.org/) for instructions on installing and using CocoaPods.

### Podfile

	platform :ios, '~> 7.0'
	pod "StarPrinting", "~> 0.1"


## Usage

### Importing
The following import statement is the only one you will ever need. It will import all the necessary header files from the pod.

```objective-c
	#import <StarPrinting.StarPrinting.h>
```

### Initializing
The best way to initialize a printer is to call the class method ```objective-c [Printer search:(PrinterSearchBlock)block]``` which returns an array of printer objects. Once you have connected to a printer, you can simply call the class method ```objective-c [Printer connectedPrinter]```.

### Searching
To search for available printers, use the class search method, passing in a result block.

```objective-c
	[Printer search:^(NSArray *listOfPrinters) {
		// do something with the list of printers
	}];
```

### Printer Delegates
StarPrinting also provides a printer delegate protocol so that an application can listen for status changes. Each printer delegate must implement the following method:

```objective-c
	- (void)printer:(Printer *)printer didChangeStatus:(PrinterStatus)status
	{
		// update UI based on new printer status
	}
```

### Printing
StarPrinting uses XML files to store print data. When any print method is called, it parses the XML, encodes the data into a printer-friendly format, and lastly sends it off to be printed. Example XML files can be found in the `StarPrintingExample/Sample Chit Sheets` folder.

To send data to the printer, you must create a `PrintData` object. `PrintData` is a wrapper object that has two properties:

 - `NSString` filePath
 - `NSDictionary` dictionary

The file path tells the printer where the XML file is located and the dictionary stores variable data to be consummed dynamically into the XML file.

#### Print Test
To print out a test sheet, simply call the `printTest` method on the printer. This is an example where the printer creates the `PrintData` wrapper object for you. The test sheet xml file is included in the pod under `Sample Chit Sheets`.

```objective-c
	Printer *printer = [Printer connectedPrinter];
	if(printer) {
		[printer printTest];
	}
}
```

#### Print Static XML Files
To print an XML file, you will need to create a `PrintData` object and pass it to the print method. For static XML files, simply pass in `nil` for the dictionary. 

```objective-c
	NSString *filePath = [NSBundle mainBundle] pathForResource:@"static_receipt" ofType:@"xml"];

	PrintData *printData = [[PrintData alloc] initWithDictionary:nil atFilePath:filePath];
	[[Printer connectedPrinter] print:printData];
```

#### Print Dynamic XML Files
For dynamic XML files, you will need to include a dictionary containing each variable you want to pass in.

```objective-c
	NSString *filePath = [NSBundle mainBundle] pathForResource:@"dynamic_receipt" ofType:@"xml"];

	NSDictionary *dictionary = @{
								  @"{{day}}" : self.day,
								  @"{{month}}" : self.month,
								  @"{{year}}" : self.year
								};

	PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
	[[Printer connectedPrinter] print:printData];
```

In the XML file, variables are created using double curly-brace syntax: `{{variable1}}`.

The following is an example XML file that requires a day, month, and year variable.

```xml
	<print>
    
    <text><center><b>The current day is: </b></center></text>
    <text>{{month}}-{{day}}-{{year}}</text>
    
	</print>
```

#### The Printable Protocol
One of the most powerful tools StarPrinting provides is the ability to conform to the `Printable` protocol from any Objective-C class. All classes that conform to `Printable` must implement the `printedFormat` method. This method simply returns a `PrintData` object. When `print` is called on an instance of the class, it will automatically call `printedFormat` and send that data to the printer.

Implementing the method:
```objective-c
	- (PrintData *)printedFormat
	{
		NSString *filePath = [NSBundle mainBundle] pathForResource:@"dynamic_receipt" ofType:@"xml"];

		NSDictionary *dictionary = @{
									  @"{{day}}" : self.day,
									  @"{{month}}" : self.month,
									  @"{{year}}" : self.year
									};

		return [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];
	}
```

Calling print on the object:
```objective-c
	[object print];
```
```objective-c
	[object print:printer];
```

## Examples

A sample application is inlcuded that demonstrates how to connect to the printer, display error messages based on printer status, and print out custom data.

## Contributors

StarPrinting was created by [Matt Newberry](https://github.com/MattNewberry) and [Will Loderhose](https://github.com/Will-Loderhose).

## License

StarPrinting is available under the MIT license. See the LICENSE file for more info.