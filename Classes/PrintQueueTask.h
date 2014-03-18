//
//  PrintQueueTask.h
//  Quickcue
//
//  Created by Will Loderhose on 1/30/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Printer.h"

@interface PrintQueueTask : NSOperation

@property (nonatomic, strong) Printer *printer;

- (id)initWithPrinter:(Printer *)printer;

//- (BOOL)openPort;
//- (void)releasePort;
//- (void)perform:(PrinterOperationBlock)block;
//- (void)updateStatus;
//- (void)connect:(PrinterResultBlock)result;
//- (void)connect;
//- (void)disconnect;

@end
