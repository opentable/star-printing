//
//  FakeSMPort.h
//  StarPrintingExample
//
//  Created by Matthew Newberry on 2/19/14.
//  OpenTable
//

#import <Foundation/Foundation.h>
#import <StarIO/SMPort.h>
#import <StarIO/Port.h>
#import "Printer.h"

@interface FakeSMPort : SMPort

@property (nonatomic, assign) PrinterStatus status;

+ (PortInfo *)fakePortInfo;
+ (PortInfo *)fakePortInfo2;

+ (void)setup;

+ (void)addSecondPrinter;
+ (void)removeSecondPrinter;
+ (void)removeAllPrinters;
+ (void)addFirstPrinter;

@end
