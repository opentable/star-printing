//
//  PrintQueue.m
//  Quickcue
//
//  Created by Will Loderhose on 1/29/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import "PrintQueue.h"

static PrintQueue *_queue;

@implementation PrintQueue

+ (PrintQueue *)sharedInstance
{
    if(!_queue) {
        _queue = [[PrintQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    };
    
    return _queue;
}

@end
