//
//  PrintJob.h
//  Quickcue
//
//  Created by Will Loderhose on 1/29/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import "PrintQueueTask.h"
#import <Foundation/Foundation.h>

@interface PrintJob : PrintQueueTask

@property (nonatomic, strong) NSData *data;

- (id)initWithPrinter:(Printer *)printer printData:(NSData *)data;

@end
