//
//  PrintData.m
//  StarPrinting
//
//  Created by Will Loderhose on 3/20/14.
//  Copyright (c) 2014 OpenTable. All rights reserved.
//

#import "PrintData.h"

@implementation PrintData

- (id)initWithDictionary:(NSDictionary *)dictionary atFilePath:(NSString *)filePath
{
    self = [super init];
    
    if(self) {
        self.dictionary = dictionary;
        self.filePath = filePath;
    }
    
    return self;
}

@end
