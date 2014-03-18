//
//  NSObject+Printable.m
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.

#import "Printable.h"
#import "Printer.h"

@implementation NSObject (Printable)

- (void)print
{
    [[Printer connectedPrinter] print:[self performSelector:@selector(printedFormat)]];
}

@end
