//
//  FakePrinterManager.h
//  Quickcue
//
//  Created by Matthew Newberry on 2/27/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Printer.h"

@interface FakePrinterManager : NSObject

+ (instancetype)sharedInstance;

- (PrinterStatus)statusForPrinter:(Printer *)printer;
- (PrinterStatus)statusForPortName:(NSString *)portName;
- (void)setStatus:(PrinterStatus)status forPrinter:(Printer *)printer;

@end
