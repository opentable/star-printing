//
//  PrintData.h
//  StarPrinting
//
//  Created by Will Loderhose on 3/20/14.
//  OpenTable
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PrintData : NSObject

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic) UIImage *image;

- (id)initWithDictionary:(NSDictionary *)dictionary atFilePath:(NSString *)filePath;
- (id)initWithImage:(UIImage *)image;

@end
