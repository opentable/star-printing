//
//  FakePrinterManager.m
//  Quickcue
//
//  Created by Matthew Newberry on 2/27/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import "FakePrinterManager.h"
#import "FakeSMPort.h"

@interface FakePrinterManager ()

@property (nonatomic, strong) NSMutableDictionary *statuses;

@end

@implementation FakePrinterManager

+ (instancetype)sharedInstance
{
    static FakePrinterManager *manager;
    if (!manager) {
        manager = [[FakePrinterManager alloc] init];
        manager.statuses = [NSMutableDictionary dictionary];
    }
    
    return manager;
}

- (PrinterStatus)statusForPrinter:(Printer *)printer
{
    return [self statusForPortName:[self identifierForPrinter:printer]];
}

- (PrinterStatus)statusForPortName:(NSString *)portName
{
    NSNumber *stored = self.statuses[portName];
    
    PrinterStatus status = PrinterStatusDisconnected;
    
    if (stored) {
        status = [stored intValue];
    }
    
    return status;
}

- (void)setStatus:(PrinterStatus)status forPrinter:(Printer *)printer
{
    self.statuses[[self identifierForPrinter:printer]] = @(status);
}

- (NSString *)identifierForPrinter:(Printer *)printer
{
    return printer.portName;
}

@end
