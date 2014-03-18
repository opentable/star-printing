//
//  PrintQueue.h
//  Quickcue
//
//  Created by Will Loderhose on 1/29/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Printer.h"

@interface PrintQueue : NSOperationQueue

+ (PrintQueue *)sharedInstance;

@end
