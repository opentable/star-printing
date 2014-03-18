//
//  NSObject+Printable.h
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.

#import <Foundation/Foundation.h>
#import "Printer.h"

@protocol Printable <NSObject>

@required
- (NSData *)printedFormat;

@end

@interface NSObject (Printable)

- (void)print;
- (void)print:(Printer *)printer;

@end
