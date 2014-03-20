//
//  FakePrinterManager.h
//  StarPrintingExample
//
//  Created by Matthew Newberry on 2/27/14.
//  OpenTable
//

#import <Foundation/Foundation.h>
#import "Printer.h"

@interface FakePrinterManager : NSObject

+ (instancetype)sharedInstance;

- (PrinterStatus)statusForPrinter:(Printer *)printer;
- (PrinterStatus)statusForPortName:(NSString *)portName;
- (void)setStatus:(PrinterStatus)status forPrinter:(Printer *)printer;

@end
