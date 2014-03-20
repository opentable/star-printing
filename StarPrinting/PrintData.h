//
//  PrintData.h
//  StarPrinting
//
//  Created by Will Loderhose on 3/20/14.
//  OpenTable
//

#import <Foundation/Foundation.h>

@interface PrintData : NSObject

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *filePath;

- (id)initWithDictionary:(NSDictionary *)dictionary atFilePath:(NSString *)filePath;

@end
