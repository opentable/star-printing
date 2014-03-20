//
//  NSObject+Printable.m
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.

#import "Printable.h"

@implementation NSObject (Printable)

- (void)print
{
    [[Printer connectedPrinter] print:[self performSelector:@selector(printedFormat)]];
}

- (void)print:(Printer *)printer
{
    [printer print:[self performSelector:@selector(printedFormat)]];
}

@end
