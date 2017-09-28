//
//  PrintData.m
//  StarPrinting
//
//  Created by Will Loderhose on 3/20/14.
//  OpenTable
//

#import "PrintData.h"

@implementation PrintData

- (id)initWithDictionary:(NSDictionary *)dictionary atFilePath:(NSString *)filePath
{
    return [self initWithDictionary:dictionary atFilePath:filePath image:nil];
}

- (id)initWithImage:(UIImage *)image {
    return [self initWithDictionary:nil atFilePath:nil image:image];
}

- (id)initWithDictionary:(NSDictionary *)dictionary atFilePath:(NSString *)filePath image:(UIImage *)image {
    self = [super init];

    if(self) {
        self.dictionary = dictionary;
        self.filePath = filePath;
        self.image = image;
    }

    return self;
}

@end
